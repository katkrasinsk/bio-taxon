package Bio::Taxon;
use Mojo::Base 'Mojo::EventEmitter', -base, -signatures, -async_await;
use Mojo::Log;
use Syntax::Keyword::Try;
use List::Util qw(any);
use Bio::Utils qw(find_services read_config);
use Time::HiRes qw(tv_interval);
use Safe::Isa;
use namespace::autoclean;

our $VERSION = "0.01";

# config read only once
has config => sub ($self) { state $config = read_config; };

# set logging service
has log => sub { state $log = Mojo::Log->new->level(shift->config->{log_level}) };

# services list
has services => sub ($self) {
    # find all services (modules) given the namespace
    my $services = find_services( __PACKAGE__ . '::Services' );

    # load services modules
    return $services->grep( 
        sub {  
            my $service = $_;
            any { !($_ eq $service->name) } @{ $self->config->{disabled_services} || [] }
        }
    )->each( sub { $_ } );
};

# timeout limit in seconds
has timeout => sub { 4 };

#
# async search using a partial term 
#
async sub search_term( $self, $term ) {
    $self->log->debug('begin searching');
    my @res;

    foreach my $service ( $self->services->each ) {
        try {
            my $res = await $service->search_p($term)->timeout($self->timeout);
            push @res, $res->$_can('result') ? $res->result->json : $res;
            $self->emit(found => $service->req_details);
            $self->log->debug(sprintf "got results for '%s' using '%s'", $term, $service->name);
        } catch ( $e ) {
            $self->log->error(sprintf qq{Error searching for "%s", on "%s", details: '%s'}, $term, $service->name, "$e");
            $self->emit(error => $e);
        }
    }

    return @res;
}

1;

__END__

=encoding utf-8

=head1 NAME

Bio::Taxon - Searches through different web services for animal scientific taxa data.

=head1 SYNOPSIS

    use Bio::Taxon;
    my $promises = Bio::Taxon->new->search_term('larus dominicanus');
    my @res;
    $promises->each( sub { $_->then( sub { push @res, shift } } );
    say @res;

=head1 DESCRIPTION

Bio::Taxon is module to search various scientific Web API about animals data
given species name.

=head1 LICENSE

Copyright (C) Marco Arthur.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Marco Arthur E<lt>arthurpbs@gmail.comE<gt>

=cut

