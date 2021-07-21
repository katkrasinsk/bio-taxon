package Bio::Roles::Service;
use Mojo::Base -base, -role, -signatures;
use Time::HiRes qw(gettimeofday tv_interval);
use Mojo::UserAgent;
use Bio::Taxon::Cache;
use namespace::autoclean;

has name => sub { die 'name attribute for service is required' };
has description => sub { '' }; # service optional description
has req_details => sub { die 'No request done yet' };
has cache => sub { Bio::Taxon::Cache->new };
has base_url => sub { die 'Base url for web service is required' };
has ua => sub { Mojo::UserAgent->new };
has taxon => sub { die 'required Bio::Taxon' };

# TODO: paralalle safe: manage queue
#has pending => sub { Mojo::Collection->new([]) };

requires qw( search_p );

#TODO: manage pending
# start timer during search
before 'search_p' => sub($self, $term) {
    my $request = {
        service => $self->name,
        term => $term,
        start_time => [gettimeofday],
        results => [],
    };

    $self->req_details( $request );
};

# TODO: manage pending request
# control cache/service search update
around 'search_p' => sub($orig, $self, @args) {
    my $term = $args[0];
    my $p = $self->$orig(@args); # call original
    my $details = $self->req_details;

    # data from cache
    if ( my $data = $self->cache->get($term) ) {
        $details->{ origin } = 'cached';
        $details->{ results } = $data;
        $p->resolve( $details );
    } 
    # data from web: add metadata, normalize and save in cache
    else {
        $p->then(
            sub($res) {
                $details->{ origin } = 'web-service';
                $details->{ service_time } = tv_interval( $details->{ start_time } ); # t - t0
                delete $details->{start_time}; # discard t0
                my $data = $details->{ results } = $self->normalize($res->result->json);
                if ( $data && $self->taxon->cache_enabled ) {
                    $self->cache->save($term, $data);
                }
            }
        )->catch(
            sub($err) {
                my $warn = sprintf "Error (%s), while processing data from %s", 
                $err, $details->{ service };
                Carp::carp($warn);
            }
        );
    }

    return $p;
};

# TODO: normalize data
# default normalization: do nothing
sub normalize( $self, $data ) {
    return $data;
}

1;
