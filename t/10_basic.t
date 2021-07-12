use strict;
use Test::More;
use Bio::Taxon;

my $b = Bio::Taxon->new;
$b->log->level('fatal'); # make test silent

subtest 'check services' => sub {
    isa_ok $b->services, 'Mojo::Collection', "services set";
    my $size = $b->services->size > 0;
    ok $size > 0, "Has total services implemented of $size";
    #TODO: check it implements Service Role
};

subtest 'find terms concurrently' => sub {
    plan skip_all => 'set TEST_ONLINE to enable it' unless $ENV{TEST_ONLINE};
    $b->timeout(10); #set sufficient big timeout
    my $cb = sub {
        my (undef, $res) = @_;
        ok $res, 'have a result';
        isa_ok $res, 'HASH', 'results is a hash';

        ok $res->{term} eq 'larus dominicanus', "search term is correct";
        is_deeply 
        [sort keys %$res],
        [sort qw(term service service_time start_time results origin)],
        "hash structure for results is ok" or note explain $res;
        delete $res->{results};
        note explain $res;
    };

    $b->on( found => $cb );
    my $animal = 'larus dominicanus';

    $b->search_concurrently($animal)->then(
        sub {
            ok @_ > 0, 'got total results: ' . @_;
        }
    )->catch(
        sub {
            fail "something happened";
            note explain @_;
        }
    )->wait;
    $b->unsubscribe( found => $cb );
};

subtest 'timeout' => sub {
    local $SIG{__WARN__} = sub { }; # silence warnings
    $b->timeout(0.01); # force timeout
    my $animal = 'lobodon';
    $b->search_term($animal)->then(
        sub {
            fail "promise not timeout";
        }
    )->catch(
        sub {
            like shift, qr/timeout/i, "promise timeout ok";
        }
    )->wait;
};

done_testing;
