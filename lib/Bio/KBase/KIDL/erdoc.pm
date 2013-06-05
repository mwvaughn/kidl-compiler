####################################################################
#
#    This file was generated using Parse::Yapp version 1.05.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package erdoc;
use vars qw ( @ISA );
use strict;

@ISA= qw ( Parse::Yapp::Driver );
use Parse::Yapp::Driver;

#line 4 "erdoc.yp"

    use Devel::StackTrace;
    use KBT;
    use Data::Dumper;
    use File::Spec;

our %field_types = ('int' => KBT::Scalar->new(scalar_type => 'int'),
		    'string' => KBT::Scalar->new(scalar_type => 'string'),
		    'float' => KBT::Scalar->new(scalar_type => 'float'),
    );



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
			'start' => 2,
			'item_list' => 1
		}
	},
	{#State 1
		ACTIONS => {
			'ENTITY' => 3,
			'RELATIONSHIP' => 7
		},
		DEFAULT => -1,
		GOTOS => {
			'entity' => 4,
			'relationship' => 5,
			'item' => 6
		}
	},
	{#State 2
		ACTIONS => {
			'' => 8
		}
	},
	{#State 3
		DEFAULT => -6,
		GOTOS => {
			'@1-1' => 9
		}
	},
	{#State 4
		DEFAULT => -4
	},
	{#State 5
		DEFAULT => -5
	},
	{#State 6
		DEFAULT => -3
	},
	{#State 7
		DEFAULT => -8,
		GOTOS => {
			'@2-1' => 10
		}
	},
	{#State 8
		DEFAULT => 0
	},
	{#State 9
		ACTIONS => {
			'IDENT' => 11
		}
	},
	{#State 10
		ACTIONS => {
			'IDENT' => 12
		}
	},
	{#State 11
		ACTIONS => {
			"{" => 13
		}
	},
	{#State 12
		ACTIONS => {
			"<" => 15,
			"=" => 16
		},
		GOTOS => {
			'direction' => 14
		}
	},
	{#State 13
		DEFAULT => -13,
		GOTOS => {
			'field_list' => 17
		}
	},
	{#State 14
		ACTIONS => {
			'IDENT' => 18
		}
	},
	{#State 15
		ACTIONS => {
			"=" => 19
		}
	},
	{#State 16
		ACTIONS => {
			">" => 20
		}
	},
	{#State 17
		ACTIONS => {
			"}" => 22
		},
		DEFAULT => -15,
		GOTOS => {
			'@3-0' => 21,
			'field' => 23
		}
	},
	{#State 18
		ACTIONS => {
			'IDENT' => 25
		},
		GOTOS => {
			'arity' => 24
		}
	},
	{#State 19
		ACTIONS => {
			">" => 26
		}
	},
	{#State 20
		DEFAULT => -11
	},
	{#State 21
		ACTIONS => {
			'TYPENAME' => 27
		},
		GOTOS => {
			'field_type' => 28
		}
	},
	{#State 22
		ACTIONS => {
			";" => 29
		}
	},
	{#State 23
		DEFAULT => -14
	},
	{#State 24
		ACTIONS => {
			"{" => 30
		}
	},
	{#State 25
		ACTIONS => {
			":" => 31
		}
	},
	{#State 26
		DEFAULT => -10
	},
	{#State 27
		DEFAULT => -17
	},
	{#State 28
		ACTIONS => {
			'IDENT' => 32
		}
	},
	{#State 29
		DEFAULT => -7
	},
	{#State 30
		DEFAULT => -13,
		GOTOS => {
			'field_list' => 33
		}
	},
	{#State 31
		ACTIONS => {
			'IDENT' => 34
		}
	},
	{#State 32
		ACTIONS => {
			";" => 35
		}
	},
	{#State 33
		ACTIONS => {
			"}" => 36
		},
		DEFAULT => -15,
		GOTOS => {
			'@3-0' => 21,
			'field' => 23
		}
	},
	{#State 34
		DEFAULT => -12
	},
	{#State 35
		DEFAULT => -16
	},
	{#State 36
		ACTIONS => {
			";" => 37
		}
	},
	{#State 37
		DEFAULT => -9
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
		 'item_list', 0,
sub
#line 23 "erdoc.yp"
{ [] }
	],
	[#Rule 3
		 'item_list', 2,
sub
#line 24 "erdoc.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 4
		 'item', 1, undef
	],
	[#Rule 5
		 'item', 1, undef
	],
	[#Rule 6
		 '@1-1', 0,
sub
#line 31 "erdoc.yp"
{ $_[0]->get_comment() }
	],
	[#Rule 7
		 'entity', 7,
sub
#line 31 "erdoc.yp"
{ ['ENTITY', $_[2], $_[3], $_[5]] }
	],
	[#Rule 8
		 '@2-1', 0,
sub
#line 33 "erdoc.yp"
{ $_[0]->get_comment() }
	],
	[#Rule 9
		 'relationship', 10,
sub
#line 34 "erdoc.yp"
{ ['REL', $_[2], $_[3], $_[4], $_[5], $_[6], $_[8]] }
	],
	[#Rule 10
		 'direction', 3,
sub
#line 37 "erdoc.yp"
{ '<=>' }
	],
	[#Rule 11
		 'direction', 2,
sub
#line 38 "erdoc.yp"
{ '=>' }
	],
	[#Rule 12
		 'arity', 3,
sub
#line 41 "erdoc.yp"
{ [$_[1], $_[3]] }
	],
	[#Rule 13
		 'field_list', 0,
sub
#line 44 "erdoc.yp"
{ [] }
	],
	[#Rule 14
		 'field_list', 2,
sub
#line 45 "erdoc.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 15
		 '@3-0', 0,
sub
#line 48 "erdoc.yp"
{$_[0]->get_comment() }
	],
	[#Rule 16
		 'field', 4,
sub
#line 48 "erdoc.yp"
{ [$_[1], $_[2], $_[3] ]}
	],
	[#Rule 17
		 'field_type', 1, undef
	]
],
                                  @_);
    bless($self,$class);
}

#line 54 "erdoc.yp"
 

sub define_type
{
    my($self, $old_type, $new_type, $comment) = @_;
    my $def = KBT::Typedef->new(name => $new_type, alias_type => $old_type, comment => $comment);
    push(@{$self->YYData->{type_list}}, $def);
    $self->YYData->{type_table}->{$new_type} = $def;
    return $def;
}

sub types
{
    my($self) = @_;
    return $self->YYData->{type_list};
}

sub lookup_type
{
    my($self, $name) = @_;
    return $self->YYData->{type_table}->{$name};
}


sub parse
{
    my($self, $data) = @_;

    #
    # Initialize type table to just the builtins.
    #
    $self->YYData->{type_table} = { %field_types };

    $self->YYData->{INPUT} = $data;

    my $res = $self->YYParse(yylex => \&Lexer, yyerror => \&Error);

    return $res;
}


sub Error {
    my($parser) = @_;
    
    my $data = $parser->YYData;
    my $bufptr = \$data->{INPUT};

    my $ctx = substr($$bufptr, 0, 100);

    if ($data->{ERRMSG})
    {
        print $data->{ERRMSG};
	print "$ctx\n";
        delete $data->{ERRMSG};
        return;
    }
    else
    {
	print "Syntax error.\n";
	print "$ctx\n";
    }
}

sub LexerX
{
my($parser) = shift;
my @res = &LexerX($parser);
print Dumper(\@res);
return @res;
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
	    s/^[ \t\n]+//;

	    
	    if ($_ eq '')
	    {
		return ('', undef);
	    }
	    elsif (s/^(entity|relationship)\b//)
	    {
		return (uc($1), $1);
	    }
	    elsif (s/^([A-Za-z][A-Za-z0-9_]*)//)
	    {
		#print "Check builtin $1 " . Dumper($data->{type_table});
		
		if (my $type = $data->{type_table}->{$1})
		{
		    return('TYPENAME', $type);
		}
		else
		{
		    return('IDENT',$1);
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
