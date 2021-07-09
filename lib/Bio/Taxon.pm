package Bio::Taxon;
use Mojo::Base 'Mojo::EventEmitter', -base, -signatures, -async_await;
use Mojo::Log;
use Syntax::Keyword::Try;
use List::Util qw(any);
use Bio::Utils qw( time_in_miliseconds find_services read_config )


# set logging service
has log => sub { state $log = Mojo::Log->new };

has config => sub { read_config };

# services list
has services => sub {
    # find all services (modules) given the namespace
    my $services = find_services( $namespace );

    # load services modules
    return $services->grep( 
        sub {  
            my $service = $_;
            any { $_ eq $service->name } @{ $config->disabled_services }
        }
    )->each( sub { $_->new } );
};

# timeout limit in seconds
has tm_limit => sub { 1 };

#
# async search using a partial term 
#
async sub search_partially( $self, $term ) {

    foreach my $service ( $self->services->each ) {
        my $start = time;
        my $found = { service => $service->name, term => $term };

        if ( my $res = $self->cache(from => $service)->get($term) ) {
            @$found{qw(results cached response_time)} = ($res, 1, time_in_miliseconds($start));
            $self->emit( found => $found );
            next;
        }

        try {
            my $res = await $service->search_p($term)->timeout($self->tm_limit);
            $found->{results} = $res->result->json;
            $self->cache(from => $service)->save($term, $found);
            $found->{response_time} = time_in_miliseconds($start);
            $self->emit(found => $found);
            $self->log->debug("got results for '$term' using '$service->name");
        } catch ( $e ) {
            $self->emit( error => $e );
            $self->log->error(qq{Error searching for "$term", on "$service->name", details: '$e'});
            next;
        }
    }

    return $self;
}


1;
__END__

=encoding utf-8

=head1 NAME

Bio::Taxon - It's new $module

=head1 SYNOPSIS

    use Bio::Taxon;

=head1 DESCRIPTION

Bio::Taxon is ...

=head1 LICENSE

Copyright (C) Marco Arthur.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Marco Arthur E<lt>arthurpbs@gmail.comE<gt>

=cut

