{

    package Array;

    # Do not edit this file - Perl 5 generated by KindaPerl6
    use v5;
    use strict;
    no strict "vars";
    use constant KP6_DISABLE_INSECURE_CODE => 0;
    use KindaPerl6::Runtime::Perl5::KP6Runtime;
    my $_MODIFIED;
    BEGIN { $_MODIFIED = {} }
    BEGIN { $_ = ::DISPATCH( $::Scalar, "new", { modified => $_MODIFIED, name => "$_" } ); }
    {
        do {
            if ( ::DISPATCH( ::DISPATCH( ::DISPATCH( $GLOBAL::Code_VAR_defined, 'APPLY', $::Array ), "true" ), "p5landish" ) ) { }
            else {
                {
                    do {
                        ::MODIFIED($::Array);
                        $::Array = ::DISPATCH( ::DISPATCH( $::Class, 'new', ::DISPATCH( $::Str, 'new', 'Array' ) ), 'PROTOTYPE', );
                        }
                }
            }
        };
        ::DISPATCH( ::DISPATCH( $::Array, 'HOW', ), 'add_parent', ::DISPATCH( $::Str, 'new', 'Container' ) );
        ::DISPATCH(
            ::DISPATCH( $::Array, 'HOW', ),
            'add_method',
            ::DISPATCH( $::Str, 'new', 'perl' ),
            ::DISPATCH(
                $::Code, 'new',
                {   code => sub {
                        my $s;
                        $s = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$s' } ) unless defined $s;
                        BEGIN { $s = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$s' } ) }
                        my $List__ = ::DISPATCH( $::Array, 'new', { modified => $_MODIFIED, name => '$List__' } );
                        my $self;
                        $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) unless defined $self;
                        BEGIN { $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) }
                        $self = shift;
                        my $CAPTURE;
                        $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) unless defined $CAPTURE;
                        BEGIN { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
                        ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                        do {
                            ::MODIFIED($List__);
                            $List__ = ::DISPATCH( $CAPTURE, 'array', );
                        };
                        do {
                            ::MODIFIED($Hash__);
                            $Hash__ = ::DISPATCH( $CAPTURE, 'hash', );
                        };
                        ::DISPATCH_VAR( $s, 'STORE', ::DISPATCH( $::Str, 'new', '[ ' ) );
                        {
                            my $v;
                            $v = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$v' } ) unless defined $v;
                            BEGIN { $v = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$v' } ) }
                            for $v ( @{ ::DISPATCH( $GLOBAL::Code_prefix_58__60__64__62_, 'APPLY', ::DISPATCH( $GLOBAL::Code_prefix_58__60__64__62_, 'APPLY', $self ) )->{_value}{_array} } ) {
                                {
                                    ::DISPATCH_VAR( $s, 'STORE',
                                        ::DISPATCH( $GLOBAL::Code_infix_58__60__126__62_, 'APPLY', $s, ::DISPATCH( $GLOBAL::Code_infix_58__60__126__62_, 'APPLY', ::DISPATCH( $v, 'perl', ), ::DISPATCH( $::Str, 'new', ', ' ) ) ) )
                                }
                            }
                        };
                        return ( ::DISPATCH( $GLOBAL::Code_infix_58__60__126__62_, 'APPLY', $s, ::DISPATCH( $::Str, 'new', ' ]' ) ) );
                    },
                    signature => ::DISPATCH(
                        $::Signature,
                        "new",
                        {   invocant => ::DISPATCH( $::Signature::Item, "new", { sigil  => '$', twigil => '', name => 'self', namespace => [], } ),
                            array    => ::DISPATCH( $::Array,           "new", { _array => [] } ),
                            hash     => ::DISPATCH( $::Hash,            "new", { _hash  => {} } ),
                            return   => $::Undef,
                        }
                    ),
                }
            )
        );
        ::DISPATCH(
            ::DISPATCH( $::Array, 'HOW', ),
            'add_method',
            ::DISPATCH( $::Str, 'new', 'str' ),
            ::DISPATCH(
                $::Code, 'new',
                {   code => sub {
                        my $List__ = ::DISPATCH( $::Array, 'new', { modified => $_MODIFIED, name => '$List__' } );
                        my $self;
                        $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) unless defined $self;
                        BEGIN { $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) }
                        $self = shift;
                        my $CAPTURE;
                        $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) unless defined $CAPTURE;
                        BEGIN { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
                        ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                        do {
                            ::MODIFIED($List__);
                            $List__ = ::DISPATCH( $CAPTURE, 'array', );
                        };
                        do {
                            ::MODIFIED($Hash__);
                            $Hash__ = ::DISPATCH( $CAPTURE, 'hash', );
                        };
                        ::DISPATCH( $self, 'join', ::DISPATCH( $::Str, 'new', ' ' ) );
                    },
                    signature => ::DISPATCH(
                        $::Signature,
                        "new",
                        {   invocant => ::DISPATCH( $::Signature::Item, "new", { sigil  => '$', twigil => '', name => 'self', namespace => [], } ),
                            array    => ::DISPATCH( $::Array,           "new", { _array => [] } ),
                            hash     => ::DISPATCH( $::Hash,            "new", { _hash  => {} } ),
                            return   => $::Undef,
                        }
                    ),
                }
            )
        );
        ::DISPATCH(
            ::DISPATCH( $::Array, 'HOW', ),
            'add_method',
            ::DISPATCH( $::Str, 'new', 'true' ),
            ::DISPATCH(
                $::Code, 'new',
                {   code => sub {
                        my $List__ = ::DISPATCH( $::Array, 'new', { modified => $_MODIFIED, name => '$List__' } );
                        my $self;
                        $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) unless defined $self;
                        BEGIN { $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) }
                        $self = shift;
                        my $CAPTURE;
                        $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) unless defined $CAPTURE;
                        BEGIN { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
                        ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                        do {
                            ::MODIFIED($List__);
                            $List__ = ::DISPATCH( $CAPTURE, 'array', );
                        };
                        do {
                            ::MODIFIED($Hash__);
                            $Hash__ = ::DISPATCH( $CAPTURE, 'hash', );
                        };
                        ::DISPATCH( $GLOBAL::Code_infix_58__60__33__61__62_, 'APPLY', ::DISPATCH( $self, 'elems', ), ::DISPATCH( $::Int, 'new', ) );
                    },
                    signature => ::DISPATCH(
                        $::Signature,
                        "new",
                        {   invocant => ::DISPATCH( $::Signature::Item, "new", { sigil  => '$', twigil => '', name => 'self', namespace => [], } ),
                            array    => ::DISPATCH( $::Array,           "new", { _array => [] } ),
                            hash     => ::DISPATCH( $::Hash,            "new", { _hash  => {} } ),
                            return   => $::Undef,
                        }
                    ),
                }
            )
        );
        ::DISPATCH(
            ::DISPATCH( $::Array, 'HOW', ),
            'add_method',
            ::DISPATCH( $::Str, 'new', 'int' ),
            ::DISPATCH(
                $::Code, 'new',
                {   code => sub {
                        my $List__ = ::DISPATCH( $::Array, 'new', { modified => $_MODIFIED, name => '$List__' } );
                        my $self;
                        $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) unless defined $self;
                        BEGIN { $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) }
                        $self = shift;
                        my $CAPTURE;
                        $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) unless defined $CAPTURE;
                        BEGIN { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
                        ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                        do {
                            ::MODIFIED($List__);
                            $List__ = ::DISPATCH( $CAPTURE, 'array', );
                        };
                        do {
                            ::MODIFIED($Hash__);
                            $Hash__ = ::DISPATCH( $CAPTURE, 'hash', );
                        };
                        ::DISPATCH( $self, 'elems', );
                    },
                    signature => ::DISPATCH(
                        $::Signature,
                        "new",
                        {   invocant => ::DISPATCH( $::Signature::Item, "new", { sigil  => '$', twigil => '', name => 'self', namespace => [], } ),
                            array    => ::DISPATCH( $::Array,           "new", { _array => [] } ),
                            hash     => ::DISPATCH( $::Hash,            "new", { _hash  => {} } ),
                            return   => $::Undef,
                        }
                    ),
                }
            )
        );
        ::DISPATCH(
            ::DISPATCH( $::Array, 'HOW', ),
            'add_method',
            ::DISPATCH( $::Str, 'new', 'array' ),
            ::DISPATCH(
                $::Code, 'new',
                {   code => sub {
                        my $List__ = ::DISPATCH( $::Array, 'new', { modified => $_MODIFIED, name => '$List__' } );
                        my $self;
                        $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) unless defined $self;
                        BEGIN { $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) }
                        $self = shift;
                        my $CAPTURE;
                        $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) unless defined $CAPTURE;
                        BEGIN { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
                        ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                        do {
                            ::MODIFIED($List__);
                            $List__ = ::DISPATCH( $CAPTURE, 'array', );
                        };
                        do {
                            ::MODIFIED($Hash__);
                            $Hash__ = ::DISPATCH( $CAPTURE, 'hash', );
                        };
                        $self;
                    },
                    signature => ::DISPATCH(
                        $::Signature,
                        "new",
                        {   invocant => ::DISPATCH( $::Signature::Item, "new", { sigil  => '$', twigil => '', name => 'self', namespace => [], } ),
                            array    => ::DISPATCH( $::Array,           "new", { _array => [] } ),
                            hash     => ::DISPATCH( $::Hash,            "new", { _hash  => {} } ),
                            return   => $::Undef,
                        }
                    ),
                }
            )
        );
        ::DISPATCH(
            ::DISPATCH( $::Array, 'HOW', ),
            'add_method',
            ::DISPATCH( $::Str, 'new', 'grep' ),
            ::DISPATCH(
                $::Code, 'new',
                {   code => sub {
                        my $List_result = ::DISPATCH( $::Array, 'new', { modified => $_MODIFIED, name => '$List_result' } );
                        my $s;
                        $s = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$s' } ) unless defined $s;
                        BEGIN { $s = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$s' } ) }
                        my $List__ = ::DISPATCH( $::Array, 'new', { modified => $_MODIFIED, name => '$List__' } );
                        my $Code_test;
                        $Code_test = ::DISPATCH( $::Routine, 'new', { modified => $_MODIFIED, name => '$Code_test' } ) unless defined $Code_test;
                        BEGIN { $Code_test = ::DISPATCH( $::Routine, 'new', { modified => $_MODIFIED, name => '$Code_test' } ) }
                        $self = shift;
                        my $CAPTURE;
                        $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) unless defined $CAPTURE;
                        BEGIN { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
                        ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                        do {
                            ::MODIFIED($List__);
                            $List__ = ::DISPATCH( $CAPTURE, 'array', );
                        };
                        do {
                            ::MODIFIED($Hash__);
                            $Hash__ = ::DISPATCH( $CAPTURE, 'hash', );
                        };
                        do {
                            ::MODIFIED($Code_test);
                            $Code_test = ::DISPATCH( $List__, 'INDEX', ::DISPATCH( $::Int, 'new', 0 ) );
                        };
                        $List_result;
                        $s;
                        {
                            my $v;
                            $v = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$v' } ) unless defined $v;
                            BEGIN { $v = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$v' } ) }
                            for $v ( @{ ::DISPATCH( $GLOBAL::Code_prefix_58__60__64__62_, 'APPLY', ::DISPATCH( $GLOBAL::Code_prefix_58__60__64__62_, 'APPLY', $self ) )->{_value}{_array} } ) {
                                {
                                    do {
                                        if ( ::DISPATCH( ::DISPATCH( ::DISPATCH( $Code_test, 'APPLY', $v ), "true" ), "p5landish" ) ) {
                                            {
                                                ::DISPATCH( $List_result, 'push', $v )
                                            }
                                        }
                                        else { ::DISPATCH( $::Bit, "new", 0 ) }
                                        }
                                }
                            }
                        };
                        return ($List_result);
                    },
                    signature => ::DISPATCH(
                        $::Signature,
                        "new",
                        {   invocant => $::Undef,
                            array    => ::DISPATCH( $::Array, "new", { _array => [ ::DISPATCH( $::Signature::Item, "new", { sigil => '&', twigil => '', name => 'test', namespace => [], } ), ] } ),
                            hash   => ::DISPATCH( $::Hash, "new", { _hash => {} } ),
                            return => $::Undef,
                        }
                    ),
                }
            )
        );
        ::DISPATCH(
            ::DISPATCH( $::Array, 'HOW', ),
            'add_method',
            ::DISPATCH( $::Str, 'new', 'uniq' ),
            ::DISPATCH(
                $::Code, 'new',
                {   code => sub {
                        my $Hash_h = ::DISPATCH( $::Hash,  'new', { modified => $_MODIFIED, name => '$Hash_h' } );
                        my $List__ = ::DISPATCH( $::Array, 'new', { modified => $_MODIFIED, name => '$List__' } );
                        my $self;
                        $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) unless defined $self;
                        BEGIN { $self = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$self' } ) }
                        $self = shift;
                        my $CAPTURE;
                        $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) unless defined $CAPTURE;
                        BEGIN { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
                        ::DISPATCH_VAR( $CAPTURE, "STORE", ::CAPTURIZE( \@_ ) );
                        do {
                            ::MODIFIED($List__);
                            $List__ = ::DISPATCH( $CAPTURE, 'array', );
                        };
                        do {
                            ::MODIFIED($Hash__);
                            $Hash__ = ::DISPATCH( $CAPTURE, 'hash', );
                        };
                        $Hash_h;
                        {
                            my $v;
                            $v = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$v' } ) unless defined $v;
                            BEGIN { $v = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$v' } ) }
                            for $v ( @{ ::DISPATCH( $GLOBAL::Code_prefix_58__60__64__62_, 'APPLY', ::DISPATCH( $GLOBAL::Code_prefix_58__60__64__62_, 'APPLY', $self ) )->{_value}{_array} } ) {
                                {
                                    ::DISPATCH_VAR( ::DISPATCH( $Hash_h, 'LOOKUP', $v ), 'STORE', ::DISPATCH( $::Int, 'new', 1 ) )
                                }
                            }
                        };
                        ::DISPATCH( $Hash_h, 'keys', );
                    },
                    signature => ::DISPATCH(
                        $::Signature,
                        "new",
                        {   invocant => ::DISPATCH( $::Signature::Item, "new", { sigil  => '$', twigil => '', name => 'self', namespace => [], } ),
                            array    => ::DISPATCH( $::Array,           "new", { _array => [] } ),
                            hash     => ::DISPATCH( $::Hash,            "new", { _hash  => {} } ),
                            return   => $::Undef,
                        }
                    ),
                }
            )
            )
    };
    1
}
