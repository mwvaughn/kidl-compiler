package Bio::KBase::Auth;
#
# Common information across the apps
#
# sychan 4/24/2012
use strict;
use Config::Simple;
use MongoDB;

our $VERSION = '0.6.0';

our $ConfPath = glob "~/.kbase_config";

if (defined($ENV{ KB_DEPLOYMENT_CONFIG })) {
    if ( -r $ENV{ KB_DEPLOYMENT_CONFIG }) {
	$ConfPath = $ENV{ KB_DEPLOYMENT_CONFIG };
    } else {
	die "\$ENV{KB_DEPLOYMENT_CONFIG} points to an unreadable file: ".$ENV{ KB_DEPLOYMENT_CONFIG };
    }
}

my $c = Config::Simple->new( $ConfPath);
our %Conf = $c ? $c->vars() : {};
our %AuthConf = map { $_, $Conf{ $_} } grep /^authentication\./, keys( %Conf);
our $AuthSvcHost = $Conf{'authentication.servicehost'} ?
    $Conf{'authentication.servicehost'} : "https://nexus.api.globusonline.org/";

our $AuthorizePath = $Conf{'authentication.authpath'} ?
    $Conf{'authentication.authpath'} : "/goauth/token";

our $ProfilePath = $Conf{'authentication.profilepath'} ?
    $Conf{'authentication.profilepath'} : "users";

our $RoleSvcURL = $Conf{'authentication.rolesvcurl'} ?
    $Conf{'authentication.rolesvcurl'} : "https://kbase.us/services/authorization/Roles";

# handle to a MongoDB Connection
our $MongoDB = undef;

eval {
    if ($Conf{'authentication.mongodb'} ) {
	$MongoDB = MongoDB::Connection->new( host => $Conf{'authentication.mongodb'});
    }
};

if ($@) {
    die "Invalid MongoDB connection declared in ".$ConfPath." authentication.mongodb = ".
	$Conf{'authentication.mongodb'};
}

# Load a new config file to override the default settings
sub LoadConfig {
    my( $ConfPath) = shift;

    my $c = Config::Simple->new( $ConfPath);
    my %Conf = $c ? $c->vars() : {};
    $AuthSvcHost = $Conf{'authentication.servicehost'} ?
	$Conf{'authentication.servicehost'} : $AuthSvcHost;
    
    $AuthorizePath = $Conf{'authentication.authpath'} ?
	$Conf{'authentication.authpath'} : $AuthSvcHost;
    
    $ProfilePath = $Conf{'authentication.profilepath'} ?
	$Conf{'authentication.profilepath'} : $ProfilePath;
    
    $RoleSvcURL = $Conf{'authentication.rolesvcurl'} ?
	$Conf{'authentication.rolesvcurl'} : $RoleSvcURL;

    $MongoDB = $Conf{'authentication.sessiondb'} ?
	$Conf{'authentication.sessiondb'} : $MongoDB;

}

1;

__END__
=pod

=head1 Bio::KBase::Auth

OAuth based authentication for Bio::KBase::* libraries.

This is a helper class that stores shared configuration information.

=head2 Class Variables

=over

=item B<$ConfPath>

   The path to the INI formatted configuration file. Defaults to ~/.kbase_config, can be overriden by the shell environment variable $KB_DEPLOYMENT_CONFIG. Configuration directives for the Bio::KBase::Auth, Bio::KBase::AuthToken and Bio::KBase::AuthUser classes are loaded from the "authentication" section of the INI file.

=item B<%Conf>

   A hash containing the full contents loaded from ConfPath (if any). This includes stuff outside of the authentication section.

=item B<%AuthConf>

   A hash containing only the directives that begin with "authentication." in %Conf

=item B<$VERSION>

   The version of the libraries.

=item B<$AuthSvcHost>

   A string specifying the base URL for the authentication and profile service. It defaults to "https://nexus.api.globusonline.org/". Set by 'authentication.servicehost' entry in .kbase_config

=item B<%AuthorizePath>

   The path beneath $AuthSvcHost that supports authentication token requests, defaults to "/goauth/token". Set by 'authentication.authpath' in .kbase_config

=item B<$ProfilePath>

   The path under $AuthSvcHost that returns user profile information, defaults to "users". Set by 'authentication.profilepath' in .kbase_config

=item B<$RoleSvcURL>

   The URL used to query for roles/groups information, defaults to "https://kbase.us/services/authorization/Roles". Set by 'authentication.rolesvcurl' in .kbase_config

=item B<$MongoDB>

   A MongoDB::Connection reference that can be activated by defining authentication.mongodb in the configuration file. The value of authentication.mongodb is passed in as the value of the host parameter in the MongoDB::Connection->new() call. The MongoDB connection is used for access to server-side caching features and is not needed for normal operation.

=back

=cut

