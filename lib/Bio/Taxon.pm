package Bio::Taxon;
use Mojo::Base 'Mojo::EventEmitter', -base, -signatures, -async_await;
use Mojo::Log;
use Syntax::Keyword::Try;
use List::Util qw(any);
use Bio::Utils qw( find_services read_config )
use Time::HiRes qw(tv_interval);
use namespace::autoclean;

has config => sub { read_config };

# set logging service
has log => sub { state $log = Mojo::Log->new };

# services list
has services => sub {
    # find all services (modules) given the namespace
    my $services = find_services( __PACKAGE__ . '::Services' );

    # load services modules
    return $services->grep( 
        sub {  
            my $service = $_;
            any { $_ eq $service->name } @{ $config->disabled_services }
        }
    )->each( sub { $_->new } );
};

# timeout limit in seconds
has timeout => sub { 1 };

#
# async search using a partial term 
#
async sub search_term( $self, $term ) {

    foreach my $service ( $self->services->each ) {
        try {
            my $res = await $service->search_p($term)->timeout($self->timeout);
            $self->emit(found => $service->req_details);
            $self->log->debug("got results for '$term' using '$service->name'");
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

