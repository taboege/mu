use v6;

use Test;

plan 19;

# L<S06/The C<callframe> and C<caller> functions>

# caller.subname
sub a_sub { b_sub() }
sub b_sub { try { caller.subname } }
#?pugs todo "feature"
is ~a_sub(), "a_sub", "caller.sub works";

# caller.file
#?pugs todo "feature"
ok index(~(try { caller.file }), "caller") >= 0, "caller.file works";

# caller.line (XXX: make sure to edit the expected line number!)
#?pugs 2 todo "feature"
sub call_line { caller.line };
is call_line(), 22, "caller.line works";

# pugs: caller exposes a bug in the MMD mechanism where directly using autogenerated
# accessors on an object returned by a factory, rather than storing the object
# in an intermediate variable, works only when you chain methods with an
# explicit () between them: caller().subname - ok; caller.subname - error.

sub try_it {
    my ($code, $expected, $desc) = @_;
    is($code(), $expected, $desc);
}
sub try_it_caller { try_it(@_) }                                # (line 33.)
class A { method try_it_caller_A { &Main::try_it_caller(@_) } }
sub try_it_caller_caller { A.try_it_caller_A(@_) }
class B { method try_it_caller_B { &Main::try_it_caller_caller(@_) } }

sub chain { B.try_it_caller_B(@_) }

# pugs: must use parentheses after caller

# basic tests of caller object
chain({ WHAT caller() },     "Control::Caller", "caller object type");
chain({ caller().package }, "Main", "caller package");
chain({ caller().file },    $?FILE, "caller filename");
chain({ caller().line },    "33", "caller line");
chain({ caller().subname }, "&Main::try_it_caller", "caller subname");
chain({ caller().subtype }, "SubRoutine", "caller subtype"); # specme
chain({ caller().sub },     &try_it_caller, "caller sub (code)");

# select by code type
chain({ caller(Any).subname },    "&Main::try_it_caller", "code type - Any");
chain({ caller("Any").subname },  "&Main::try_it_caller", "code type - Any (string)");
chain({ caller(Method).subname }, "&A::try_it_caller_A", "code type - Method");
chain({ caller("Moose") },         Mu, "code type - not found");

# :skip
chain({ caller(:skip<1>).subname }, "&A::try_it_caller_A", ":skip<1>");
chain({ caller(:skip<128>) },       Mu, ":skip<128> - not found");

# type + :skip
chain({ caller(Sub, :skip<1>).subname }, "&Main::try_it_caller_caller", "Sub, :skip<1>");
chain({ caller(Sub, :skip<2>).subname }, "&Main::chain", "Sub, :skip<2>");
chain({ caller(Method, :skip<1>).subname }, "&B::try_it_caller_B", "Method, :skip<1>");

# WRITEME: label tests


# vim: ft=perl6
