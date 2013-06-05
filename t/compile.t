use Test::More;

use lib qw(blib);
unless (-e "t/script") {mkdir "t/script" or die "can not make dir t/script";}
unless (-e "t/lib") {mkdir "t/lib" or die "can not make t/lib";}
my $rv = system "blib/script/compile_typespec.pl --scripts t/script --psgi service.psgi t/MyFirstService.spec t/lib";
ok($rv==0, "$?, $!");

my $rv = system "blib/script/compile_typespec.pl --scripts t/script --psgi service.psgi t/MyFirstAuthenticatedService.spec t/lib";
ok($rv==0, "$?, $!");

done_testing;

