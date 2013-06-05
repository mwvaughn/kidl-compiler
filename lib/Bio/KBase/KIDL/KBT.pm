package Bio::KBase::KIDL::KBT;
use Bio::KBase::KIDL::KBT::Funcdef;
use Bio::KBase::KIDL::KBT::Mapping;
use Bio::KBase::KIDL::KBT::List;
use Bio::KBase::KIDL::KBT::Tuple;
use Bio::KBase::KIDL::KBT::Scalar;
use Bio::KBase::KIDL::KBT::Struct;
use Bio::KBase::KIDL::KBT::StructItem;
use Bio::KBase::KIDL::KBT::Typedef;
use Bio::KBase::KIDL::KBT::Typeref;
use Bio::KBase::KIDL::KBT::ExtTyperef;
use Bio::KBase::KIDL::KBT::DefineModule;
use Bio::KBase::KIDL::KBT::UseModule;

use strict;
use File::Spec;

sub install_path
{
    return File::Spec->catpath((File::Spec->splitpath(__FILE__))[0,1], '');
}


1;
