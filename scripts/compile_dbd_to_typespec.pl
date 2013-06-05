#!/usr/bin/env perl
use strict;
use Data::Dumper;
use XML::LibXML;
#use String::CamelCase 'decamelize';
use Template;
use Bio::KBase::KIDL::KBT;
use Getopt::Long;

=head1 NAME

compile_dbd_to_typespec

=head1 SYNOPSIS

compile_dbd_to_typespec service-name module-name DBD-xml-file spec-file impl-file bin-dir

=head1 DESCRIPTION

compile_dbd_to_typespec creates the type specification, implementation module, and command
line scripts for an ERDB database as defined by its XML specification.

=head1 COMMAND-LINE OPTIONS

Usage: compile_dbd_to_typespec service-name module-name DBD-xml-file spec-file impl-file bin-dir

=head1 AUTHORS

Robert Olson, Argonne National Laboratory, olson@mcs.anl.gov

=cut

my $help;
my $rc = GetOptions("h|help" => \$help);    

if (!$rc || $help || @ARGV < 6)
{
    seek(DATA, 0, 0);
    while (<DATA>)
    {
	last if /^=head1 COMMAND-LINE /;
    }
    while (<DATA>)
    {
	last if /^=/;
	print $_;
    }
    exit($help ? 0 : 1);
}


my $service = shift;
my $module = shift;
my $in_file = shift;
my $out_file = shift;
my $impl_file = shift;
my $bin_dir = shift;

-d $bin_dir or die "bin-dir $bin_dir does not exist\n";

my $doc = XML::LibXML->new->parse_file($in_file);
$doc or die "cannot parse $in_file\n";

my %type_map = (boolean	    => 'int',
		'semi-boolean'	=> 'string',
		char	    => 'string',
		countVector => 'countVector',
		counter	    => 'int',
		date	    => 'string',
		diamond	    => 'diamond',
		dna	    => 'string',
		float	    => 'float',
		image	    => 'string',
		int	    => 'int',
		link	    => 'string',
		rectangle   => 'rectangle',
		string	    => 'string',
		'long-string'	    => 'string',
		text	    => 'string',
		);


my %kids;
my %names;

for my $r ($doc->findnodes('//Relationships/Relationship'))
{
    my $n = $r->getAttribute("name");
    my $arity = $r->getAttribute("arity");
    my $from = $r->getAttribute("from");
    my $to = $r->getAttribute("to");
    my $converse = $r->getAttribute("converse");
    
    die "Duplicate name detected in relationship: $n" if $names{$n};
    die "Duplicate name detected in converse relationship: $converse" if $names{$converse};
	
	$names{$n} = 1;
	$names{$converse} = 1;
	
    push(@{$kids{$from}}, {name => $n, to => $to});
    push(@{$kids{$to}}, {name => $converse, to => $from});
}

for my $e ($doc->findnodes('//Entities/Entity')) 
{
	my $n = $e->getAttribute("name");
	die "Duplicate name detected in entity: $n" if $names{$n};
	$names{$n} = 1
}

my $entities = [];
my $relationships = [];
my $template_data = {
    entities => $entities,
    entities_by_name => {},
    relationships => $relationships,
    module => $module,
};

open(OUT, ">", $out_file) or die "cannot write $out_file: $!";
open(IMPL, ">", $impl_file) or die "cannot write $impl_file: $!";
print OUT "module $service : $module {\n";
print OUT "typedef string diamond;\n";
print OUT "typedef string countVector;\n";
print OUT "typedef string rectangle;\n";
print OUT "\n";

for my $e (sort { $a->getAttribute("name") cmp $b->getAttribute("name") }  $doc->findnodes('//Entities/Entity'))
{
    my $n = $e->getAttribute("name");
    my @cnode = $e->getChildrenByTagName("Notes");
    my $com = join("\n", map { my $s = $_->textContent; $s =~ s/^\s*//gm; $s } @cnode);
    my $keyType = $e->getAttribute("keyType");
    # my $nn = decamelize($n);
    my $nn = $n;

    my $field_map = [];

    my $edata = {
	name 	     => $nn,
	sapling_name => $n,
	field_map    => $field_map,
	comment      => $com,
	key_type     => $keyType,
    };
    push(@$entities, $edata);
    $template_data->{entities_by_name}->{$n} = $edata;

    my @fields = $e->findnodes('Fields/Field');
    # next if @fields == 0;

    my $id_ftype = $type_map{$keyType};

    print OUT "typedef structure {\n";
    print OUT "\t$id_ftype id;\n";

    #
    # Relationship linkages.
    #
    $edata->{relationships} = [ sort { $a->{name} cmp $b->{name} } @{$kids{$n}} ];

    $com .= "\nIt has the following fields:\n\n=over 4\n\n";
    for my $f (@fields)
    {
	my $fn = $f->getAttribute("name");
	# my $fnn = decamelize($fn);
	my $fnn = $fn;

	my $field_rel = $f->getAttribute("relation");

	$fnn =~ s/-/_/g;

	my $field_ent = { name => $fnn, sapling_name => $fn };
	push(@$field_map,$field_ent);
	
	my $ftype = $type_map{$f->getAttribute("type")};

	if ($field_rel)
	{
	    print OUT "\tlist<$ftype> $fnn nullable;\n";
	    $field_ent->{field_rel} = $field_rel;
	}
	else 
	{
	    print OUT "\t$ftype $fnn nullable;\n";
	}

	my @fcnode = $f->getChildrenByTagName("Notes");
	my $fcom = join("\n", map { my $s = $_->textContent; $s =~ s/^\s*//gm; $s } @fcnode);
	$field_ent->{notes} = $fcom;
	$field_ent->{notes} =~ s/\n/ /gs;

	$com .= "\n=item $fnn\n\n$fcom\n\n";
    }

    $edata->{field_list} = join(", ", map { "'$_->{name}'" } @$field_map);
    $com .= "\n\n=back\n\n";
    print OUT "} fields_$nn ;\n";
    print OUT "\n";
    print OUT "/*\n$com\n*/\n";
    print OUT "funcdef get_entity_$nn(list<string> ids, list<string> fields)\n";
    print OUT "\treturns(mapping<string, fields_$nn>);\n";
    print OUT "funcdef query_entity_$nn(list<tuple<string, string, string>> qry, list<string> fields)\n";
    print OUT "\treturns(mapping<string, fields_$nn>);\n";
    print OUT "funcdef all_entities_$nn(int start, int count, list<string> fields)\n";
    print OUT "\treturns(mapping<string, fields_$nn>);\n";
    print OUT "\n";
}

for my $e (sort { $a->getAttribute("name") cmp $b->getAttribute("name") }  $doc->findnodes('//Relationships/Relationship'))
{
    my $n = $e->getAttribute("name");
    my $from = $e->getAttribute("from");
    my $to = $e->getAttribute("to");
    my $converse = $e->getAttribute("converse");
    
    my @cnode = $e->getChildrenByTagName("Notes");
    my $com = join("\n", map { my $s = $_->textContent; $s =~ s/^\s*//gm; $s } @cnode);

    # my $nn = decamelize($n);
    my $nn = $n;

    my $field_map = [];

    my $edata = {
	name 	     => $nn,
	sapling_name => $n,
	field_map    => $field_map,
	relation     => $nn,
	is_converse  => 0,
	from 	     => $from,
	to 	     => $to,
	comment      => $com,
	from_data    => $template_data->{entities_by_name}->{$from},
	to_data      => $template_data->{entities_by_name}->{$to},
    };
    push(@$relationships, $edata);

    my $rev_edata = {
	name 	     => $converse,
	sapling_name => $converse,
	relation     => $nn,
	is_converse  => 1,
	field_map    => $field_map,
	from 	     => $to,
	to 	     => $from,
	comment      => $com,
	from_data    => $template_data->{entities_by_name}->{$to},
	to_data      => $template_data->{entities_by_name}->{$from},
    };
    push(@$relationships, $rev_edata);

    my $from_ftype = $type_map{$template_data->{entities_by_name}->{$from}->{key_type}};
    my $to_ftype = $type_map{$template_data->{entities_by_name}->{$to}->{key_type}};

    my @fields = $e->findnodes('Fields/Field');

    print OUT "typedef structure {\n";
#    print OUT "\tstring id;\n";
    print OUT "\t$from_ftype from_link;\n";
    print OUT "\t$to_ftype to_link;\n";

    $com .= "\nIt has the following fields:\n\n=over 4\n\n";
    for my $f (@fields)
    {
	my $fn = $f->getAttribute("name");
	# my $fnn = decamelize($fn);
	my $fnn = $fn;

	my $field_rel = $f->getAttribute("relation");
	$fnn =~ s/-/_/g;

	my $field_ent = { name => $fnn, sapling_name => $fn };
	push(@$field_map,$field_ent);

	my $ftype = $type_map{$f->getAttribute("type")};

	
	if ($field_rel)
	{
	    print OUT "\tlist<$ftype> $fnn nullable;\n";
	    $field_ent->{field_rel} = $field_rel;
	}
	else 
	{
	    print OUT "\t$ftype $fnn nullable;\n";
	}

	my @fcnode = $f->getChildrenByTagName("Notes");
	my $fcom = join("\n", map { my $s = $_->textContent; $s =~ s/^\s*//gm; $s } @fcnode);

	$com .= "\n=item $fnn\n\n$fcom\n\n";
    }

    $edata->{field_list} = join(", ", map { "'$_->{name}'" } @$field_map);
    $rev_edata->{field_list} = join(", ", map { "'$_->{name}'" } @$field_map);
    $com .= "\n\n=back\n\n";
    print OUT "} fields_$nn ;\n";
    print OUT "\n";
    print OUT "/*\n$com\n*/\n";
    print OUT "funcdef get_relationship_$nn(list<string> ids, list<string> from_fields, list<string> rel_fields,  list<string> to_fields)\n";
    print OUT "\treturns(list<tuple<fields_$from, fields_$nn, fields_$to>>);\n";

    print OUT "funcdef get_relationship_$converse(list<string> ids, list<string> from_fields, list<string> rel_fields,  list<string> to_fields)\n";
    print OUT "\treturns(list<tuple<fields_$to, fields_$nn, fields_$from>>);\n";

    print OUT "\n";
}


print OUT "};\n";

my $tmpl_dir = Bio::KBase::KIDL::KBT->install_path;

my $tmpl = Template->new({ OUTPUT_PATH => '.',
			       ABSOLUTE => 1,
			   });

for my $entity (@{$entities})
{
    my %d = %$template_data;
    $d{entity} = $entity;
    open(my $fh, ">", "$bin_dir/get_entity_$entity->{name}.pl") or die "cannot write $bin_dir/get_entity_$entity->{name}.pl: $!";
    $tmpl->process("$tmpl_dir/get_entity.tt", \%d, $fh) || die Template->error;
    close($fh);
    open(my $fh, ">", "$bin_dir/all_entities_$entity->{name}.pl") or die "cannot write $bin_dir/all_entities_$entity->{name}.pl: $!";
    $tmpl->process("$tmpl_dir/all_entities.tt", \%d, $fh) || die Template->error;
    close($fh);
    open(my $fh, ">", "$bin_dir/query_entity_$entity->{name}.pl") or die "cannot write $bin_dir/query_entity_$entity->{name}.pl: $!";
    $tmpl->process("$tmpl_dir/query_entity.tt", \%d, $fh) || die Template->error;
    close($fh);
}

for my $rel (@{$relationships})
{
    my %d = %$template_data;
    $d{relationship} = $rel;
    open(my $fh, ">", "$bin_dir/get_relationship_$rel->{name}.pl") or die "cannot write $bin_dir/get_relationship_$rel->{name}.pl: $!";
    $tmpl->process("$tmpl_dir/get_relationship.tt", \%d, $fh) || die Template->error;
    close($fh);
}
$tmpl->process("$tmpl_dir/sapling_impl.tt", $template_data, \*IMPL) || die Template->error;

__DATA__
