use strict;
use Test::More;
use Bio::Taxon;

my $b = Bio::Taxon->new;
$b->on( 
    found => sub {
        my (undef, $res) = @_;
        ok $res, 'found result';
        note explain $res;
    }
);

subtest 'basic api tests' => sub {
    my $animal = 'larus dominicanus';

    $b->search_term($animal)->then(
        sub {
            ok 1, 'complete the search';
            #note explain @_;
        }
    )->catch(
        sub {
            fail "something happened";
            note explain @_;
        }
    )->wait;
};

done_testing;
