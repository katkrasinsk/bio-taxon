use strict;
use Test::More;
use Bio::Taxon;

# make test silent
my $b = Bio::Taxon->new->tap( sub { $_->log->level('fatal') } );

subtest 'check all services' => sub {
    isa_ok $b->services, 'Mojo::Collection', "services set";
    my $size = $b->services->size;
    ok $size == 4, "Has total services implemented of $size";
    is_deeply 
            [ sort @{$b->services->map( sub { $_->name } )} ],
            [ sort qw(GBIF WoRMS WikiAves COL) ], 'Services correct name';
};

subtest 'find terms concurrently' => sub {
    plan skip_all => 'set TEST_ONLINE to enable it' unless $ENV{TEST_ONLINE};

    $b->timeout(12); #set large timeout
    my $animal = 'larus dominicanus';

    my $cb = sub {
        my (undef, $res) = @_;
        ok $res, 'have a result';
        isa_ok $res, 'HASH', 'results is a hash';
        ok $res->{term} eq $animal, "search term is correct";
        is_deeply 
            [sort keys %$res],
            [sort qw(term service service_time start_time results origin)],
            "hash structure for results is ok" or note explain $res;
        delete $res->{results}; #don't show results but show other fields
        note explain $res;
    };

    $b->on( found => $cb );

    $b->search_concurrently($animal)
    ->then( sub { ok @_ > 0, 'got total results: ' . @_; })
    ->catch( sub { fail "something happened"; note explain @_; })
    ->wait;

    $b->unsubscribe( found => $cb );
};

subtest 'check timeout' => sub {
    local $SIG{__WARN__} = sub { }; # silence warnings
    $b->timeout(0.01);              # force timeout
    $b->search_term('any one')
    ->then( sub { fail "promise not timeout"; })
    ->catch( sub { like shift, qr/timeout/i, "promise timeout ok"; })
    ->wait;
};

done_testing;
