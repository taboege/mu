
use v6-alpha;

class KindaPerl6::Visitor::EmitLisp {

    # This visitor is a list emitter
    # TODO !!!
    
    method visit ( $node ) {
        $node.emit_lisp($.visitor_args{'secure'});
    };

}

class CompUnit {
    sub set_secure_mode( $args_secure ) {
        my $value := 'nil';
        if ($args_secure != 0) { $value := 't' };
        return '(defconstant +KP6_DISABLE_INSECURE_CODE+ ' ~ $value ~ ')' ~ Main::newline();
    };

    method emit_lisp( $args_secure ) {
          '(defpackage :' ~ $.name ~ ')' ~ Main::newline()
        ~ '(in-package :' ~ $.name ~ ')' ~ Main::newline()
        ~ ';; Do not edit this file - Lisp generated by ' ~ $Main::_V6_COMPILER_NAME ~ Main::newline()
        ~ set_secure_mode($args_secure)
        #~ '(load (compile-file "'~ Main::get_compiler_target_runtime() ~'"))' ~ Main::newline()
        ~ '(load (compile-file "lib/KindaPerl6/Runtime/Lisp/Runtime.lisp"))' ~ Main::newline()
        #~ 'my $_MODIFIED; BEGIN { $_MODIFIED = {} }' ~ Main::newline()

        # XXX - not sure about $_ scope
        #~ 'BEGIN { '
        #~   '$_ = ::DISPATCH($::Scalar, "new", { modified => $_MODIFIED, name => "$_" } ); '
        #~ '}' ~ Main::newline()

        ~ $.body.emit_lisp ~ Main::newline()
    }
}

class Val::Int {
    method emit_lisp { 
        "(make-instance \'Int :value " ~ $.int ~ ")" ~ Main::newline();
    }
}

class Val::Bit {
    method emit_lisp { 
        "(make-instance \'Bit :value " ~ $.bit ~ ")" ~ Main::newline();
    }
}

class Val::Num {
    method emit_lisp { 
        "(make-instance \'Num :value " ~ $.num ~ ")" ~ Main::newline();
    }
}

class Val::Buf {
    method emit_lisp { 
        "(make-instance \'Str :value " ~ '"' ~ Main::mangle_string( $.buf ) ~ '"' ~ ")" ~ Main::newline();
    }
}

class Val::Char {
    method emit_lisp { 
        # XXX Char != Str
        "(make-instance \'Str :value (code-char " ~ $.char ~ ") )" ~ Main::newline();
    }
}

class Val::Undef {
    method emit_lisp { 
        "(make-instance \'Undef )" ~ Main::newline();
    }
}

class Val::Object {
    method emit_lisp {
        die 'Emitting of Val::Object not implemented';
        # 'bless(' ~ %.fields.perl ~ ', ' ~ $.class.perl ~ ')';
    }
}

class Native::Buf {
    method emit_lisp { 
        die 'Emitting of Native::Buf not implemented';
        # '\'' ~ $.buf ~ '\''
    }
}

class Lit::Seq {
    method emit_lisp {
        '(' ~ (@.seq.>>emit_lisp).join(', ') ~ ')';
    }
}

class Lit::Array {
    method emit_lisp {
        "(make-instance \'Array :value (list " ~ (@.array.>>emit_lisp).join(' ') ~ ") )" ~ Main::newline();
    }
}

class Lit::Hash {
    method emit_lisp {
        my $fields := @.hash;
        my $str := '';
        my $field;
        for @$fields -> $field { 
            $str := $str ~ '(setf (gethash \'' ~ ($field[0]).emit_lisp ~ ' hash) ' ~ ($field[1]).emit_lisp ~ ')';
        }; 
          '(make-instance \'Hash :value '
        ~   '(let ((hash (make-hash-table))) ' ~ $str ~ ' hash)' 
        ~ ')'
        ~ Main::newline();
    }
}

class Lit::Pair {
    method emit_lisp {
        "(make-instance \'Pair :key " ~ $.key.emit_lisp ~ " :value " ~ $.value.emit_lisp ~ ")" ~ Main::newline();
    }
}

class Lit::NamedArgument {
    method emit_lisp {
        "(make-instance \'NamedArgument :_argument_name_ " ~ $.key.emit_lisp ~ " :value " ~ $.value.emit_lisp ~ ")" ~ Main::newline();
    }
}

class Lit::Code {
    method emit_lisp {
        self.emit_declarations ~ self.emit_body;
    };
    method emit_body {
        (@.body.>>emit_lisp).join('; ');
    };
    method emit_signature {
        $.sig.emit_lisp
    };
    method emit_declarations {
        my $s;
        my $name;
        for @($.pad.variable_names) -> $name {
            my $decl := ::Decl(
                decl => 'my',
                type => '',
                var  => ::Var(
                    sigil     => '',
                    twigil    => '',
                    name      => $name,
                    namespace => [ ],
                ),
            );
            $s := $s ~ $name.emit_lisp ~ ';' ~ Main::newline();
        };
        return $s;
    };
    method emit_arguments {
        my $array_  := ::Var( sigil => '@', twigil => '', name => '_',       namespace => [ ], );
        my $hash_   := ::Var( sigil => '%', twigil => '', name => '_',       namespace => [ ], );
        my $CAPTURE := ::Var( sigil => '$', twigil => '', name => 'CAPTURE', namespace => [ ],);
        my $CAPTURE_decl := ::Decl(decl=>'my',type=>'',var=>$CAPTURE);
        my $str := '';
        $str := $str ~ $CAPTURE_decl.emit_lisp;
        $str := $str ~ '::DISPATCH_VAR($CAPTURE,"STORE",::CAPTURIZE(\@_));';

        my $bind_ := ::Bind(parameters=>$array_,arguments=>::Call(invocant => $CAPTURE,method => 'array',arguments => []));
        $str := $str ~ $bind_.emit_lisp ~ ';';

        my $bind_hash := 
                     ::Bind(parameters=>$hash_, arguments=>::Call(invocant => $CAPTURE,method => 'hash', arguments => []));
        $str := $str ~ $bind_hash.emit_lisp ~ ';';

        my $i := 0;
        my $field;
        for @($.sig.positional) -> $field { 
            my $bind := ::Bind(parameters=>$field,arguments=>::Index(obj=> $array_ , 'index'=>::Val::Int(int=>$i)) );
            $str := $str ~ $bind.emit_lisp ~ ';';
            $i := $i + 1;
        };

        return $str;
    };
}

class Lit::Object {
    method emit_lisp {
        # $.class ~ '->new( ' ~ @.fields.>>emit_lisp.join(', ') ~ ' )';
        my $fields := @.fields;
        my $str := '';
        # say @fields.map(sub { $_[0].emit_lisp ~ ' => ' ~ $_[1].emit_lisp}).join(', ') ~ ')';
        my $field;
        for @$fields -> $field { 
            $str := $str ~ ($field[0]).emit_lisp ~ ' => ' ~ ($field[1]).emit_lisp ~ ',';
        }; 
        '::DISPATCH( $::' ~ $.class ~ ', \'new\', ' ~ $str ~ ' )' ~ Main::newline();
    }
}

class Index {
    method emit_lisp {
        '::DISPATCH( ' ~ $.obj.emit_lisp ~ ', \'INDEX\', ' ~ $.index.emit_lisp ~ ' )' ~ Main::newline();
    }
}

class Lookup {
    method emit_lisp {
        '::DISPATCH( ' ~ $.obj.emit_lisp ~ ', \'LOOKUP\', ' ~ $.index.emit_lisp ~ ' )' ~ Main::newline();
    }
}

class Assign {
    method emit_lisp {
        # TODO - same as ::Bind
        
        my $node := $.parameters;
        
        if $node.isa( 'Var' ) && @($node.namespace)     
        {
            # it's a global, 
            # and it should be autovivified

            $node :=
                ::Apply(
                    code => ::Var(
                        name      => 'ternary:<?? !!>',
                        twigil    => '',
                        sigil     => '&',
                        namespace => [ 'GLOBAL' ],
                    ),
                    arguments => [
                       ::Apply(
                            arguments => [ $node ],
                            code => ::Var( name => 'VAR_defined', twigil => '', sigil => '&', namespace => [ 'GLOBAL' ] ),
                        ),
                        $node,
                        ::Bind(
                            'parameters' => $node,  
                            'arguments'  => ::Call(
                                'invocant' => ::Var( name => '::Scalar', twigil => '', sigil => '$', namespace => [ ] ),  
                                'method'   => 'new',
                                'hyper'    => '',
                            ),
                        )
                    ],
                );

        };

        '::DISPATCH_VAR( ' ~ $node.emit_lisp ~ ', \'STORE\', ' ~ $.arguments.emit_lisp ~ ' )' ~ Main::newline();
    }
}

class Var {
    method emit_lisp {
        # Normalize the sigil here into $
        # $x    => $x
        # @x    => $List_x
        # %x    => $Hash_x
        # &x    => $Code_x
        my $table := {
            '$' => '$',
            '@' => '$List_',
            '%' => '$Hash_',
            '&' => '$Code_',
        };
        
        if $.twigil eq '.' {
            return '::DISPATCH( $self, "' ~ $.name ~ '" )'  ~ Main::newline()
        };
        
        if $.name eq '/' {
            return $table{$.sigil} ~ 'MATCH' 
        };
        
        return Main::mangle_name( $.sigil, $.twigil, $.name, $.namespace ); 
    };
    method perl {
        # this is used by the signature emitter
          '::DISPATCH( $::Signature::Item, "new", { ' 
        ~     'sigil  => \'' ~ $.sigil  ~ '\', '
        ~     'twigil => \'' ~ $.twigil ~ '\', '
        ~     'name   => \'' ~ $.name   ~ '\', '
        ~     'namespace => [ ], '
        ~ '} )' ~ Main::newline()
    }
}

class Bind {
    method emit_lisp {
    
        # XXX - replace Bind with Assign
        if $.parameters.isa('Call') 
        {
            return ::Assign(parameters=>$.parameters,arguments=>$.arguments).emit_lisp;
        };
        if $.parameters.isa('Lookup') {
            return ::Assign(parameters=>$.parameters,arguments=>$.arguments).emit_lisp;
        };
        if $.parameters.isa('Index') {
            return ::Assign(parameters=>$.parameters,arguments=>$.arguments).emit_lisp;
        };

        my $str := '::MODIFIED(' ~ $.parameters.emit_lisp ~ ');' ~ Main::newline();
        $str := $str ~ $.parameters.emit_lisp ~ ' = ' ~ $.arguments.emit_lisp;
        return 'do {'~$str~'}';
    }
}

class Proto {
    method emit_lisp {
        return '$::'~$.name;
    }
}

class Call {
    method emit_lisp {
        my $invocant;
        if $.invocant.isa( 'Proto' ) {

            if $.invocant.name eq 'self' {
                $invocant := '$self';
            }
            else {
                $invocant := $.invocant.emit_lisp;
            }
            
        }
        else {
            $invocant := $.invocant.emit_lisp;
        };
        if $invocant eq 'self' {
            $invocant := '$self';
        };
        
        my $meth := $.method;
        if  $meth eq 'postcircumfix:<( )>'  {
             $meth := '';  
        };
        
        my $call := (@.arguments.>>emit_lisp).join(', ');
        if ($.hyper) {
            # TODO - hyper + role
            '[ map { $_' ~ '->' ~ $meth ~ '(' ~ $call ~ ') } @{ ' ~ $invocant ~ ' } ]' ~ Main::newline();
        }
        else {
            if ( $meth eq '' ) {
                # $var.()
                '::DISPATCH( ' ~ $invocant ~ ', \'APPLY\', ' ~ $call ~ ' )' ~ Main::newline()
            }
            else {
                  '::DISPATCH( ' 
                ~ $invocant ~ ', '
                ~ '\'' ~ $meth ~ '\', '
                ~ $call
                ~ ' )' 
                ~ Main::newline()
            };
        };
        

    }
}

class Apply {
    method emit_lisp {
        if     ( $.code.name eq 'self' )
            # && ( @.arguments.elems == 0 )
        {
            return '$self';
        }

        my $op := $.code.emit_lisp;
        # XXX short circuit ops
        # ||
        if $op eq '$GLOBAL::Code_infix_58__60__124__124__62_' {
             return
             'do { do { my $____some__weird___var____ = ' ~ (@.arguments[0]).emit_lisp ~ '; ' ~
                '::DISPATCH($____some__weird___var____,"true")->{_value} && $____some__weird___var____ ' ~
             '} ||' ~
             'do { my $____some__weird___var____ = ' ~ (@.arguments[1]).emit_lisp ~ '; ' ~
                '::DISPATCH($____some__weird___var____,"true")->{_value} && $____some__weird___var____ ' ~
             '} || ::DISPATCH( $::Bit, "new", 0 ) }' ~ Main::newline();
        }
        # ||
        if $op eq '$GLOBAL::Code_infix_58__60__38__38__62_' {
             return 'do { ( ' ~
             'do { my $____some__weird___var____ = ' ~ (@.arguments[0]).emit_lisp ~ '; ' ~
                '::DISPATCH($____some__weird___var____,"true")->{_value} && $____some__weird___var____ ' ~
             '} &&' ~
             'do { my $____some__weird___var____ = ' ~ (@.arguments[1]).emit_lisp ~ '; ' ~
                '::DISPATCH($____some__weird___var____,"true")->{_value} && $____some__weird___var____ ' ~
             '}) || ::DISPATCH( $::Bit, "new", 0) }' ~ Main::newline();
        }
        return  '::DISPATCH( ' ~ $op ~ ', \'APPLY\', ' ~ (@.arguments.>>emit_lisp).join(', ') ~ ' )' ~ Main::newline();
    }
}

class Return {
    method emit_lisp {
        return
        #'do { print Main::perl(caller(),' ~ $.result.emit_lisp ~ '); return(' ~ $.result.emit_lisp ~ ') }';
        'return(' ~ $.result.emit_lisp ~ ')' ~ Main::newline();
    }
}

class If {
    method emit_lisp {
        'do { if (::DISPATCH(::DISPATCH(' ~ $.cond.emit_lisp ~ ',"true"),"p5landish") ) ' 
        ~ ( $.body 
            ?? '{ ' ~ $.body.emit_lisp ~ ' } '
            !! '{ } '
          )
        ~ ( $.otherwise 
            ?? ' else { ' ~ $.otherwise.emit_lisp ~ ' }' 
            !! '' 
          )
        ~ ' }' ~ Main::newline();
    }
}

class For {
    method emit_lisp {
        my $cond := $.cond;
        if   $cond.isa( 'Var' ) 
          && $cond.sigil eq '@' 
        {
        } else {
            $cond := ::Apply( code => ::Var(sigil=>'&',twigil=>'',name=>'prefix:<@>',namespace => [ 'GLOBAL' ],), arguments => [$cond] );
        }
        'for ' 
        ~   $.topic.emit_lisp 
        ~ ' ( @{ ' ~ $cond.emit_lisp ~ '->{_value}{_array} } )'
        ~ ' { ' 
        ~     $.body.emit_lisp 
        ~ ' } '
        ~ Main::newline();
    }
}

class While {
    method emit_lisp {
        my $cond := $.cond;
        if   $cond.isa( 'Var' ) 
          && $cond.sigil eq '@' 
        {
        } else {
            $cond := ::Apply( code => ::Var(sigil=>'&',twigil=>'',name=>'prefix:<@>',namespace => [ 'GLOBAL' ],), arguments => [$cond] );
        }
        'do { while (::DISPATCH(::DISPATCH(' ~ $.cond.emit_lisp ~ ',"true"),"p5landish") ) ' 
        ~ ' { ' 
        ~     $.body.emit_lisp 
        ~ ' } }'
        ~ Main::newline();
    }
}

class Decl {
    method emit_lisp {
        my $decl := $.decl;
        my $name := $.var.name;
        if $decl eq 'has' {
            return 'sub ' ~ $name ~ ' { ' ~
            '@_ == 1 ' ~
                '? ( $_[0]->{' ~ $name ~ '} ) ' ~
                ': ( $_[0]->{' ~ $name ~ '} = $_[1] ) ' ~
            '}';
        };
        my $create := ', \'new\', { modified => $_MODIFIED, name => \'' ~ $.var.emit_lisp ~ '\' } ) ';
        if $decl eq 'our' {
            my $s;
            # ??? use vars --> because compile-time scope is too tricky to use 'our'
            # ??? $s := 'use vars \'' ~ $.var.emit_lisp ~ '\'; ';  
            $s := 'our ';

            if ($.var).sigil eq '$' {
                return $s 
                    ~ $.var.emit_lisp
                    ~ ' = ::DISPATCH( $::Scalar' ~ $create
                    ~ ' unless defined ' ~ $.var.emit_lisp ~ '; '
                    ~ 'BEGIN { '
                    ~     $.var.emit_lisp
                    ~     ' = ::DISPATCH( $::Scalar' ~ $create
                    ~     ' unless defined ' ~ $.var.emit_lisp ~ '; '
                    ~ '}' ~ Main::newline()
            };
            if ($.var).sigil eq '&' {
                return $s 
                    ~ $.var.emit_lisp
                    ~ ' = ::DISPATCH( $::Routine' ~ $create ~ ';' ~ Main::newline();
            };
            if ($.var).sigil eq '%' {
                return $s ~ $.var.emit_lisp
                    ~ ' = ::DISPATCH( $::Hash' ~ $create ~ ';' ~ Main::newline();
            };
            if ($.var).sigil eq '@' {
                return $s ~ $.var.emit_lisp
                    ~ ' = ::DISPATCH( $::Array' ~ $create ~ ';' ~ Main::newline();
            };
            return $s ~ $.var.emit_lisp ~ Main::newline();
        };
        if ($.var).sigil eq '$' {
            return 
                  $.decl ~ ' ' 
                # ~ $.type ~ ' ' 
                ~ $.var.emit_lisp ~ '; '
                ~ $.var.emit_lisp
                ~ ' = ::DISPATCH( $::Scalar' ~ $create
                ~ ' unless defined ' ~ $.var.emit_lisp ~ '; '
                ~ 'BEGIN { '
                ~     $.var.emit_lisp
                ~     ' = ::DISPATCH( $::Scalar' ~ $create
                ~ '}'
                ~ Main::newline()
                ;
        };
        if ($.var).sigil eq '&' {
            return 
                  $.decl ~ ' ' 
                # ~ $.type ~ ' ' 
                ~ $.var.emit_lisp ~ '; '
                ~ $.var.emit_lisp
                ~ ' = ::DISPATCH( $::Routine' ~ $create
                ~ ' unless defined ' ~ $.var.emit_lisp ~ '; '
                ~ 'BEGIN { '
                ~     $.var.emit_lisp
                ~     ' = ::DISPATCH( $::Routine' ~ $create
                ~ '}'
                ~ Main::newline()
                ;
        };
        if ($.var).sigil eq '%' {
            return $.decl ~ ' ' 
                # ~ $.type 
                ~ ' ' ~ $.var.emit_lisp
                ~ ' = ::DISPATCH( $::Hash' ~ $create ~ '; '
                ~ Main::newline();
        };
        if ($.var).sigil eq '@' {
            return $.decl ~ ' ' 
                # ~ $.type 
                ~ ' ' ~ $.var.emit_lisp
                ~ ' = ::DISPATCH( $::Array' ~ $create ~ '; '
                ~ Main::newline();
        };
        return $.decl ~ ' ' 
            # ~ $.type ~ ' ' 
            ~ $.var.emit_lisp;
    }
}

class Sig {
    method emit_lisp {
        my $inv := '$::Undef';
        if $.invocant.isa( 'Var' ) {
            $inv := $.invocant.perl;
        }
            
        my $pos;
        my $decl;
        for @($.positional) -> $decl {
            $pos := $pos ~ $decl.perl ~ ', ';
        };

        my $named := '';  # TODO

          '::DISPATCH( $::Signature, "new", { '
        ~     'invocant => ' ~ $inv ~ ', '
        ~     'array    => ::DISPATCH( $::Array, "new", { _array => [ ' ~ $pos   ~ ' ] } ), '
        ~     'hash     => ::DISPATCH( $::Hash,  "new", { _hash  => { ' ~ $named ~ ' } } ), '
        ~     'return   => $::Undef, '
        ~ '} )'
        ~ Main::newline();
    };
}

class Capture {
    method emit_lisp {
        my $s := '::DISPATCH( $::Capture, "new", { ';
        if defined $.invocant {
           $s := $s ~ 'invocant => ' ~ $.invocant.emit_lisp ~ ', ';
        }
        else {
            $s := $s ~ 'invocant => $::Undef, '
        };
        if defined $.array {
           $s := $s ~ 'array => ::DISPATCH( $::Array, "new", { _array => [ ';
                            my $item;
           for @.array -> $item { 
                $s := $s ~ $item.emit_lisp ~ ', ';
            }
            $s := $s ~ ' ] } ),';
        };
        if defined $.hash {
           $s := $s ~ 'hash => ::DISPATCH( $::Hash, "new", { _hash => { ';
                           my $item;
           for @.hash -> $item { 
                $s := $s ~ ($item[0]).emit_lisp ~ '->{_value} => ' ~ ($item[1]).emit_lisp ~ ', ';
            }
            $s := $s ~ ' } } ),';
        };
        return $s ~ ' } )' ~ Main::newline();
    };
}

class Subset {
    method emit_lisp {
          '::DISPATCH( $::Subset, "new", { ' 
        ~ 'base_class => ' ~ $.base_class.emit_lisp 
        ~ ', '
        ~ 'block => '    
        ~       'sub { local $_ = shift; ' ~ ($.block.block).emit_lisp ~ ' } '    # XXX
        ~ ' } )' ~ Main::newline();
    }
}

class Method {
    method emit_lisp {
          '::DISPATCH( $::Code, \'new\', { '
        ~   'code => sub { '  
        ~     $.block.emit_declarations 
        ~     '$self = shift; ' 
        ~     $.block.emit_arguments 
        ~     $.block.emit_body
        ~    ' }, '
        ~   'signature => ' 
        ~       $.block.emit_signature
        ~    ', '
        ~ ' } )' 
        ~ Main::newline();
    }
}

class Sub {
    method emit_lisp {
          '::DISPATCH( $::Code, \'new\', { '
        ~   'code => sub { '  
        ~       $.block.emit_declarations 
        ~       $.block.emit_arguments 
        ~       $.block.emit_body
        ~    ' }, '
        ~   'signature => ' 
        ~       $.block.emit_signature
        ~    ', '
        ~ ' } )' 
        ~ Main::newline();
    }
}

class Do {
    method emit_lisp {
        'do { ' ~ 
          $.block.emit_lisp ~ 
        ' }'
        ~ Main::newline();
    }
}

class BEGIN {
    method emit_lisp {
        'BEGIN { ' ~ 
          $.block.emit_lisp ~ 
        ' }'
    }
}

class Use {
    method emit_lisp {
        if ($.mod eq 'v6') {
            return Main::newline() ~ '#use v6' ~ Main::newline();
        }
        if ( $.perl5 ) {
            return 'use ' ~ $.mod ~ ';$::' ~ $.mod ~ '= KindaPerl6::Runtime::Perl5::Wrap::use5(\'' ~ $.mod ~ '\')';
        } else {
            return 'use ' ~ $.mod;
        }
    }
}

=begin

=head1 NAME 

KindaPerl6::Perl5::EmitPerl5 - Code generator for KindaPerl6-in-Perl5

=head1 DESCRIPTION

This module generates Perl5 code for the KindaPerl6 compiler.

=head1 AUTHORS

The Pugs Team E<lt>perl6-compiler@perl.orgE<gt>.

=head1 SEE ALSO

The Perl 6 homepage at L<http://dev.perl.org/perl6>.

The Pugs homepage at L<http://pugscode.org/>.

=head1 COPYRIGHT

Copyright 2007 by Flavio Soibelmann Glock and others.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=end
