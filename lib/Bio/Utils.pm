package Bio::Utils;
use Mojo::Base -strict, -signatures;
use Carp qw(confess);
use Mojo::Loader;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw( time_in_miliseconds find_services read_config );

sub time_in_miliseconds( $start ) {
    confess "Not implemented yet";
}

sub find_services {
    confess "Not implemented yet";
}

sub read_config {
    confess "Not implemented yet";
}

1;
