use v6-alpha;

class KindaPerl6::Visitor::Emit::MiniPerl6Like {
    # This visitor is a MiniPerl6 style emitter
    method visit ( $node ) {
        '# Do not edit this file - Generated by KindaPerl6::Visitor::Emit::MiniPerlLike' ~ Main.newline
        ~ 'use v5;' ~ Main.newline
        ~ 'use strict;' ~ Main.newline
        ~ 'use KindaPerl6::Runtime::MiniPerl6Like::Runtime;' ~ Main.newline
        ~ 'use KindaPerl6::Runtime::MiniPerl6Like::Match;' ~ Main.newline
        ~ 'use autobox ARRAY=>"Array";' ~ Main.newline
        ~ $node.emit_mp6like() ~ Main.newline
        ~ '1;' ~ Main.newline
    };

}

class CompUnit {
    method emit_mp6like {
          'package ' ~ $.name ~ ";" ~ Main.newline 
        ~ 'sub new { shift; bless { @_ }, "' ~ $.name ~ '" }'  ~ Main.newline 
        ~ $.body.emit_mp6like ~ ';'
        ~ Main.newline
        ~ Main.newline
    }
}

class Val::Int {
    method emit_mp6like { $.int }
}

class Val::Bit {
    method emit_mp6like { $.bit }
}

class Val::Num {
    method emit_mp6like { $.num }
}

class Val::Buf {
    method emit_mp6like { '\'' ~ $.buf ~ '\'' }
}
class Val::Char {
    method emit_mp6like { 'chr('~ $.char ~ ')' }
}

class Val::Undef {
    method emit_mp6like { '(undef)' }
}

class Val::Object {
    method emit_mp6like {
        'bless(' ~ %.fields.perl ~ ', ' ~ $.class.perl ~ ')';
    }
}

class Lit::Seq {
    method emit_mp6like {
        '(' ~ (@.seq.>>emit_mp6like).join(', ') ~ ')';
    }
}

class Lit::Array {
    method emit_mp6like {
        '[' ~ (@.array.>>emit_mp6like).join(', ') ~ ']';
    }
}

class Lit::Hash {
    method emit_mp6like {
        my $fields := @.hash;
        my $str := '';
        for @$fields -> $field { 
            $str := $str ~ ($field[0]).emit_mp6like ~ ' => ' ~ ($field[1]).emit_mp6like ~ ',';
        }; 
        '{ ' ~ $str ~ ' }';
    }
}

#        my $bind := ::Bind( 
#            'parameters' => ::Lit::Array( array => $sig.positional ), 
#            'arguments'  => ::Var( sigil => '@', twigil => '', name => '_' )
#        );
#        $str := $str ~ $bind.emit_mp6like ~ '; ';


class Lit::Code {
    method emit_mp6like_declarations {
        my $s;
        my $name;
        for @($.pad.lexicals) -> $name {
            my $decl := Decl.new(
                decl => 'my',
                type => '',
                var  => Var.new(
                    sigil     => '',
                    twigil    => '',
                    name      => $name,
                    namespace => [ ],
                ),
            );
            $s := $s ~ $name.emit_mp6like ~ ';' ~ Main::newline();
        };
        return $s;
    };
    method emit_mp6like_arguments($invocant) {
        my $str := '';
        my $i := 0;
        for @($.sig.positional) -> $field { 
            $str := $str ~ ($field.key).emit_mp6like ~ ' = $_[' ~ $i ~ ']; ';
            $i := $i + 1;
        };
        #XXX $.sig.invocant
        ($invocant ?? 'my $self = shift; ' !! '') ~
        '$List__ = \@_; ' ~
        $str;
    };
    method emit_mp6like_body {
        (@.body.>>emit_mp6like).join( ";" ~ Main.newline )
    };
    method emit_mp6like {
        self.emit_mp6like_declarations ~
        self.emit_mp6like_body
    }
}

class Lit::Object {
    method emit_mp6like {
        # $.class ~ '->new( ' ~ @.fields.>>emit_mp6like.join(', ') ~ ' )';
        my $fields := @.fields;
        my $str := '';
        # say @fields.map(sub { $_[0].emit_mp6like ~ ' => ' ~ $_[1].emit_mp6like}).join(', ') ~ ')';
        for @$fields -> $field { 
            $str := $str ~ ($field[0]).emit_mp6like ~ ' => ' ~ ($field[1]).emit_mp6like ~ ',';
        }; 
        $.class ~ '->new( ' ~ $str ~ ' )';
    }
}
class Lit::NamedArgument {
    method emit_mp6like {
        $.key.emit_mp6like ~ '=>' ~ $.value.emit_mp6like;
    }
}
class Lit::Pair {
    method emit_mp6like {
        $.key.emit_mp6like ~ '=>' ~ $.value.emit_mp6like;
    }
}

class Index {
    method emit_mp6like {
        $.obj.emit_mp6like ~ '->[' ~ $.index.emit_mp6like ~ ']';
        # TODO
        # if ($.obj.isa(Lit::Seq)) {
        #    $.obj.emit_mp6like ~ '[' ~ $.index.emit_mp6like ~ ']';
        # }
        # else {
        #    $.obj.emit_mp6like ~ '->[' ~ $.index.emit_mp6like ~ ']';
        # }
    }
}

class Lookup {
    method emit_mp6like {
        $.obj.emit_mp6like ~ '->{' ~ $.index.emit_mp6like ~ '}';
    }
}

class Var {
    method emit_mp6like {
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
           ( $.twigil eq '.' )
        ?? ( '$self->{' ~ $.name ~ '}' )
        !!  (    ( $.name eq '/' )
            ??   ( $table{$.sigil} ~ 'MATCH' )
            !!   Main::mangle_name( $.sigil, $.twigil, $.name, $.namespace )
            )
    };
    #( $table{$.sigil} ~ $.name )
}

class Bind {
    method emit_mp6like {
        if $.parameters.isa( 'Lit::Array' ) {
            
            #  [$a, [$b, $c]] := [1, [2, 3]]
            
            my $a := $.parameters.array;
            #my $b := $.arguments.array;
            my $str := 'do { ';
            my $i := 0;
            for @$a -> $var { 
                my $bind := ::Bind( 
                    'parameters' => $var, 
                    # 'arguments' => ($b[$i]) );
                    'arguments'  => ::Index(
                        obj    => $.arguments,
                        index  => ::Val::Int( int => $i )
                    )
                );
                $str := $str ~ ' ' ~ $bind.emit_mp6like ~ '; ';
                $i := $i + 1;
            };
            return $str ~ $.parameters.emit_mp6like ~ ' }';
        };
        if $.parameters.isa( 'Lit::Hash' ) {

            #  {:$a, :$b} := { a => 1, b => [2, 3]}

            my $a := $.parameters.hash;
            my $b := $.arguments.hash;
            my $str := 'do { ';
            my $i := 0;
            my $arg;
            for @$a -> $var {

                $arg := ::Val::Undef();
                for @$b -> $var2 {
                    #say "COMPARE ", ($var2[0]).buf, ' eq ', ($var[0]).buf;
                    if ($var2[0]).buf eq ($var[0]).buf {
                        $arg := $var2[1];
                    }
                };

                my $bind := ::Bind( 'parameters' => $var[1], 'arguments' => $arg );
                $str := $str ~ ' ' ~ $bind.emit_mp6like ~ '; ';
                $i := $i + 1;
            };
            return $str ~ $.parameters.emit_mp6like ~ ' }';
        };

        if $.parameters.isa( 'Lit::Object' ) {

            #  ::Obj(:$a, :$b) := $obj

            my $class := $.parameters.class;
            my $a     := $.parameters.fields;
            my $b     := $.arguments;
            my $str   := 'do { ';
            my $i     := 0;
            my $arg;
            for @$a -> $var {
                my $bind := ::Bind( 
                    'parameters' => $var[1], 
                    'arguments'  => ::Call( invocant => $b, method => ($var[0]).buf, arguments => [ ], hyper => 0 )
                );
                $str := $str ~ ' ' ~ $bind.emit_mp6like ~ '; ';
                $i := $i + 1;
            };
            return $str ~ $.parameters.emit_mp6like ~ ' }';
        };
    
        if $.parameters.isa( 'Var') && ($.parameters.sigil eq '&') {
            # XXX
            return $.arguments.emit_mp6like;
        };
        $.parameters.emit_mp6like ~ ' = ' ~ $.arguments.emit_mp6like;
    }
}

class Assign {
    method emit_mp6like {
       #XXX 
       if ($.parameters.isa('Call')) { 
            return '('~($.parameters.invocant).emit_mp6like~')->'~$.parameters.method~'('~$.arguments.emit_mp6like~')';
       }
       my $bind := Bind.new('parameters' => $.parameters,'arguments' => $.arguments);
       $bind.emit_mp6like;
       #die "KindaPerl6::Visitor::Emit::MiniPerl6Like does not support assignment yet";
    }
}

class Proto {
    method emit_mp6like {
        ~$.name        
    }
}

class Call {
    #has $.hyper;
    method emit_mp6like {
        #XXX
        if ($.invocant.isa('Proto') && $.invocant.name eq 'Hash') {
            return ($.arguments[0]).emit_mp6like;
        };
        if ($.invocant.isa('Proto') && $.invocant.name eq 'Array') {
            return ($.arguments[0]).emit_mp6like;
        };

        my $invocant := $.invocant.emit_mp6like;
        if $invocant eq 'self' {
            $invocant := '$self';
        };

        if     $.method eq 'LOOKUP'
        { 
            return $invocant ~ '->{' ~ (@.arguments.>>emit_mp6like).join(', ') ~ '}';
        };
        if     $.method eq 'INDEX'
        { 
            return $invocant ~ '->[' ~ (@.arguments.>>emit_mp6like).join(', ') ~ ']';
        };

        if     ($.method eq 'values')
        { 
            if ($.hyper) {
                die "not implemented";
            }
            else {
                return '@{' ~ $invocant ~ '}';
            }
        };

        if     ($.method eq 'perl')
            || ($.method eq 'yaml')
            || ($.method eq 'say' )
            || ($.method eq 'join')
            || ($.method eq 'chars')
            || ($.method eq 'isa')
        { 
            if ($.hyper) {
                return 
                    '[ map { Main::' ~ $.method ~ '( $_, ' ~ ', ' ~ (@.arguments.>>emit_mp6like).join(', ') ~ ')' ~ ' } @{ ' ~ $invocant ~ ' } ]';
            }
            else {
                return
                    'Main::' ~ $.method ~ '(' ~ $invocant ~ ', ' ~ (@.arguments.>>emit_mp6like).join(', ') ~ ')';
            }
        };

        my $meth := $.method;
        if  $meth eq 'postcircumfix:<( )>'  {
             $meth := '';  
        };
        
        my $call := '->' ~ $meth ~ '(' ~ (@.arguments.>>emit_mp6like).join(', ') ~ ')';
        if ($.hyper) {
            '[ map { $_' ~ $call ~ ' } @{ ' ~ $invocant ~ ' } ]';
        }
        else {
            $invocant ~ $call;
        };

    }
}

class Apply {
    method emit_mp6like {
        
        my $code := $.code;

        #XXX $code.namespace
        if ($code.isa( 'Var' )) && ($code.sigil eq '&') && ($code.twigil eq '') {
            $code := $code.name;
        };

        if $code.isa( 'Str' ) { }
        else {
            return '(' ~ $.code.emit_mp6like ~ ')->(' ~ (@.arguments.>>emit_mp6like).join(', ') ~ ')';
        };

        if $code eq 'self'       { return '$self' };

        if $code eq 'make'       { return 'return('   ~ (@.arguments.>>emit_mp6like).join(', ') ~ ')' };

        if $code eq 'say'        { return 'Main::say('   ~ (@.arguments.>>emit_mp6like).join(', ') ~ ')' };
        if $code eq 'print'      { return 'Main::print(' ~ (@.arguments.>>emit_mp6like).join(', ') ~ ')' };
        if $code eq 'push'      { return 'Main::push(' ~ (@.arguments.>>emit_mp6like).join(', ') ~ ')' };
        if $code eq 'keys'      { return 'Main::keys(' ~ (@.arguments.>>emit_mp6like).join(', ') ~ ')' };
        if $code eq 'warn'       { return 'warn('        ~ (@.arguments.>>emit_mp6like).join(', ') ~ ')' };

        if $code eq 'array'      { return '@{' ~ (@.arguments.>>emit_mp6like).join(' ')    ~ '}' };

        if $code eq 'prefix:<~>' { return '("" . ' ~ (@.arguments.>>emit_mp6like).join(' ') ~ ')' };
        if $code eq 'prefix:<!>' { return '('  ~ (@.arguments.>>emit_mp6like).join(' ')    ~ ' ? 0 : 1)' };
        if $code eq 'prefix:<?>' { return '('  ~ (@.arguments.>>emit_mp6like).join(' ')    ~ ' ? 1 : 0)' };

        #XXX
        if $code eq 'prefix:<$>' { return '${' ~ (@.arguments.>>emit_mp6like).join(' ')    ~ '}' };
        if $code eq 'prefix:<@>' { return (@.arguments.>>emit_mp6like).join(' ') };
        if $code eq 'prefix:<%>' { return (@.arguments.>>emit_mp6like).join(' ') };

        if $code eq 'infix:<~>'  { return '('  ~ (@.arguments.>>emit_mp6like).join(' . ')  ~ ')' };
        if $code eq 'infix:<+>'  { return '('  ~ (@.arguments.>>emit_mp6like).join(' + ')  ~ ')' };
        if $code eq 'infix:<->'  { return '('  ~ (@.arguments.>>emit_mp6like).join(' - ')  ~ ')' };
        if $code eq 'infix:<>>'  { return '('  ~ (@.arguments.>>emit_mp6like).join(' > ')  ~ ')' };
        if $code eq 'infix:<<>'  { return '('  ~ (@.arguments.>>emit_mp6like).join(' > ')  ~ ')' };
        if $code eq 'infix:<x>'  { return '('  ~ (@.arguments.>>emit_mp6like).join(' x ')  ~ ')' };
        
        if $code eq 'infix:<&&>' { return '('  ~ (@.arguments.>>emit_mp6like).join(' && ') ~ ')' };
        if $code eq 'infix:<||>' { return '('  ~ (@.arguments.>>emit_mp6like).join(' || ') ~ ')' };
        if $code eq 'infix:<eq>' { return '('  ~ (@.arguments.>>emit_mp6like).join(' eq ') ~ ')' };
        if $code eq 'infix:<ne>' { return '('  ~ (@.arguments.>>emit_mp6like).join(' ne ') ~ ')' };
 
        if $code eq 'infix:<==>' { return '('  ~ (@.arguments.>>emit_mp6like).join(' == ') ~ ')' };
        if $code eq 'infix:<!=>' { return '('  ~ (@.arguments.>>emit_mp6like).join(' != ') ~ ')' };

        if $code eq 'ternary:<?? !!>' { 
            return '(' ~ (@.arguments[0]).emit_mp6like ~
                 ' ? ' ~ (@.arguments[1]).emit_mp6like ~
                 ' : ' ~ (@.arguments[2]).emit_mp6like ~
                  ')' };
        
        if ($.code.isa('Var') && @($.code.namespace)) {
            $code := ($.code.namespace).join('::') ~ '::' ~ $.code.name; 
        }
        $code ~ '(' ~ (@.arguments.>>emit_mp6like).join(', ') ~ ')';
        # '(' ~ $.code.emit_mp6like ~ ')->(' ~ @.arguments.>>emit_mp6like.join(', ') ~ ')';
    }
}

class Return {
    method emit_mp6like {
        return
        #'do { print Main::perl(caller(),' ~ $.result.emit_mp6like ~ '); return(' ~ $.result.emit_mp6like ~ ') }';
        'return(' ~ $.result.emit_mp6like ~ ')';
    }
}

class If {
    method emit_mp6like {
        'do { if (' ~ $.cond.emit_mp6like ~ ') { ' ~ ($.body.emit_mp6like) ~ ' } else { ' ~ ($.otherwise ?? $.otherwise.emit_mp6like !! '') ~ ' } }';
    }
}

class For {
    method emit_mp6like {
        my $cond := $.cond;
        if   $cond.isa( 'Var' ) 
          && $cond.sigil eq '@' 
        {
            $cond := ::Apply( code => 'prefix:<@>', arguments => [ $cond ] );
        };
        'do { for my ' ~ $.topic.emit_mp6like ~ ' ( ' ~ $cond.emit_mp6like ~ ' ) { ' ~ (@.body.>>emit_mp6like).join(';') ~ ' } }';
    }
}

class Decl {
    method emit_mp6like {
        my $decl := $.decl;
        my $name := $.var.name;
           ( $decl eq 'has' )
        ?? ( 'sub ' ~ $name ~ ' { ' ~
            '@_ == 1 ' ~
                '? ( $_[0]->{' ~ $name ~ '} ) ' ~
                ': ( $_[0]->{' ~ $name ~ '} = $_[1] ) ' ~
            '}' )
        !! $.decl ~ ' ' ~ $.type ~ ' ' ~ $.var.emit_mp6like;
    }
}

class Sig {
    method emit_mp6like {
        ' print \'Signature - TODO\'; die \'Signature - TODO\'; '
    };
}

class Method {
    method emit_mp6like {
        'sub ' ~ $.name ~ ' { ' ~ 
            $.block.emit_mp6like_declarations ~
            $.block.emit_mp6like_arguments(1) ~
            $.block.emit_mp6like_body ~
        ' }'
    }
}

class Sub {
    method emit_mp6like {
        'sub ' ~ $.name ~ ' { ' ~ 
            $.block.emit_mp6like_declarations ~
            $.block.emit_mp6like_arguments(0) ~
            $.block.emit_mp6like_body ~
        ' }'
    }
}

class Do {
    method emit_mp6like {
        'do { ' ~ 
          $.block.emit_mp6like ~ 
        ' }'
    }
}

class Use {
    method emit_mp6like {
        'use ' ~ $.mod
    }
}

=begin

=head1 NAME 

MiniPerl6::Perl5::Emit - Code generator for MiniPerl6-in-Perl5

=head1 SYNOPSIS

    $program.emit_mp6like  # generated Perl5 code

=head1 DESCRIPTION

This module generates Perl5 code for the MiniPerl6 compiler.

=head1 AUTHORS

The Pugs Team E<lt>perl6-compiler@perl.orgE<gt>.

=head1 SEE ALSO

The Perl 6 homepage at L<http://dev.perl.org/perl6>.

The Pugs homepage at L<http://pugscode.org/>.

=head1 COPYRIGHT

Copyright 2006 by Flavio Soibelmann Glock, Audrey Tang and others.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=end
