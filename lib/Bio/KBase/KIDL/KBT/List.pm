package Bio::KBase::KIDL::KBT::List;

use Moose;

has 'element_type' => (is => 'rw');

sub as_string
{
    my($self) = @_;
    return "list<" . $self->element_type->as_string . ">";
}

sub english
{
    my($self, $indent) = @_;

    my $value_eng = $self->element_type->english($indent);
    return "a reference to a list where each element is $value_eng";
}

sub get_validation_routine
{
    my($self, $var) = @_;
    my $val = "ref($var) eq 'ARRAY'";
    return $val;
}

sub get_validation_code
{
    return 'Params::Validate::ARRAYREF';
}

sub subtypes
{
    my($self, $seen) = @_;
    my $out = [];
    for my $type ($self->element_type)
    {	
	push(@$out, @{$type->subtypes($seen)});
    }

    return $out;
}



1;
