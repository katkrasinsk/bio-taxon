use strict;
use Test::More;
use Bio::Taxon;

my $b = Bio::Taxon->new;
$b->on( 
    found => sub {
        my (undef, $res) = @_;
        ok $res, 'found result';
        isa_ok $res, 'HASH';

        is_deeply [sort keys %$res], [sort qw(term service service_time start_time results origin)];
        #note explain $res;
    }
);

subtest 'basic api tests' => sub {
    my $animal = 'larus dominicanus';

    $b->search_term($animal)->then(
        sub {
            ok @_ > 0, 'got total #result ' . @_;
        }
    )->catch(
        sub {
            fail "something happened";
            note explain @_;
        }
    )->wait;
};

done_testing;
