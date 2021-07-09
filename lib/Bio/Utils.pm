package Bio::Utils;
use Mojo::Base -strict, -signatures;
use Carp qw(confess);
use Mojo::Loader qw(find_modules);
use Mojo::File;
use List::Util qw( first );
use YAML;
require Exporter;
our @ISA = qw(Exporter);

# config order to be read
our @Conf = map {
    my $f = Mojo::File->new($_); 
} ( $ENV{TAXON_CONF}, qw(./taxon.yml ~/.taxon.yml) );

our @EXPORT_OK = qw( time_in_miliseconds find_services read_config );

#
# find all service modules and load them
#
sub find_services ( $namespace ) {
    confess "Not implemented yet";
}

#
# read and parse config content
#
sub read_config {
    my $conf_file = first { -f "$_" } @Conf;
    croak "No conf file found\n" unless $conf_file;
    return LoadFile("$conf_file") || croak "Parse Error for '$conf_file': $@";
}

1;
