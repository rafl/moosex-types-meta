package MooseX::Types::Meta;
# ABSTRACT: Moose types to check against Moose's meta objects

use Moose 1.05 ();
use MooseX::Types -declare => [qw(
    TypeConstraint
    TypeCoercion
    Attribute
    RoleAttribute
    Method
    Class
    Role

    TypeEquals
    TypeOf
    SubtypeOf

    StructuredTypeConstraint
    StructuredTypeCoercion

    ParameterizableRole
    ParameterizedRole

)];
use Carp qw(confess);
use namespace::clean;

# TODO: ParameterizedType{Constraint,Coercion} ?
#       {Duck,Class,Enum,Parameterizable,Parameterized,Role,Union}TypeConstraint?

=type TypeConstraint

A L<Moose::Meta::TypeConstraint>.

=cut

class_type TypeConstraint, { class => 'Moose::Meta::TypeConstraint' };

=type TypeCoercion

A L<Moose::Meta::TypeCoercion>.

=cut

class_type TypeCoercion,   { class => 'Moose::Meta::TypeCoercion' };

=type Attribute

A L<Class::MOP::Attribute>.

=cut

class_type Attribute,      { class => 'Class::MOP::Attribute' };

=type RoleAttribute

A L<Moose::Meta::Role::Attribute>.

=cut

class_type RoleAttribute,  { class => 'Moose::Meta::Role::Attribute' };

=type Method

A L<Class::MOP::Method>.

=cut

class_type Method,         { class => 'Class::MOP::Method' };

=type Class

A L<Class::MOP::Class>.

=cut

class_type Class,          { class => 'Class::MOP::Class' };

=type Role

A L<Moose::Meta::Role>.

=cut

class_type Role,           { class => 'Moose::Meta::Role' };

=type StructuredTypeConstraint

A L<MooseX::Meta::TypeConstraint::Structured>.

=cut

class_type StructuredTypeConstraint, {
    class => 'MooseX::Meta::TypeConstraint::Structured',
};

=type StructuredTypeCoercion

A L<MooseX::Meta::TypeCoercion::Structured>.

=cut

class_type StructuredTypeCoercion, {
    class => 'MooseX::Meta::TypeCoercion::Structured',
};

=type ParameterizableRole

A L<MooseX::Role::Parameterized::Meta::Role::Parameterizable>.

=cut

class_type ParameterizableRole, {
    class => 'MooseX::Role::Parameterized::Meta::Role::Parameterizable',
};

=type ParameterizedRole

A L<MooseX::Role::Parameterized::Meta::Role::Parameterized>.

=cut

class_type ParameterizedRole, {
    class => 'MooseX::Role::Parameterized::Meta::Role::Parameterized',
};

=type TypeEquals[`x]

A L<Moose::Meta::TypeConstraint>, that's equal to the type constraint
C<x>.

=type TypeOf[`x]

A L<Moose::Meta::TypeConstraint>, that's either equal to or a subtype
of the type constraint C<x>.

=type SubtypeOf[`x]

A L<Moose::Meta::TypeConstraint>, that's a subtype of the type
constraint C<x>.

=cut

for my $t (
    [ 'TypeEquals', 'equals'        ],
    [ 'TypeOf',     'is_a_type_of'  ],
    [ 'SubtypeOf',  'is_subtype_of' ],
) {
    my ($name, $method) = @{ $t };
    my $tc = Moose::Meta::TypeConstraint::Parameterizable->new(
        name                 => join(q{::} => __PACKAGE__, $name),
        package_defined_in   => __PACKAGE__,
        parent               => TypeConstraint,
        constraint_generator => sub {
            my ($type_parameter) = @_;
            confess "type parameter $type_parameter for $name is not a type constraint"
                unless TypeConstraint->check($type_parameter);
            return sub {
                my ($val) = @_;
                return $val->$method($type_parameter);
            };
        },
    );

    Moose::Util::TypeConstraints::register_type_constraint($tc);
    Moose::Util::TypeConstraints::add_parameterizable_type($tc);
}

__PACKAGE__->meta->make_immutable;

1;
