package Bio::Utils;
use Mojo::Base -strict, -signatures;
use Carp qw(confess croak);
use Mojo::Loader qw(find_modules load_class);
use Mojo::File;
use List::Util qw( first );
use YAML qw(LoadFile);
require Exporter;
our @ISA = qw(Exporter);

# config order to be read
our @Conf = map { Mojo::File->new($_) }
grep { $_ } ( $ENV{TAXON_CONF}, qw(./taxon.yml ~/.taxon.yml) );

our @EXPORT_OK = qw( find_services read_config );

#
# find all service modules and load them
#
sub find_services ( $namespace ) {
    my @services;
    for my $service (find_modules $namespace) {
        my $e = load_class($service);
        croak "Error loading $service: $e" if $e;
        push @services, $service->new;
    }

    return Mojo::Collection->new(@services);
}

#
# read and parse config content
#
sub read_config {
    my $conf_file = first { $_ && -f "$_"  } @Conf;
    croak "No conf file found\n" unless $conf_file;
    return LoadFile("$conf_file") || croak "Parse Error for '$conf_file': $@";
}

1;
