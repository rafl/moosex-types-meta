use strict;
use warnings;
use Test::More;

use MooseX::Types::Moose qw(Int);

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
{
    local $TODO = 'figure out if Attribute should handle both metaclass and -role attrs, or if there should be another one for roles';
    # also don't ever use "ClassAttribute" for anything but MooseX::ClassAttribute stuff

    ok(Attribute->check($_)) for (
        (map { $_->meta->get_attribute('attr') } qw(TestClass TestRole)),
        Moose::Meta::Class->meta->get_attribute('constructor_class'),
    );
}

ok(!Attribute->check($_)) for TestClass->meta, \23;


# Method
ok(Method->check($_)) for (
    (map { TestClass->meta->get_method($_) } qw(foo bar baz attr)),
    (map { TestRole->meta->get_method($_)  } qw(foo attr)),
);


# TypeCoercion
# StructuredTypeConstraint
# StructuredTypeCoercion
# ParameterizableRole
# ParameterizedRole

# TypeEquals
# TypeOf
# SubtypeOf

done_testing;
