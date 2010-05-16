use strict;
use warnings;
use Test::More;

use Moose::Util::TypeConstraints;
use MooseX::Types::Moose ':all';
use MooseX::Types::Structured ':all';

use MooseX::Types::Meta ':all';

sub test {
    my ($name, $code) = @_;
    subtest $name => sub {
        $code->();
        done_testing;
    };
}

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

test TypeConstraint => sub {
    ok(TypeConstraint->check($_)) for TypeConstraint, Int;
    ok(!TypeConstraint->check($_)) for \42, 'Moose::Meta::TypeConstraint';
};

test Class => sub {
    ok(Class->check($_)) for (
        MooseX::Types::Meta->meta,
        TestClass->meta,
        Moose::Meta::Class->meta,
    );

    ok(!Class->check($_)) for 42, TestRole->meta;
};

test Role => sub {
    ok(Role->check($_)) for TestRole->meta;
    ok(!Role->check($_)) for TestClass->meta, 13;
};

test Attribute => sub {
    ok(Attribute->check($_)) for (
        TestClass->meta->get_attribute('attr'),
        Moose::Meta::Class->meta->get_attribute('constructor_class'),
    );

    ok(!Attribute->check($_)) for (
        TestRole->meta->get_attribute('attr'),
        \42,
    );
};

test RoleAttribute => sub {
    ok(RoleAttribute->check($_)) for (
        TestRole->meta->get_attribute('attr'),
    );

    ok(!RoleAttribute->check($_)) for (
        TestClass->meta->get_attribute('attr'),
        Moose::Meta::Class->meta->get_attribute('constructor_class'),
        TestClass->meta,
    );
};

test Method => sub {
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
};

test TypeCoercion => sub {
    my $tc = subtype as Int;
    coerce $tc, from Str, via { 0 + $_ };

    ok(TypeCoercion->check($_)) for $tc->coercion;
    ok(!TypeCoercion->check($_)) for $tc, Str, 42;
};

test StructuredTypeConstraint => sub {
    ok(StructuredTypeConstraint->check($_)) for (
        Dict,
        Dict[],
        Dict[foo => Int],
        Map,
        Map[],
        Map[Int, Str],
        Tuple,
        Tuple[],
        Tuple[Int, Int],
        (subtype as Dict[]),
    );

    ok(!StructuredTypeConstraint->check($_)) for (
        ArrayRef,
        ArrayRef[Dict[]],
    );
};

test StructuredTypeCoercion => sub {
    my $tc = subtype as Dict[];
    coerce $tc, from Undef, via { +{} };

    ok(StructuredTypeCoercion->check($_)) for $tc->coercion;
    ok(!StructuredTypeCoercion->check($_)) for $tc, Str, 42;
};

test TypeEquals => sub {
    ok((TypeEquals[Num])->check($_)) for Num;
    ok(!(TypeEquals[Num])->check($_)) for Int, Str;
};

test SubtypeOf => sub {
    ok((SubtypeOf[Str])->check($_)) for Num, Int, ClassName, RoleName;
    ok(!(SubtypeOf[Str])->check($_)) for Str, Value, Ref, Defined, Any, Item;
};

test TypeOf => sub {
    ok((TypeOf[Str])->check($_)) for Str, Num, Int, ClassName, RoleName;
    ok(!(TypeOf[Str])->check($_)) for Value, Ref, Defined, Any, Item;
};

test 'MooseX::Role::Parameterized' => sub {
    plan skip_all => 'MooseX::Role::Parameterized required'
        unless eval { require MooseX::Role::Parameterized; 1 };

    eval <<'EOR' or fail;
package TestRole::Parameterized;
use MooseX::Role::Parameterized;
role {
    sub foo { }
};
1;
EOR

    test ParameterizableRole => sub {
        ok(ParameterizableRole->check($_)) for (
            TestRole::Parameterized->meta,
        );

        ok(!ParameterizableRole->check($_)) for (
            TestRole->meta,
        );
    };

    test ParameterizedRole => sub {
        ok(ParameterizedRole->check($_)) for (
            TestRole::Parameterized->meta->generate_role(
                consumer   => Moose::Meta::Class->create_anon_class,
                parameters => {},
            ),
        );

        ok(!ParameterizedRole->check($_)) for (
            TestRole->meta,
        );
    };
};

# TypeEquals
# TypeOf
# SubtypeOf

done_testing;
