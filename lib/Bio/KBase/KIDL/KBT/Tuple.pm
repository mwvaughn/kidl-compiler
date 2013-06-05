package Bio::KBase::KIDL::KBT::Tuple;

use Moose;

has 'element_types' => (is => 'rw', isa => 'ArrayRef');
has 'element_names' => (is => 'rw', isa => 'ArrayRef[Maybe[Str]]');
has 'name' => (is => 'rw', isa => 'Str',
	       predicate => 'has_name');
has 'comment' => (is => 'rw', isa => 'Str',
		  predicate => 'has_comment');

sub BUILD
{
    my($self) = @_;

    #
    # If we have element names and types, and names are empty, try
    # to fill them in if the corresponding type is a typedef.
    #
    my $names = $self->element_names;
    my $types = $self->element_types;
    if (ref($names) && ref($types))
    {
	my %seen;
	for (my $i = 0; $i < @$types; $i++)
	{
	    if (defined($names->[$i]))
	    {
		$seen{$names->[$i]}++;
	    }
	    else
	    {
		if ($types->[$i]->isa('KBT::Typedef'))
		{
		    $names->[$i] = $types->[$i]->name;
		}
		else
		{
		    $names->[$i] = "e_" . ($i + 1);
		}
		$seen{$names->[$i]}++;
	    }
	}
	#
	# Disambiguate names.
	#
	my %count;
	for (my $i = 0; $i < @$names; $i++)
	{
	    my $name = $names->[$i];
	    if ($seen{$name} > 1)
	    {
		my $idx = $count{$name}++;
		$idx++;
		$names->[$i] .= "_$idx";
	    }
	}
    }
}

sub get_validation_code
{
    return 'Params::Validate::ARRAYREF';
}

sub get_validation_routine
{
    my($self, $var) = @_;
    my $val = "ref($var) eq 'ARRAY'";
    return $val;
}

sub name_type
{
    my($self, $name) = @_;

    if (!$self->has_name)
    {
	$self->name($name);
    }
}

sub as_string
{
    my($self) = @_;
    return "tuple<" . join(", ", map { $_->as_string } @{$self->element_types} ) . ">";
}

sub subtypes
{
    my($self, $seen) = @_;
    my $out = [];
    for my $type (@{$self->element_types})
    {	
	push(@$out, @{$type->subtypes($seen)});
    }

    return $out;
}

sub english
{
    my($self, $indent) = @_;
    
    my $n = @{$self->element_types};
    my $names = $self->element_names;
    my $eng = "a reference to a list containing $n items:\n";
    my $i = 0;
    for my $ent (@{$self->element_types})
    {
	my $item_eng = $ent->english($indent + 1);
	my $item_name = ($names->[$i] && $names->[$i] !~ /^e_\d+$/) ? "($names->[$i]) " : "";
	$eng .= "\t" x $indent. "$i: $item_name$item_eng\n";
	$i++;
    }
    return $eng;
}

1;
