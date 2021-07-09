package Bio::Taxon;
use Mojo::Base 'Mojo::EventEmitter', -base, -signatures, -async_await;
use Mojo::Log;
use Syntax::Keyword::Try;
use List::Util qw(any);
use Bio::Utils qw( find_services read_config );
use Time::HiRes qw(tv_interval);
use namespace::autoclean;

has config => sub { read_config };

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
    )->each( sub { $_->new } );
};

# timeout limit in seconds
has timeout => sub { 2 };

#
# async search using a partial term 
#
async sub search_term( $self, $term ) {
    $self->log->debug('begin searching');
    my @res;

    foreach my $service ( $self->services->each ) {
        try {
            my $res = await $service->search_p($term)->timeout($self->timeout);
            push @res, $res->result->json;
            $self->emit(found => $service->req_details);
            $self->log->debug(sprintf "got results for '%s' using '%s'", $term, $service->name);
        } catch ( $e ) {
            $self->emit(error => $e);
            $self->log->error(sprintf qq{Error searching for "%s", on "%s", details: '%s'}, $term, $service->name, "$e");
            next;
        }
    }

    return @res;
}


1;

__END__

=encoding utf-8

=head1 NAME

Bio::Taxon - Searches throw diferent web services for animal scientific data.

=head1 SYNOPSIS

    use Bio::Taxon;
    my $promises = Bio::Taxon->new->search_term('larus dominicanus');
    my @res;
    $promises->each( sub { $_->then( sub { push @res, shift } } );
    say @res;

=head1 DESCRIPTION

Bio::Taxon is module to search various scientific api information about animals
given species name.

=head1 LICENSE

Copyright (C) Marco Arthur.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Marco Arthur E<lt>arthurpbs@gmail.comE<gt>

=cut

