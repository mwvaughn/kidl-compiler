package Bio::KBase::KIDL::KBT::Struct;

use Moose;
use Data::Dumper;

has 'items' => (isa => 'ArrayRef[Bio::KBase::KIDL::KBT::StructItem]',
		is => 'rw');

has 'name' => (is => 'rw', isa => 'Str',
	       predicate => 'has_name');
has 'comment' => (is => 'rw', isa => 'Str',
		  predicate => 'has_comment');

sub name_type
{
    my($self, $name) = @_;
    if (!$self->has_name)
    {
	$self->name($name);
    }
}

sub get_validation_routine
{
    my($self, $var) = @_;
    my $val = "ref($var) eq 'HASH'";
    return $val;
}

sub get_validation_code
{
    return 'Params::Validate::HASHREF';
}

sub as_string
{
    my($self) = @_;
    return join(" ", "struct", "{", (map { $_->as_string, ";" } @{$self->items}), "}" );
}

sub subtypes
{
    my($self, $seen) = @_;
    my $out = [];

    for my $item (@{$self->items})
    {
	push(@$out, @{$item->subtypes($seen)});
    }
    return $out;
}

sub english
{
    my($self, $indent) = @_;
    
    my $eng = "a reference to a hash where the following keys are defined:\n";
    for my $ent (@{$self->items})
    {
	my $n = $ent->name;
	my $item_eng = $ent->item_type->english($indent);
	$eng .= "\t" x $indent . "$n has a value which is $item_eng\n";
    }
    return $eng;
}

1;
