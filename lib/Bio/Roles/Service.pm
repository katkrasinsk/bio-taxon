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

# TODO: paralalle safe: manage queue
#has pending => sub { Mojo::Collection->new([]) };

requires qw( search_p );

# start timer during search
before 'search_p' => sub($self, $term) {
    my $request = {
        service => $self->name,
        term => $term,
        start_time => [gettimeofday],
    };

    #TODO: manage pending
    $self->req_details( $request );
};

# control cache/service search update
around 'search_p' => sub($orig, $self, @args) {
    my $term = $args[0];
    my $p = $self->$orig(@args); # call original
    my $details = $self->req_details;
    # TODO: manage pending request
    # push @{$self->pending}, $p;

    # check cache first
    if ( my $res = $self->cache->get($term) ) {
        $details->{ origin } = 'cached';
        $details->{ results } = $res;
        $p->resolve( $details );
    } 
    # get data and process: add metadata, normalize and save in cache
    else {
        $p->then(
            sub($res) {
                $details->{ origin } = 'web-service';
                $details->{ service_time } = tv_interval( $details->{ start_time } ); # t - t0
                delete $details->{start_time}; # discard t0
                my $data = $details->{ results } = $self->normalize($res->result->json);
                $self->cache->save($term, $data);
                return $details->{ results };
            }
        )->catch(
            sub($err) {
                warn "Error while processing data from " . $details->{ service };
                warn "$err";
            }
        );
    }

    return $p;
};

# default normalization: do nothing
sub normalize( $self, $data ) {
    return $data;
}

1;
