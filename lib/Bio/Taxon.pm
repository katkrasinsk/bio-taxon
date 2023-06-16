package Bio::Taxon;
use Mojo::Base 'Mojo::EventEmitter', -base, -signatures, -async_await;
use Mojo::Log;
use Syntax::Keyword::Try;
use List::Util qw(any);
use Bio::Utils qw(find_services read_config);
use Time::HiRes qw(tv_interval);
use Safe::Isa;
use namespace::autoclean;
use constant TIMEOUT = $ENVS{BT_TIMEOUT} || 4;

our $VERSION = "0.01";

# config read only once
has config => sub ($self) { state $config = read_config; };

# set logging service
has log => sub { state $log = Mojo::Log->new->level(shift->config->{log_level}) };

# services list
has services => sub ($self) {
    # find all services (modules) given the namespace
    # TODO: filter disabled from config
    return find_services( __PACKAGE__ . '::Services' );
};

# timeout limit in seconds
has timeout => sub { TIMEOUT };

#
# searchs without concurrency
#
async sub search_term( $self, $term ) {
    $self->log->debug('begin searching');
    my @res;

    foreach my $service ( $self->services->each ) {
        try {
            # this prevents concurrency, we await each search
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

#
# Search $term in all services concurrently
#
async sub search_concurrently( $self, $term ) {
    $self->log->debug("concurrently searching for '$term'");

    my @p = $self->services->map( 
        sub ($service) { 
            $service->search_p($term)->timeout($self->timeout)
            ->then( sub{ $self->emit( found => $service->req_details ) })
            ->catch(
                sub($e) {
                    $self->log->error(
                        sprintf qq{Error searching for "%s", on "%s", details: '%s'},
                        $term, $service->name, "$e"
                    );
                    # Should we emit error ?
                    # $self->emit(error => $e);
                }
            );
        }
    )->@*;

    # start concurrently search in all services
    my @res = await Mojo::Promise->all_settled(@p);

    return @res;
}

1;

__END__

=encoding utf-8

=head1 NAME

Bio::Taxon - Searches through different web services for animal scientific taxa data.

=head1 SYNOPSIS

    use Bio::Taxon;
    my $bt = Bio::Taxon->new(timeout => 5);
    my @res;
    $bt->on( found => sub { push @res, $_[1] } );
    $bt->search_concurrently('egretta thula')->wait;
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

