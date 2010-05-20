package MooseX::Types::Meta;

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

class_type TypeConstraint, { class => 'Moose::Meta::TypeConstraint'  };
class_type TypeCoercion,   { class => 'Moose::Meta::TypeCoercion'    };
class_type Attribute,      { class => 'Class::MOP::Attribute'        };
class_type RoleAttribute,  { class => 'Moose::Meta::Role::Attribute' };
class_type Method,         { class => 'Class::MOP::Method'           };
class_type Class,          { class => 'Class::MOP::Class'            };
class_type Role,           { class => 'Moose::Meta::Role'            };

class_type StructuredTypeConstraint, {
    class => 'MooseX::Meta::TypeConstraint::Structured',
};

class_type StructuredTypeCoercion, {
    class => 'MooseX::Meta::TypeCoercion::Structured',
};

class_type ParameterizableRole, {
    class => 'MooseX::Role::Parameterized::Meta::Role::Parameterizable',
};

class_type ParameterizedRole, {
    class => 'MooseX::Role::Parameterized::Meta::Role::Parameterized',
};

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
