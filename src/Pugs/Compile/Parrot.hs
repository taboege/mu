{-# OPTIONS_GHC -fglasgow-exts #-}

module Pugs.Compile.Parrot where
import Pugs.Internals
import Pugs.Pretty
import Pugs.AST
import Pugs.Types
import Pugs.Eval
import Text.PrettyPrint
import qualified Pugs.Types.Scalar as Scalar
import qualified Pugs.Types.Code   as Code
import qualified Data.Map       as Map

-- XXX This compiler needs a totaly rewrite using Parrot AST,
-- XXX and maybe TH-based AST combinators

class (Show x) => Compile x where
    compile :: x -> Eval Doc
    compile x = fail ("Unrecognized construct: " ++ show x)

genIMC :: Eval Val
genIMC = do
    Env{ envBody = exp, envGlobal = globRef } <- ask

    glob <- liftIO $ readIORef globRef
    ref  <- liftIO $ newIORef $ Map.fromList [("tempPMC", "9")]

    -- get a list of functions
    local (\e -> e{ envDebug = Just ref }) $ do

    pmc  <- askPMC
    init <- local (\e -> e{ envStash = pmc }) $ compile glob

    pmc  <- askPMC
    main <- local (\e -> e{ envStash = pmc }) $ compile exp

    return . VStr . unlines $
        [ "#!/usr/bin/env parrot"
        , renderStyle (Style PageMode 0 0) init
        , renderStyle (Style PageMode 0 0) $ vcat
            [ text ".sub main @MAIN"
            , nest 4 main
            , text ".end"
            ]
        ]

instance Compile Doc where
    compile = return

instance Compile Pad where
    compile pad = fmap vcat $ mapM compile (padToList pad)

instance Compile (String, [IORef VRef]) where
    compile (('&':name), [sym]) = do
        imc <- compile sym
        return $ vcat
            [ text (".sub \"" ++ name ++ "\"")
            , nest 4 imc
            , text ".end"
            ]
    compile _ = fail "fnord"

instance Compile (IORef VRef) where
    compile x = do
        ref <- liftIO $ readIORef x
        compile ref

instance Compile VRef where
    compile (MkRef (ICode cv)) = do
        vsub <- Code.fetch cv
        compile vsub
    compile (MkRef (IScalar sv))
        | Scalar.iType sv == mkType "Scalar::Const" = do
            sv  <- Scalar.fetch sv
            ref <- fromVal sv
            compile (ref :: VCode)
    compile x = internalError ("Unrecognized construct: " ++ show x)

instance Compile VCode where
    compile sub = do
        prms <- mapM compile (subParams sub)
        body <- compile (subFun sub)
        return . vcat $ prms ++ [ text "", body ]

instance Compile Param where
    compile prm = return $ text ".param pmc" <+> varText (paramName prm)

varText ('$':name)  = text $ "s__" ++ name
varText ('@':name)  = text $ "a__" ++ name
varText ('%':name)  = text $ "h__" ++ name
varText x           = error $ "invalid name: " ++ x

varInit ('$':_) = text $ "PerlUndef"
varInit ('@':_) = text $ "PerlArray"
varInit ('%':_) = text $ "PerlHash"
varInit x       = error $ "invalid name: " ++ x

askPMC :: Eval String
askPMC = do
    Just ioRef <- asks envDebug
    fm <- liftIO $ readIORef ioRef
    let cnt = Map.findWithDefault "0" "tempPMC" fm
    return $ "$P" ++ cnt

tempPMC :: Eval Doc
tempPMC = incCounter "tempPMC" ("$P" ++)

tempLabels :: [String] -> Eval [Doc]
tempLabels strs = do
    tmp <- incCounter "label" ("LABEL_" ++)
    return $ map ((tmp <> text "_" <>) . text) strs

incCounter key f = do
    Just ioRef <- asks envDebug
    liftIO $ do
        fm <- readIORef ioRef
        let cnt = Map.findWithDefault "0" key fm
            cnt' = show (read cnt + (1 :: Int))
        writeIORef ioRef (Map.insert key cnt' fm)
        return $ text (f cnt')

instance Compile SourcePos where
    compile SourcePos{ sourceName = file, sourceLine = line } = return $ hsep $
        [ text "#line"
        , doubleQuotes $ text file
        , showText line
        ]


label doc = doc <> text ":"

compileCond neg [cond, bodyIf, bodyElse] = do
    [alt, end]  <- tempLabels ["else", "endif"]
    (condC, p)  <- compileArg cond
    (ifC, _)    <- compileArg bodyIf
    (elseC, _)  <- compileArg bodyElse
    return $ vcat $
        [ condC
        , text neg <+> p <+> text "goto" <+> alt
        , ifC
        , text "goto" <+> end
        , label alt
        , elseC
        , label end
        ]
compileCond x y = error $ show (x,y)

instance Compile Exp where
    compile (Var name) = do
        lv <- asks envLValue
        let p = varText name
        constPMC (if lv then p else text "assign" <+> p)
    compile (Syn ";" stmts) = fmap vcat $ mapM compile stmts
    compile (Syn "block" blocks) = fmap vcat $ mapM compile blocks
    compile (Syn "=" [lhs, rhs]) = do
        (lhsC, p1) <- enterLValue $ compileArg lhs
        (rhsC, p2) <- enterRValue $ compileArg rhs
        p <- constPMC p1
        return $ vcat [ lhsC, rhsC, p1 <+> text "= assign" <+> p2, p ]
    compile (Syn "if" exps) = compileCond "unless" exps
    compile (Syn "unless" exps) = compileCond "if" exps
    compile (Syn "loop" [pre, cond, post, body]) = do
        [start, end, last] <- tempLabels ["start", "end", "last"]
        preC  <- compile pre
        bodyC <- compile body
        postC <- compile post
        condC <- compile cond
        return $ vcat $
            [ preC
            , text "goto" <+> end
            , label start
            , text ".local pmc last"
            , text "last = new Continuation"
            , text "set_addr last," <+> last
            , bodyC
            , postC
            , label end
            , condC
            , text "goto" <+> start
            , label last
            ]
    compile (App "&return" [] [val]) = do
        (valC, p) <- compileArg val
        return $ valC $+$ text ".return" <+> parens p
    compile (App "&last" _ _) = return $ text "invoke last"
    compile (App "&substr" [] [str, idx, Val (VInt 1)]) = do
        (strC, p1) <- enterLValue $ compileArg str
        (idxC, p2) <- enterLValue $ compileArg idx
        rv         <- constPMC $ hcat [ p1, text "[" , p2, text "]"]
        return $ vcat [strC, idxC, rv]
    compile (App "&postfix:++" [inv] []) = do
        (invC, p) <- enterLValue $ compileArg inv
        return $ invC $+$ text "inc" <+> p
    compile (App "&postfix:--" [inv] []) = do
        (invC, p) <- enterLValue $ compileArg inv
        return $ invC $+$ text "dec" <+> p
    -- compile (App "&infix:~" [exp, Val (VStr "")] []) = compile exp
    compile (App "&infix:~" [exp1, exp2] []) = do
        tmp <- currentStash
        (arg1, p1) <- compileArg exp1
        (arg2, p2) <- compileArg exp2
        return $ vcat $
            [ arg1
            , arg2
            , tmp <+> text "= new PerlUndef"
            , text "concat" <+> tmp <> comma <+> p1 <> comma <+> p2
            ]
    compile (App ('&':'i':'n':'f':'i':'x':':':op) [lhs, rhs] []) = do
        (lhsC, p1) <- compileArg lhs
        (rhsC, p2) <- compileArg rhs
        rv  <- case op of
            --- XXX look at signature
            "<" -> do
                i <- constPMC (text "$I9")
                return $ text "$I9 =" <+> text "islt" <+> p1 <> comma <+> p2 $+$ i
            ">" -> do
                i <- constPMC (text "$I9")
                return $ text "$I9 =" <+> text "isgt" <+> p1 <> comma <+> p2 $+$ i
            _ -> do
                constPMC $ p1 <+> text op <+> p2
        return $ vcat [ lhsC, rhsC, rv ]
    compile (App "&say" invs args) = 
        compile $ App "&print" invs (args ++ [Val $ VStr "\n"])
    compile (App "&print" invs args) = do
        actions <- fmap vcat $ mapM (compileWith (text "print" <+>)) (invs ++ args)
        rv      <- compile (Val (VBool True))
        return $ actions $+$ rv
    compile (App ('&':name) _ [arg]) = do
        lhsC <- tempPMC
        compileWith (\tmp -> lhsC <+> text "=" <+> text name <> parens tmp) arg
    compile (App "&not" [] []) = return $ text "new PerlUndef"
    compile (Val (VStr x))  = constPMC $ showText $ encodeUTF8 (concatMap quoted x)
    compile (Val (VInt x))  = constPMC $ integer x
    compile (Val (VNum x))  = constPMC $ showText x
    compile (Val (VRat x))  = constPMC $ showText $ ratToNum x
    compile (Val VUndef)    = constPMC $ text "PerlUndef"
    compile (Val (VBool True)) = constPMC $ text "1"
    compile (Val (VBool False)) = constPMC $ text "0"
    compile Noop            = return empty
    compile (Stmts stmts) = fmap vcat $ sequence
        [ do
            posC  <- compile pos
            stmtC <- compile stmt
            return $ posC $+$ stmtC $+$ text ""
        | (stmt, pos) <- stmts
        ]
    compile (Pad _ pad) = return $ vcat $ concat
        [ [ text ".local" <+> text "pmc" <+> varText name
          , varText name <+> text "=" <+> text "new" <+> varInit name
          ]
          | (name, _) <- padToList pad
        ]
    compile (Syn "mval" [exp]) = compile exp
    compile (Syn "," things) = fmap vcat $ mapM compile things
    compile (Syn syn [lhs, exp]) | last syn == '=' =
        compile $ Syn "=" [lhs, App ("&infix:" ++ init syn) [lhs, exp] []]
    compile (Cxt _ exp) = compile exp
    compile x = error $ "Cannot compile: " ++ (show x)

showText :: (Show a) => a -> Doc
showText = text . show

compileAssign :: Doc -> Exp -> Eval Doc
compileAssign lhsC rhs@(Var _) = do
    rhsC <- compile rhs
    return $ hsep [ lhsC, text "=", text "assign", rhsC ]
compileAssign lhsC (App ('&':name) _ [arg]) = do
    compileWith (\tmp -> lhsC <+> text "=" <+> text name <> parens tmp) arg
compileAssign lhsC (Syn "[]" [arr, idx]) = do
    arrC <- compile arr
    idxC <- compile idx
    return $ vcat [ lhsC <+> text "=" <+> arrC <> text "[" <> idxC <> text "]" ]
compileAssign lhsC rhs = do
    rhsC <- compile rhs
    tmp  <- askPMC
    return $ rhsC $+$ hsep [ lhsC, text "=", text tmp ]

compileWith :: (Doc -> Doc) -> Exp -> Eval Doc
compileWith f x = do
    tmp  <- tempPMC
    pmc  <- askPMC
    argC <- local (\e -> e{ envStash = pmc }) $ compile x
    return $ vcat [ argC, f tmp ]

currentStash = fmap text $ asks envStash
constPMC doc = do
    tmp  <- currentStash
    return $ vcat
        [ tmp <+> text "= new PerlUndef"
        , tmp <+> text "=" <+> doc
        ]

compileArg exp = do
    tmp  <- tempPMC
    pmc  <- askPMC
    argC <- local (\e -> e{ envStash = pmc }) $ compile exp
    return (argC, tmp)
