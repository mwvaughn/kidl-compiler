use ExtUtils::MakeMaker;

WriteMakefile (
	NAME	=> 'Bio::Kbase::KIDL::KBT',
	# VERSION_FROM	=> 'lib/Bio/KBase/KIDL/KBT/KBT.pm',
	VERSION	=> '1.0',
	AUTHOR	=> 'Robert Olson',
	EXE_FILES	=> ['scripts/compile_dbd_to_typespec.pl',
                            'scripts/compile_typespec.pl',
                            'scripts/gen_java_client.pl',
	],
	MIN_PERL_VERSION => '5.10.0',
	PREREQ_PM => {
		Lingua::EN::Inflect    => '1.895',
               Data::Dumper           => '2.130_02',
               Template               => '2.24',
               File::Slurp            => '0',
               File::Basename         => '0',
               File::Path             => '2.08_01',
               Getopt::Long           => '0',
               Parse::Yapp::Driver    => '1.05',
               Devel::StackTrace      => '1.30',
               File::Spec             => '3.33',
               Moose                  => '2.0604',
	},
	LICENSE	=> 'mit',
);
