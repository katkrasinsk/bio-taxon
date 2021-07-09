package Bio::Roles::Service;
use Mojo::Base -role, -signatures;
use Time::HiRes qw(gettimeofday);
use Bio::Taxon::Cache;

has name => sub { die 'name attribute for service is required' };
has description => sub { '' }; # service optional description
has req_details => sub { die 'No request done yet' };
has cache => sub { Bio::Taxon::Cache->new };
has base_url => sub { die 'Base url for web service is required' };
has ua => sub { Mojo::UserAgent->new };

# TODO: queue safe
#has pending => sub { Mojo::Collection->new([]) };

required qw( search_p );

# start timer during search
before 'search_p' => sub($self, $term) {
    my $request = {
        service => $self->name,
        term => $term,
        start_time => gettimeofday,
    };

    #TODO: manage pending
    $self->req_details( $request );
};

# control cache/service search update
around 'search_p' => sub($orig, $self, @args) {
    my $term = $args[0];
    my $p = $self->$orig(@args); # call original
    my $details = $self->req_details;
    # TODO: manage pending -> add
    #push @{$self->pending}, $p;

    # check on cache
    if ( my $res = $self->cache->get($term) ) {
        $details->{ origin } = 'cached';
        $details->{ results } = $res;
        $p->resolve( $details );
    } else {
        # attach callback to save the results into cache
        $p->then(
            sub($res) {
                $details->{ origin } = 'web-service';
                $details->{ service_time } = tv_interval( $details->{ start_time } );
                $details->{ results } = $res->results->json;
                # save in cache
                $self->cache->save($term, $res->results->json);
                # manage pending -> remove
                #$self->pending->remove($p);
                return $details->{ results };
            }
        );
    }

    return $p;
};


1;
