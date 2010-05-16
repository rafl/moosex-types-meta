use strict;
use warnings;
use Test::More;

use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(Int Str);

use MooseX::Types::Meta ':all';

# TypeConstraint
ok(TypeConstraint->check($_)) for TypeConstraint, Int;
ok(!TypeConstraint->check($_)) for \42, 'Moose::Meta::TypeConstraint';


# Class
{
    package TestClass;
    use Moose;
    use namespace::autoclean;

    has attr => (
        is => 'ro',
    );

    sub foo { 42 }

    __PACKAGE__->meta->add_method(bar => sub { 23 });

    sub baz { 13 }
    before baz => sub {};

    __PACKAGE__->meta->make_immutable;
}

{
    package TestRole;
    use Moose::Role;
    use namespace::autoclean;

    has attr => (
        is => 'ro',
    );

    sub foo { }
}

ok(Class->check($_)) for (
    MooseX::Types::Meta->meta,
    TestClass->meta,
    Moose::Meta::Class->meta,
);

ok(!Class->check($_)) for 42, TestRole->meta;


# Role
ok(Role->check($_)) for TestRole->meta;
ok(!Role->check($_)) for TestClass->meta, 13;


# Attribute
ok(Attribute->check($_)) for (
    TestClass->meta->get_attribute('attr'),
    Moose::Meta::Class->meta->get_attribute('constructor_class'),
);

ok(!Attribute->check($_)) for (
    TestRole->meta->get_attribute('attr'),
    \42,
);

ok(!Attribute->check($_)) for TestClass->meta, \23;


# RoleAttribute
ok(RoleAttribute->check($_)) for (
    TestRole->meta->get_attribute('attr'),
);

ok(!RoleAttribute->check($_)) for (
    TestClass->meta->get_attribute('attr'),
    Moose::Meta::Class->meta->get_attribute('constructor_class'),
    TestClass->meta,
);

# Method
ok(Method->check($_)) for (
    (map { TestClass->meta->get_method($_) } qw(foo bar baz attr)),
    (map { TestRole->meta->get_method($_)  } qw(foo attr)),
    Moose::Meta::Class->meta->get_method('create'),
    Moose::Meta::Class->meta->get_method('new'),
);

ok(!Method->check($_)) for (
    TestClass->meta->get_attribute('attr'),
    TestClass->meta,
);


# TypeCoercion
my $tc = subtype as Int;
coerce $tc, from Str, via { 0 + $_ };

ok(TypeCoercion->check($_)) for $tc->coercion;
ok(!TypeCoercion->check($_)) for $tc, Str, 42;

# StructuredTypeConstraint
# StructuredTypeCoercion
# ParameterizableRole
# ParameterizedRole

# TypeEquals
# TypeOf
# SubtypeOf

done_testing;
