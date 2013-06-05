####################################################################
#
#    This file was generated using Parse::Yapp version 1.05.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package typedoc;
use vars qw ( @ISA );
use strict;

@ISA= qw ( Parse::Yapp::Driver );
use Parse::Yapp::Driver;

#line 4 "typedoc.yp"

    use Devel::StackTrace;
    use Bio::KBase::KIDL::KBT;
    use Data::Dumper;
    use File::Spec;

our @valid_authentication_values = qw(required optional none);    
our %valid_authentication_value = map { $_ => 1 } @valid_authentication_values;

our %builtin_types = ('int' => Bio::KBase::KIDL::KBT::Scalar->new(scalar_type => 'int'),
		      'string' => Bio::KBase::KIDL::KBT::Scalar->new(scalar_type => 'string'),
		      'float' => Bio::KBase::KIDL::KBT::Scalar->new(scalar_type => 'float'),
    );

our $auth_default = 'none';



sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.05',
                                  yystates =>
[
	{#State 0
		DEFAULT => -2,
		GOTOS => {
			'module_list' => 1,
			'start' => 2
		}
	},
	{#State 1
		ACTIONS => {
			'' => -1
		},
		DEFAULT => -8,
		GOTOS => {
			'module_opts' => 3,
			'module' => 4
		}
	},
	{#State 2
		ACTIONS => {
			'' => 5
		}
	},
	{#State 3
		ACTIONS => {
			'MODULE' => 6,
			'module_opt' => 7
		}
	},
	{#State 4
		DEFAULT => -3
	},
	{#State 5
		DEFAULT => 0
	},
	{#State 6
		DEFAULT => -4,
		GOTOS => {
			'@1-2' => 8
		}
	},
	{#State 7
		DEFAULT => -9
	},
	{#State 8
		ACTIONS => {
			'IDENT' => 9
		},
		GOTOS => {
			'mod_name_def' => 10
		}
	},
	{#State 9
		ACTIONS => {
			":" => 11
		},
		DEFAULT => -6
	},
	{#State 10
		ACTIONS => {
			"{" => 12
		}
	},
	{#State 11
		ACTIONS => {
			'IDENT' => 13
		}
	},
	{#State 12
		DEFAULT => -10,
		GOTOS => {
			'module_components' => 14
		}
	},
	{#State 13
		DEFAULT => -7
	},
	{#State 14
		ACTIONS => {
			"}" => 16,
			'AUTHENTICATION' => 15,
			'ASYNC' => 22,
			"use" => 23,
			'DOC_COMMENT' => 18,
			'TYPEDEF' => 24
		},
		DEFAULT => -27,
		GOTOS => {
			'async_flag' => 21,
			'module_component' => 17,
			'funcdef' => 20,
			'auth_type' => 19,
			'typedef' => 25,
			'module_component_with_doc' => 26
		}
	},
	{#State 15
		ACTIONS => {
			'IDENT' => 27
		}
	},
	{#State 16
		ACTIONS => {
			";" => 28
		}
	},
	{#State 17
		DEFAULT => -12
	},
	{#State 18
		ACTIONS => {
			'AUTHENTICATION' => 15,
			'ASYNC' => 22,
			"use" => 23,
			'TYPEDEF' => 24
		},
		DEFAULT => -27,
		GOTOS => {
			'async_flag' => 21,
			'module_component' => 29,
			'funcdef' => 20,
			'auth_type' => 19,
			'typedef' => 25
		}
	},
	{#State 19
		ACTIONS => {
			";" => 30
		}
	},
	{#State 20
		DEFAULT => -15
	},
	{#State 21
		ACTIONS => {
			'FUNCDEF' => 31
		}
	},
	{#State 22
		DEFAULT => -28
	},
	{#State 23
		ACTIONS => {
			"module" => 32
		}
	},
	{#State 24
		ACTIONS => {
			'TYPENAME' => 33,
			'TUPLE' => 35,
			'LIST' => 39,
			'IDENT' => 36,
			'MAPPING' => 37,
			'STRUCTURE' => 42
		},
		GOTOS => {
			'mapping' => 34,
			'structure' => 38,
			'type' => 41,
			'tuple' => 40,
			'list' => 43
		}
	},
	{#State 25
		DEFAULT => -14
	},
	{#State 26
		DEFAULT => -11
	},
	{#State 27
		DEFAULT => -18
	},
	{#State 28
		DEFAULT => -5
	},
	{#State 29
		DEFAULT => -13
	},
	{#State 30
		DEFAULT => -17
	},
	{#State 31
		ACTIONS => {
			'TYPENAME' => 33,
			'TUPLE' => 35,
			'LIST' => 39,
			'IDENT' => 44,
			'MAPPING' => 37,
			'STRUCTURE' => 42
		},
		GOTOS => {
			'mapping' => 34,
			'structure' => 38,
			'type' => 45,
			'tuple' => 40,
			'list' => 43
		}
	},
	{#State 32
		ACTIONS => {
			'ident' => 46
		}
	},
	{#State 33
		DEFAULT => -34
	},
	{#State 34
		DEFAULT => -35
	},
	{#State 35
		ACTIONS => {
			"<" => 47
		}
	},
	{#State 36
		DEFAULT => -39
	},
	{#State 37
		ACTIONS => {
			"<" => 48
		}
	},
	{#State 38
		DEFAULT => -36
	},
	{#State 39
		ACTIONS => {
			"<" => 49
		}
	},
	{#State 40
		DEFAULT => -38
	},
	{#State 41
		ACTIONS => {
			'IDENT' => 50
		}
	},
	{#State 42
		ACTIONS => {
			"{" => 51
		}
	},
	{#State 43
		DEFAULT => -37
	},
	{#State 44
		ACTIONS => {
			'IDENT' => -39
		},
		DEFAULT => -21,
		GOTOS => {
			'@3-3' => 52
		}
	},
	{#State 45
		ACTIONS => {
			'IDENT' => 53
		}
	},
	{#State 46
		ACTIONS => {
			";" => 54
		}
	},
	{#State 47
		ACTIONS => {
			'TYPENAME' => 33,
			'TUPLE' => 35,
			'LIST' => 39,
			'IDENT' => 36,
			'MAPPING' => 37,
			'STRUCTURE' => 42
		},
		GOTOS => {
			'mapping' => 34,
			'tuple_types' => 55,
			'structure' => 38,
			'tuple_type' => 56,
			'tuple' => 40,
			'type' => 57,
			'list' => 43
		}
	},
	{#State 48
		ACTIONS => {
			'TYPENAME' => 33,
			'TUPLE' => 35,
			'LIST' => 39,
			'IDENT' => 36,
			'MAPPING' => 37,
			'STRUCTURE' => 42
		},
		GOTOS => {
			'mapping' => 34,
			'tuple_type' => 58,
			'structure' => 38,
			'tuple' => 40,
			'type' => 57,
			'list' => 43
		}
	},
	{#State 49
		ACTIONS => {
			'TYPENAME' => 33,
			'TUPLE' => 35,
			'LIST' => 39,
			'IDENT' => 36,
			'MAPPING' => 37,
			'STRUCTURE' => 42
		},
		GOTOS => {
			'mapping' => 34,
			'structure' => 38,
			'type' => 59,
			'tuple' => 40,
			'list' => 43
		}
	},
	{#State 50
		DEFAULT => -19,
		GOTOS => {
			'@2-3' => 60
		}
	},
	{#State 51
		ACTIONS => {
			'TYPENAME' => 33,
			'TUPLE' => 35,
			'LIST' => 39,
			'IDENT' => 36,
			'MAPPING' => 37,
			'STRUCTURE' => 42
		},
		GOTOS => {
			'mapping' => 34,
			'structure' => 38,
			'tuple' => 40,
			'type' => 63,
			'struct_items' => 62,
			'struct_item' => 61,
			'list' => 43
		}
	},
	{#State 52
		ACTIONS => {
			"(" => 64
		}
	},
	{#State 53
		DEFAULT => -23,
		GOTOS => {
			'@4-4' => 65
		}
	},
	{#State 54
		DEFAULT => -16
	},
	{#State 55
		ACTIONS => {
			"," => 66,
			">" => 67
		}
	},
	{#State 56
		DEFAULT => -48
	},
	{#State 57
		ACTIONS => {
			'IDENT' => 68
		},
		DEFAULT => -50
	},
	{#State 58
		ACTIONS => {
			"," => 69
		}
	},
	{#State 59
		ACTIONS => {
			">" => 70
		}
	},
	{#State 60
		ACTIONS => {
			";" => 71
		}
	},
	{#State 61
		DEFAULT => -42
	},
	{#State 62
		ACTIONS => {
			"}" => 72,
			'TYPENAME' => 33,
			'TUPLE' => 35,
			'LIST' => 39,
			'IDENT' => 36,
			'MAPPING' => 37,
			'STRUCTURE' => 42
		},
		GOTOS => {
			'mapping' => 34,
			'structure' => 38,
			'tuple' => 40,
			'type' => 63,
			'struct_item' => 73,
			'list' => 43
		}
	},
	{#State 63
		ACTIONS => {
			'IDENT' => 74
		}
	},
	{#State 64
		ACTIONS => {
			'TYPENAME' => 33,
			'TUPLE' => 35,
			'IDENT' => 36,
			'MAPPING' => 37,
			'LIST' => 39,
			'STRUCTURE' => 42
		},
		DEFAULT => -29,
		GOTOS => {
			'funcdef_param' => 76,
			'mapping' => 34,
			'structure' => 38,
			'funcdef_params' => 75,
			'type' => 77,
			'tuple' => 40,
			'list' => 43
		}
	},
	{#State 65
		ACTIONS => {
			"(" => 78
		}
	},
	{#State 66
		ACTIONS => {
			'TYPENAME' => 33,
			'TUPLE' => 35,
			'LIST' => 39,
			'IDENT' => 36,
			'MAPPING' => 37,
			'STRUCTURE' => 42
		},
		GOTOS => {
			'mapping' => 34,
			'tuple_type' => 79,
			'structure' => 38,
			'tuple' => 40,
			'type' => 57,
			'list' => 43
		}
	},
	{#State 67
		DEFAULT => -47
	},
	{#State 68
		DEFAULT => -51
	},
	{#State 69
		ACTIONS => {
			'TYPENAME' => 33,
			'TUPLE' => 35,
			'LIST' => 39,
			'IDENT' => 36,
			'MAPPING' => 37,
			'STRUCTURE' => 42
		},
		GOTOS => {
			'mapping' => 34,
			'tuple_type' => 80,
			'structure' => 38,
			'tuple' => 40,
			'type' => 57,
			'list' => 43
		}
	},
	{#State 70
		DEFAULT => -46
	},
	{#State 71
		DEFAULT => -20
	},
	{#State 72
		DEFAULT => -41
	},
	{#State 73
		DEFAULT => -43
	},
	{#State 74
		ACTIONS => {
			'NULLABLE' => 82,
			";" => 81
		}
	},
	{#State 75
		ACTIONS => {
			"," => 83,
			")" => 84
		}
	},
	{#State 76
		DEFAULT => -30
	},
	{#State 77
		ACTIONS => {
			'IDENT' => 85
		},
		DEFAULT => -33
	},
	{#State 78
		ACTIONS => {
			'TYPENAME' => 33,
			'TUPLE' => 35,
			'IDENT' => 36,
			'MAPPING' => 37,
			'LIST' => 39,
			'STRUCTURE' => 42
		},
		DEFAULT => -29,
		GOTOS => {
			'funcdef_param' => 76,
			'mapping' => 34,
			'structure' => 38,
			'funcdef_params' => 86,
			'type' => 77,
			'tuple' => 40,
			'list' => 43
		}
	},
	{#State 79
		DEFAULT => -49
	},
	{#State 80
		ACTIONS => {
			">" => 87
		}
	},
	{#State 81
		DEFAULT => -44
	},
	{#State 82
		ACTIONS => {
			";" => 88
		}
	},
	{#State 83
		ACTIONS => {
			'TYPENAME' => 33,
			'TUPLE' => 35,
			'LIST' => 39,
			'IDENT' => 36,
			'MAPPING' => 37,
			'STRUCTURE' => 42
		},
		GOTOS => {
			'funcdef_param' => 89,
			'mapping' => 34,
			'structure' => 38,
			'type' => 77,
			'tuple' => 40,
			'list' => 43
		}
	},
	{#State 84
		ACTIONS => {
			'RETURNS' => 90
		}
	},
	{#State 85
		DEFAULT => -32
	},
	{#State 86
		ACTIONS => {
			"," => 83,
			")" => 91
		}
	},
	{#State 87
		DEFAULT => -40
	},
	{#State 88
		DEFAULT => -45
	},
	{#State 89
		DEFAULT => -31
	},
	{#State 90
		ACTIONS => {
			"(" => 92
		}
	},
	{#State 91
		ACTIONS => {
			'AUTHENTICATION' => 15
		},
		DEFAULT => -25,
		GOTOS => {
			'auth_param' => 94,
			'auth_type' => 93
		}
	},
	{#State 92
		ACTIONS => {
			'TYPENAME' => 33,
			'TUPLE' => 35,
			'IDENT' => 36,
			'MAPPING' => 37,
			'LIST' => 39,
			'STRUCTURE' => 42
		},
		DEFAULT => -29,
		GOTOS => {
			'funcdef_param' => 76,
			'mapping' => 34,
			'structure' => 38,
			'funcdef_params' => 95,
			'type' => 77,
			'tuple' => 40,
			'list' => 43
		}
	},
	{#State 93
		DEFAULT => -26
	},
	{#State 94
		ACTIONS => {
			";" => 96
		}
	},
	{#State 95
		ACTIONS => {
			"," => 83,
			")" => 97
		}
	},
	{#State 96
		DEFAULT => -24
	},
	{#State 97
		ACTIONS => {
			'AUTHENTICATION' => 15
		},
		DEFAULT => -25,
		GOTOS => {
			'auth_param' => 98,
			'auth_type' => 93
		}
	},
	{#State 98
		ACTIONS => {
			";" => 99
		}
	},
	{#State 99
		DEFAULT => -22
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'start', 1, undef
	],
	[#Rule 2
		 'module_list', 0,
sub
#line 28 "typedoc.yp"
{ [] }
	],
	[#Rule 3
		 'module_list', 2,
sub
#line 29 "typedoc.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 4
		 '@1-2', 0,
sub
#line 32 "typedoc.yp"
{ $_[0]->get_comment() }
	],
	[#Rule 5
		 'module', 8,
sub
#line 32 "typedoc.yp"
{
    Bio::KBase::KIDL::KBT::DefineModule->new(options => $_[1],
			   @{$_[4]},
			   module_components => $_[6],
		           comment => $_[3]);
    }
	],
	[#Rule 6
		 'mod_name_def', 1,
sub
#line 40 "typedoc.yp"
{ [ module_name => $_[1], service_name => $_[1] ] }
	],
	[#Rule 7
		 'mod_name_def', 3,
sub
#line 41 "typedoc.yp"
{ [ module_name => $_[3], service_name => $_[1] ] }
	],
	[#Rule 8
		 'module_opts', 0,
sub
#line 44 "typedoc.yp"
{ [] }
	],
	[#Rule 9
		 'module_opts', 2,
sub
#line 45 "typedoc.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 10
		 'module_components', 0,
sub
#line 48 "typedoc.yp"
{ [] }
	],
	[#Rule 11
		 'module_components', 2,
sub
#line 49 "typedoc.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 12
		 'module_component_with_doc', 1, undef
	],
	[#Rule 13
		 'module_component_with_doc', 2,
sub
#line 54 "typedoc.yp"
{ $_[2]->comment($_[1]); $_[2] }
	],
	[#Rule 14
		 'module_component', 1, undef
	],
	[#Rule 15
		 'module_component', 1, undef
	],
	[#Rule 16
		 'module_component', 4, undef
	],
	[#Rule 17
		 'module_component', 2,
sub
#line 61 "typedoc.yp"
{ $auth_default = $_[1]; 'auth_default' . $_[1] }
	],
	[#Rule 18
		 'auth_type', 2,
sub
#line 64 "typedoc.yp"
{ 
			       if ($valid_authentication_value{$_[2]}) 
			       {
				   $_[2];
			       }
			       else
			       {
				   $_[0]->emit_error("Invalid authentication type '" . $_[2] . "'. Valid types are " . join(" ", map { "'$_'" } @valid_authentication_values));
				   "none";
			       }
			   }
	],
	[#Rule 19
		 '@2-3', 0,
sub
#line 77 "typedoc.yp"
{ $_[0]->get_comment() }
	],
	[#Rule 20
		 'typedef', 5,
sub
#line 77 "typedoc.yp"
{ $_[0]->define_type($_[2], $_[3], $_[4]); }
	],
	[#Rule 21
		 '@3-3', 0,
sub
#line 80 "typedoc.yp"
{ $_[0]->get_comment() }
	],
	[#Rule 22
		 'funcdef', 13,
sub
#line 81 "typedoc.yp"
{ Bio::KBase::KIDL::KBT::Funcdef->new(return_type => $_[10], name => $_[3], parameters => $_[6],
			      comment => $_[4], async => $_[1], authentication => $_[12] ); }
	],
	[#Rule 23
		 '@4-4', 0,
sub
#line 83 "typedoc.yp"
{ $_[0]->get_comment() }
	],
	[#Rule 24
		 'funcdef', 10,
sub
#line 84 "typedoc.yp"
{ Bio::KBase::KIDL::KBT::Funcdef->new(return_type => [$_[3]], name => $_[4], parameters => $_[7],
			      comment => $_[5], async => $_[1], authentication => $_[9]); }
	],
	[#Rule 25
		 'auth_param', 0,
sub
#line 88 "typedoc.yp"
{ $auth_default }
	],
	[#Rule 26
		 'auth_param', 1, undef
	],
	[#Rule 27
		 'async_flag', 0,
sub
#line 92 "typedoc.yp"
{ 0 }
	],
	[#Rule 28
		 'async_flag', 1,
sub
#line 93 "typedoc.yp"
{ 1 }
	],
	[#Rule 29
		 'funcdef_params', 0,
sub
#line 96 "typedoc.yp"
{ [] }
	],
	[#Rule 30
		 'funcdef_params', 1,
sub
#line 97 "typedoc.yp"
{ [ $_[1] ] }
	],
	[#Rule 31
		 'funcdef_params', 3,
sub
#line 98 "typedoc.yp"
{ [ @{$_[1]}, $_[3] ] }
	],
	[#Rule 32
		 'funcdef_param', 2,
sub
#line 101 "typedoc.yp"
{ { type => $_[1], name => $_[2] } }
	],
	[#Rule 33
		 'funcdef_param', 1,
sub
#line 102 "typedoc.yp"
{ { type => $_[1] } }
	],
	[#Rule 34
		 'type', 1, undef
	],
	[#Rule 35
		 'type', 1, undef
	],
	[#Rule 36
		 'type', 1, undef
	],
	[#Rule 37
		 'type', 1, undef
	],
	[#Rule 38
		 'type', 1, undef
	],
	[#Rule 39
		 'type', 1,
sub
#line 111 "typedoc.yp"
{ my $type = $_[0]->lookup_type($_[1]);
			if (!defined($type))
			{
			    $_[0]->emit_error("Attempt to use undefined type '$_[1]'");
			}
			$type }
	],
	[#Rule 40
		 'mapping', 6,
sub
#line 119 "typedoc.yp"
{ Bio::KBase::KIDL::KBT::Mapping->new(key_type => $_[3]->[0], value_type=> $_[5]->[0]); }
	],
	[#Rule 41
		 'structure', 4,
sub
#line 122 "typedoc.yp"
{ Bio::KBase::KIDL::KBT::Struct->new(items => $_[3]); }
	],
	[#Rule 42
		 'struct_items', 1,
sub
#line 125 "typedoc.yp"
{ [$_[1]] }
	],
	[#Rule 43
		 'struct_items', 2,
sub
#line 126 "typedoc.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 44
		 'struct_item', 3,
sub
#line 129 "typedoc.yp"
{ Bio::KBase::KIDL::KBT::StructItem->new(item_type => $_[1], name => $_[2], nullable => 0); }
	],
	[#Rule 45
		 'struct_item', 4,
sub
#line 130 "typedoc.yp"
{ Bio::KBase::KIDL::KBT::StructItem->new(item_type => $_[1], name => $_[2], nullable => 1); }
	],
	[#Rule 46
		 'list', 4,
sub
#line 133 "typedoc.yp"
{ Bio::KBase::KIDL::KBT::List->new(element_type => $_[3]); }
	],
	[#Rule 47
		 'tuple', 4,
sub
#line 136 "typedoc.yp"
{ Bio::KBase::KIDL::KBT::Tuple->new(element_types => [ map { $_->[0] } @{$_[3]}],
							    element_names => [ map { $_->[1] } @{$_[3]}] ); }
	],
	[#Rule 48
		 'tuple_types', 1,
sub
#line 140 "typedoc.yp"
{ [ $_[1] ] }
	],
	[#Rule 49
		 'tuple_types', 3,
sub
#line 141 "typedoc.yp"
{ [ @{$_[1]}, $_[3] ] }
	],
	[#Rule 50
		 'tuple_type', 1,
sub
#line 144 "typedoc.yp"
{ [ $_[1], undef ] }
	],
	[#Rule 51
		 'tuple_type', 2,
sub
#line 145 "typedoc.yp"
{ [ $_[1], $_[2] ] }
	]
],
                                  @_);
    bless($self,$class);
}

#line 148 "typedoc.yp"
 

sub define_type
{
    my($self, $old_type, $new_type, $comment) = @_;
    my $def = Bio::KBase::KIDL::KBT::Typedef->new(name => $new_type, alias_type => $old_type, comment => $comment);
    push(@{$self->YYData->{type_list}}, $def);
    $self->YYData->{type_table}->{$new_type} = $def;
    #
    # Try to name the typedefed type if it is a tuple or struct.
    #
    if ($old_type->isa('Bio::KBase::KIDL::KBT::Struct') || $old_type->isa('Bio::KBase::KIDL::KBT::Tuple'))
    {
	$old_type->name_type($new_type);
	if ($comment)
	{
	    $old_type->comment($comment);
	}
    }
    return $def;
}

sub types
{
    my($self) = @_;
    return $self->YYData->{type_list} || [];
}

sub lookup_type
{
    my($self, $name) = @_;
    return $self->YYData->{type_table}->{$name};
}


sub parse
{
    my($self, $data, $filename) = @_;

    $self->init_state($data, $filename);
    my $res = $self->YYParse(yylex => \&Lexer, yyerror => \&Error);

    return ($res, $self->YYData->{error_count});;
}

sub init_state
{
    my($self, $data, $filename) = @_;

    #
    # Initialize type table to just the builtins.
    #
    $self->YYData->{type_table} = { %builtin_types };
    $self->YYData->{INPUT} = $data;
    $self->YYData->{line_number} = 1;
    $self->YYData->{filename} = $filename;
    $self->YYData->{error_count} = 0;
}


sub Error {
    my($parser) = @_;
    
    my $data = $parser->YYData;

    my $error = $data->{ERRMSG} || "Syntax error";

    $parser->emit_error($error);
}

sub emit_error {
    my($parser, $message) = @_;
    
    my $data = $parser->YYData;

    my $line = $data->{line_number};
    my $file = $data->{filename};

    my $token = $parser->YYCurtok;
    my $tval = $parser->YYCurval;

    if ($token eq 'IDENT')
    {
	$token = $tval;
    }
    

    print STDERR "$file:$line: $message (next token is '$token')\n";
    $data->{error_count}++;
}


sub Lexer {
    my($parser)=shift;

    my $data = $parser->YYData;
    my $bufptr = \$data->{INPUT};

    for ($$bufptr)
    {
	while ($_ ne '')
	{
	    # print "Top: '$_'\n";
	    next if (s/^[ \t]+//);
	    if (s/^\n//)
	    {
		$data->{line_number}++;
		next;
	    }
	    
	    if ($_ eq '')
	    {
		return ('', undef);
	    }
	    elsif (s/^(funcdef|typedef|module|list|mapping|structure|nullable|returns|authentication|tuple|async)\b//)
	    {
		return (uc($1), $1);
	    }
	    elsif (s/^([A-Za-z][A-Za-z0-9_]*)//)
	    {
		my $str = $1;
		if ($builtin_types{$str})
		{
		    my $type = $data->{type_table}->{$str};
		    return('TYPENAME', $type);
		}
		else
		{
		    return('IDENT', $str);
		}
	    }
	    elsif (s,^/\*(.*?)\*/,,s)
	    {
		my $com = $1;
		if ($com =~ /^\*/)
		{
		    #
		    # It was a /** comment which is a doc-block. Return that as a token.
		    #
		    return('DOC_COMMENT', $com);
		}

		my @lines = split(/\n/, $com);
		$lines[0] =~ s/^\s*//;
		my @new = ($lines[0]);
		shift @lines;
		if (@lines)
		{
		    my $l = $lines[0];
		    $l =~ s/\t/        /g;
		    my($init_ws) = $l =~ /^(\s+)/;
		    my $x = length($init_ws);
		    # print "x=$x '$lines[0]'\n";
		    for my $l (@lines)
		    {
			$l =~ s/\t/        /g;
			$l =~ s/^\s{$x}//;
			push(@new, $l);
		    }
		}
		#$parser->{cur_comment} = $com;
		$parser->{cur_comment} = join("\n", @new);
		
		# Else just elide.
	    }
	    elsif (s/^(.)//s)
	    {
		return($1,$1);
	    }
	}
    }
}

#
# Return the current comment if there is one. Always
# clear the current comment.
#
sub get_comment
{
    my($self) = @_;
    my $ret = $self->{cur_comment};
    $self->{cur_comment} = "";
    $ret =~ s/^\s+//;
    $ret =~ s/\s+$//;
    return $ret;
}
    

1;
