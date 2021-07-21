use strict;
use Test::More;
use Bio::Taxon;

my $DEBUG = $ENV{TAXON_TEST_DEBUG};
our @SERVICES = qw(GBIF WoRMS WikiAves COL);
our @RES_KEYS = qw(term service service_time results origin);

# make test silent
my $b = Bio::Taxon->new->tap( sub { $_->log->level('fatal') } );

subtest 'check all services' => sub {
    isa_ok $b->services, 'Mojo::Collection', "services set";
    my $size = $b->services->size;
    ok $size == 4, "Has total services implemented of $size";
    is_deeply 
    [ sort @{$b->services->map( sub { $_->name } )} ],
    [ sort @SERVICES ], 'Services correct name';
};

subtest 'find terms concurrently' => sub {
    plan skip_all => 'set TEST_ONLINE to enable it' unless $ENV{TEST_ONLINE};

    $b->timeout(12); #set large timeout
    my $animal = 'larus dominicanus';

    my $tests = sub {
        my (undef, $res) = @_;
        ok $res, 'have a result';
        isa_ok $res, 'HASH', 'results is a hash';
        ok $res->{term} eq $animal, "search term is correct";
        is_deeply 
        [sort keys %$res],
        [sort @RES_KEYS],
        "hash structure for results is ok" or note explain $res;
        delete $res->{results}; #don't show results but show other fields
        note explain $res if $DEBUG;
    };

    $b->on( found => $tests );

    $b->search_concurrently($animal)
    ->then(sub { ok @_ == 1, ' results should be only one'; })
    ->catch(sub { fail "something happened"; note explain @_ if $DEBUG; })
    ->wait;

    $b->unsubscribe( found => $tests );
};

subtest 'check timeout' => sub {
    local $SIG{__WARN__} = sub { }; # silence warnings
    $b->timeout(0.01);              # force timeout
    $b->search_concurrently('any one')
    ->then(
        sub { 
            like (shift->{error}, qr/timeout/i, "promise timeout ok")
                or note explain @_;
        }
    )->catch(sub { fail "promise did not timeout"; note explain @_ if $DEBUG; })
    ->wait;
};

done_testing;
