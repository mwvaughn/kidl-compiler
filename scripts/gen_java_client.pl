#!/usr/bin/env perl
use Bio::KBase::KIDL::typedoc;
use strict;
use POSIX;
use Data::Dumper;
use Template;
use File::Slurp;
use File::Path 'make_path';
use Bio::KBase::KIDL::KBT;
use Getopt::Long;

=head1 NAME

gen_java_client

=head1 SYNOPSIS

gen_java_client typespec [typespec...] package output-dir

=head1 DESCRIPTION

gen_java_client is the java client compiler for the KBase Interface Description Language (KIDL).

=head1 COMMAND-LINE OPTIONS

Usage: gen_java_client typespec [typespec...] package output-dir

=head1 AUTHORS

Robert Olson, Argonne National Laboratory olson@mcs.anl.gov

=cut

my $scripts_dir;
my $help;

our %java_scalar_map = (int => 'Integer',
			string => 'String',
			float => 'Float');

our %java_topscalar_map = (int => 'int',
			string => 'String',
			float => 'float');

my $rc = GetOptions('help|h' => \$help);

if (!$rc || $help || @ARGV < 3)
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
    exit 0;
}

my $dir = pop;
my $package = pop;
my @spec_files = @ARGV;

my $package_dir = $package;
$package_dir =~ s,\.,/,g;
$package_dir = "$dir/$package_dir";
make_path($package_dir);

my $parser = typedoc->new();

#
# Read and parse all the given documents. We collect all documents
# that comprise each service, and process the services as units.
#

my %services;
my @all_modules;

my $errors_found;

for my $spec_file (@spec_files)
{
    my $txt = read_file($spec_file) or die "Cannot read $spec_file: $!";
    my($modules, $errors) = $parser->parse($txt, $spec_file);
    my $type_info = assemble_types($parser);
    if ($errors)
    {
	print "$errors errors were found in $spec_file\n";
	$errors_found += $errors;
    }
    push(@all_modules, @$modules);
    for my $mod (@$modules)
    {
	my $mod_name = $mod->module_name;
	my $serv_name = $mod->service_name;
	print "$spec_file: module $mod_name service $serv_name\n";
	push(@{$services{$serv_name}}, [$mod, $type_info, $parser->YYData->{type_table}]);
    }
}
if ($errors_found)
{
    exit 1;
}

#die Dumper(\%services);

while (my($service, $modules) = each %services)
{
    write_service_stubs($service, $modules, $dir);
}

sub write_service_stubs
{
    my($service, $modules, $dir) = @_;

    my $tmpl = Template->new( { OUTPUT_PATH => $dir,
				ABSOLUTE => 1,
			      });

    my %service_options;

    my @modules;

    for my $module_ent (@$modules)
    {
	my($module, $type_info, $type_table) = @$module_ent;

	write_module_stubs($module, $type_info, $type_table);
	
    }
}

sub write_module_stubs
{
    my($module, $type_info, $type_table) = @_;
    
    my $tmpl_dir = Bio::KBase::KIDL::KBT->install_path;
    my $tmpl = Template->new({ ABSOLUTE => 1 });

    my %service_options;
    $service_options{$_} = 1 foreach @{$module->options};

#    my $data = compute_module_data($module, $type_info, $type_table);

    my $vars = java_typing($module);

    my $file = "$package_dir/" . $module->module_name . ".java";

    $tmpl->process("$tmpl_dir/java_client.tt", $vars, $file) or die Template->error;

    for my $tent (@{$vars->{tuples}})
    {
	my %vars = ( %$vars, tuple => $tent );
	my $n = $tent->{name};

	my $file = "$package_dir/${n}_serializer.java";
	$tmpl->process("$tmpl_dir/java_serializer.tt", \%vars, $file) or die Template->error;

	my $file = "$package_dir/${n}_deserializer.java";
	$tmpl->process("$tmpl_dir/java_deserializer.tt", \%vars, $file) or die Template->error;

	my $file = "$package_dir/${n}.java";
	$tmpl->process("$tmpl_dir/java_tuple.tt", \%vars, $file) or die Template->error;
    }
 
    for my $sent (@{$vars->{structs}})
    {
	my %vars = ( %$vars, struct => $sent );
	my $n = $sent->{name};

	my $file = "$package_dir/${n}.java";
	$tmpl->process("$tmpl_dir/java_struct.tt", \%vars, $file) or die Template->error;
    }
 
}

sub java_typing
{
    my($module) = @_;

    my $doc = $module->comment;
    $doc =~ s/^\s*\*\s?//mg;

    my $methods = [];
    my $struct_types = {
	_next_struct => 1,
	_next_tuple => 1,
	package => $package,
	methods => $methods,
	module => $module->module_name,
	module_doc => $doc,
    };
    
    for my $comp (@{$module->module_components})
    {
	next unless $comp->isa('Bio::KBase::KIDL::KBT::Funcdef');

	my $doc = $comp->comment;
	$doc =~ s/^\s*\*\s?//mg;

	my $meth = {};

	push(@$methods, $meth);

	$meth->{name} = $comp->name;
	$meth->{jsonrpc_call} = join(".", $module->module_name, $comp->name);
	$meth->{doc} = $doc if $doc ne '';

	my $params = $comp->parameters;
	my $returns = $comp->return_type;

	my @args;
	my %ncount;
	my @jtypes;
	my @decls;
	my @argtypes;
	my $tmpargs = [];
	$meth->{args} = $tmpargs;
	
	print $comp->name . "\n";
	for my $i (0..$#$params)
	{
	    my $p = $params->[$i];

	    my $name = $p->{name};
	    if (!$name)
	    {
		#
		# if we didn't pass in a name, and if
		# this parameter is a typedef, use the type name.
		#
		if (ref($p->{type}) && $p->{type}->can('alias_type'))
		{
		    $name = $p->{type}->name;
		}
		else
		{
		    $name = "arg_" . ($i + 1);
		}
	    }
	    push(@args, $name);
	    $ncount{$name}++;
	    push(@argtypes, $p->{type});

	    my $jt = map_type_to_java($module->module_name, $p->{type}, $struct_types, 1);

	    push(@jtypes, $jt);
	    push(@decls, "$jt $name");

	    push(@$tmpargs, { name => $name, type => $jt });
	}
	for my $argi (0..$#args)
	{
	    if ($ncount{$args[$argi]} > 1)
	    {
		$args[$argi] .= "_" . ($argi + 1);
	    }
	}

	#
	# We construct a tuple for the arguments.
	#
	my $arg_type_name = 'args_' . $comp->name;
	my $arg_tuple = Bio::KBase::KIDL::KBT::Tuple->new(name => $arg_type_name,
					element_types => [@argtypes],
					element_names => [@args]);
	my $arg_jt = map_type_to_java($module->module_name,$arg_tuple, $struct_types);

	$meth->{args_decl_string} = join(", ", @decls);
	$meth->{args_type} = $arg_jt;
		

	if (@$returns == 0)
	{
	    $meth->{return_type} = "void";
	    $meth->{return_val} = "";
	    $meth->{void} = 1;
	}
	else
	{
	    my($rtype, $rname);
	    
	    #
	    # We construct a tuple type for the returns. If there is only
	    # one, we adjust the signature of the method to return just the single
	    # value; otherwise the method returns the tuple.
	    #
	    
	    my($rtypes, $rnames);
	    for my $i (0..$#$returns)
	    {
		my $p = $returns->[$i];
		
		push(@$rtypes, $p->{type});
		
		my $name = $p->{name} // "return_" . ($i + 1);
		push(@$rnames, $name);
	    }
	    $rname = 'return_' . $comp->name;
	    my $tuple = Bio::KBase::KIDL::KBT::Tuple->new(name => $rname,
					element_types => $rtypes,
					element_names => $rnames);
	    
	    $rtype = map_type_to_java($module->module_name, $tuple, $struct_types);
	    $meth->{json_return_type} = $rtype;
	    
	    if (@$returns == 1)
	    {
		$meth->{return_type} = map_type_to_java($module->module_name, $rtypes->[0], $struct_types);
		$meth->{return_name} = $rnames->[0];
		$meth->{return_val} = "res.$rnames->[0]";
	    }
	    else
	    {
		$meth->{return_type} = $rtype;
		$meth->{return_name} = $rname;
		$meth->{return_val} = "res";
	    }
	}
    }

    return $struct_types;
}

# Map a type object to the corresponding Java type.
# 
# The C<$toplevel> flag is true when we can map the base types (int float) directly
# to java base types. Otherwise we map to the object-based types (Integer, Float).

sub map_type_to_java
{
    my($module_name, $type, $struct_types, $toplevel) = @_;

    if ($type->isa('Bio::KBase::KIDL::KBT::Typedef'))
    {
	return map_type_to_java($module_name, $type->alias_type, $struct_types);
    }
    elsif ($type->isa('Bio::KBase::KIDL::KBT::Scalar'))
    {
	if ($toplevel)
	{
	    return $java_topscalar_map{$type->scalar_type};
	}
	else
	{
	    return $java_scalar_map{$type->scalar_type};
	}
    }
    elsif ($type->isa('Bio::KBase::KIDL::KBT::List'))
    {
	my $elt_type = map_type_to_java($module_name, $type->element_type, $struct_types);
	my $ret = "List<$elt_type>";
	return $ret;
    }
    elsif ($type->isa('Bio::KBase::KIDL::KBT::Mapping'))
    {
	my $kt = map_type_to_java($module_name, $type->key_type, $struct_types);
	my $vt = map_type_to_java($module_name, $type->value_type, $struct_types);
	return "Map<$kt, $vt>";
    }
    elsif ($type->isa('Bio::KBase::KIDL::KBT::Tuple'))
    {
	return construct_tuple($module_name, $type, $struct_types);
    }
    elsif ($type->isa('Bio::KBase::KIDL::KBT::Struct'))
    {
	return construct_struct($module_name, $type, $struct_types);
    }
    else
    {
	die Dumper($type);
	return "undef";
    }
}

sub construct_tuple
{
    my($module_name, $type, $struct_types) = @_;

    my $tuple_name;
    if ($type->has_name)
    {
	$tuple_name = $type->name;
    }
    else
    {
	#
	# Unnamed tuple. Assign one based on _next_tuple in the struct_types hash.
	#
	# We make these unique based on the signature of the type.
	#

	my $sig = $type->as_string;
	if (my $existing = $struct_types->{_existing_tuples}->{$sig})
	{
	    return $existing;
	}
	
	my $n = $struct_types->{_next_tuple}++;
	$tuple_name = "${module_name}_tuple_$n";
	$struct_types->{_existing_tuples}->{$sig} = $tuple_name;
    }

    my @subtypes;
    my @names;

    @subtypes = @{$type->element_types};
    @names = @{$type->element_names};

    my @elt_types = map { map_type_to_java($module_name, $_, $struct_types) } @subtypes;

    my $elts = [];
    my $tup = { name => $tuple_name, elements => $elts };
    $tup->{comment} = $type->comment if $type->has_comment;
    
    for (my $i = 0; $i < @subtypes; $i++)
    {
	my $type = $subtypes[$i];
	my $jtype = $elt_types[$i];
	my $jclass;
	if ($type->can("java_type_expression"))
	{
	    $jclass = $type->java_type_expression();
	}
	if (!$jclass)
	{
	    if ($jtype =~ /</)
	    {
		$jclass = "new TypeReference<$jtype>(){}";
	    }
	    else
	    {
		$jclass = $jtype . ".class";
	    }
	}
	push(@$elts, {
	    name => $names[$i],
	    type => $subtypes[$i],
	    java_type => $elt_types[$i],
	    java_class => $jclass,
	});
    }
    push(@{$struct_types->{tuples}}, $tup);
    
    
    return $tuple_name;
}


sub construct_struct
{
    my($module_name, $type, $struct_types) = @_;

    my $struct_name;
    if ($type->has_name)
    {
	$struct_name = $type->name;
    }
    else
    {
	#
	# Unnamed struct. Assign one based on _next_struct in the struct_types hash.
	#
	
	my $n = $struct_types->{_next_struct}++;
	$struct_name = "${module_name}_struct_$n";
    }


    my @items = @{$type->items};
    my @subtypes = map { $_->item_type } @items;
    my @names = map { $_->name } @items;

    my @elt_types = map { map_type_to_java($module_name, $_, $struct_types) } @subtypes;

    my $elts = [];
    my $tup = { name => $struct_name, elements => $elts };
    $tup->{comment} = $type->comment if $type->has_comment;
    
    for (my $i = 0; $i < @subtypes; $i++)
    {
	my $type = $subtypes[$i];
	my $jtype = $elt_types[$i];
	my $jclass;
	if ($type->can("java_type_expression"))
	{
	    $jclass = $type->java_type_expression();
	}
	if (!$jclass)
	{
	    if ($jtype =~ /</)
	    {
		$jclass = "new TypeReference<$jtype>(){}";
	    }
	    else
	    {
		$jclass = $jtype . ".class";
	    }
	}
	push(@$elts, {
	    name => $names[$i],
	    type => $subtypes[$i],
	    java_type => $elt_types[$i],
	    java_class => $jclass,
	});
    }
    push(@{$struct_types->{structs}}, $tup);
    
    return $struct_name;
}

sub compute_module_data
{
    my($module, $type_info, $type_table) = @_;

    my $doc = $module->comment;
    $doc =~ s/^\s*\*\s?//mg;
    
    my $impl_package_name = $module->module_name . "Impl";

    my %saved_stub;
    my $saved_header;
    my $saved_const;

    my $impl_file = "$dir/$impl_package_name.pm";
    if (open(my $fh, "<", $impl_file))
    {
	#
	# Collect old client implementation code.
	#
	my $cur_rtn;
	my $cur_hdr;
	my $cur_const;
	while (<$fh>)
	{
	    if (/^\s*\#BEGIN\s+(\S+)/)
	    {
		$cur_rtn = $1;
	    }
	    elsif (/^\s*\#END\s+(\S+)/)
	    {
		undef $cur_rtn;
	    }
	    elsif ($cur_rtn)
	    {
		$saved_stub{$cur_rtn} .= $_;
	    }
	    elsif (/^\s*\#BEGIN_HEADER\s*$/)
	    {
		$cur_hdr = 1;
	    }
	    elsif (/^\s*\#END_HEADER\s*$/)
	    {
		$cur_hdr = 0;
	    }
	    elsif (/^\s*\#BEGIN_CONSTRUCTOR\s*$/)
	    {
		$cur_const = 1;
	    }
	    elsif (/^\s*\#END_CONSTRUCTOR\s*$/)
	    {
		$cur_const = 0;
	    }
	    elsif ($cur_hdr)
	    {
		$saved_header .= $_;
	    }
	    elsif ($cur_const)
	    {
		$saved_const .= $_;
	    }
	}
	close($fh);
    }

    my $methods = [];

    my $vars = {
	impl_package_name => $impl_package_name,
	module_name => $module->module_name,
	module => $module,
	module_doc => $doc,
	methods => $methods,
	types => $type_info,
    };

    for my $comp (@{$module->module_components})
    {
	next unless $comp->isa('Bio::KBase::KIDL::KBT::Funcdef');

	my $params = $comp->parameters;
	my @args;
	my %ncount;

	for my $i (0..$#$params)
	{
	    my $p = $params->[$i];

	    my $name;
	    if ($p->{name})
	    {
		$name = $p->{name};
	    }
	    else
	    {
		#
		# if we didn't pass in a name, and if
		# this parameter is a typedef, use the type name.
		#
		if (ref($p->{type}) && $p->{type}->can('alias_type'))
		{
		    $name = $p->{type}->name;
		}
		else
		{
		    $name = "arg_" . ($i + 1);
		}
	    }
	    push(@args, $name);
	    $ncount{$name}++;
	}

	#
	# Scan args for duplicates and disambiguate.
	#
	for my $argi (0..$#args)
	{
	    if ($ncount{$args[$argi]} > 1)
	    {
		$args[$argi] .= "_" . ($argi + 1);
	    }
	}
	#
	# Generate english type descriptions.
	#
	my %types_seen;
	my $typenames = [];
	my @english;
	
	for my $argi (0..$#args)
	{
	    my $name = $args[$argi];
	    my $p = $params->[$argi];
	    my $type = $p->{type};
	    my $eng = $type->english(1);
	    my $tn = $type->subtypes(\%types_seen);
	    # print "arg $argi $type subtypes @$tn\n";
	    push(@$typenames, @$tn);
	    push(@english, "\$$name is $eng");
	}

	my $args = join(", ", @args);
	my $arg_vars = join(", ", map { "\$$_" } @args);

	my $returns = $comp->return_type;
	
	my @rets;

	if (@$returns == 1)
	{
	    my $p = $returns->[0];
	    my $name = $p->{name} // "return";
	    push(@rets, $name);
	    my $tn = $p->{type}->subtypes(\%types_seen);
	    push(@$typenames, @$tn);
	    my $eng = $p->{type}->english(1);
	    push(@english, "\$$name is $eng");
	}
	else
	{
	    for my $i (0..$#$returns)
	    {
		my $p = $returns->[$i];
		my $name = $p->{name} // "return_" . ($i + 1);
		push(@rets, $name);
		my $tn = $p->{type}->subtypes(\%types_seen);
		push(@$typenames, @$tn);
		my $eng = $p->{type}->english(1);
		push(@english, "\$$name is $eng");
	    }
	}
	my $rets = join(", ", @rets);
	my $ret_vars = join(", ", map { "\$$_" } @rets);

	for my $tn (@$typenames)
	{
	    my $type = $type_table->{$tn};
	    if (!defined($type))
	    {
		die "Type $tn is not defined in module " . $module->module_name . "\n";
	    }

	    push(@english, "$tn is " . $type->alias_type->english(1));
	}
	
	my $doc = $comp->comment;
	$doc =~ s/^\s*\*\s?//mg;

	chomp @english;

	my $meth = {
	    name => $comp->name,
	    arg_doc => [grep { !/^\s*$/ } @english],
	    doc => $doc,
	    args => $args,
	    arg_vars => $arg_vars,
	    rets => $rets,
	    ret_vars => $ret_vars,
	    arg_count => scalar @args,
	    user_code => $saved_stub{$comp->name},
	};
	push(@$methods, $meth);
    }
    return $vars;
}

sub assemble_types
{
    my($parser) = @_;

    my $types = [];

    my $typelist = $parser->types() // [];
    for my $type (@$typelist)
    {
	my $name = $type->name;
	my $ref = $type->alias_type;
	my $eng = $ref->english(0);
	push(@$types, {
	    name => $name,
	    ref => $ref,
	    english => $eng,
	    comment => $type->comment,
	     });
    }
    return $types;
}
__DATA__
