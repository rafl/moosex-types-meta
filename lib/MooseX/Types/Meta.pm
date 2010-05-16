package MooseX::Types::Meta;

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

__PACKAGE__->meta->make_immutable;

1;
