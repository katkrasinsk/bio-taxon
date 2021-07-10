use strictures 2;
use Bio::Taxon;
use 5.028;
use DDP;

my $taxon = Bio::Taxon->new;

$taxon->on( found => 
    sub {
        my (undef, $results) = @_;
        p $results;
    }
);

while( 1 ) {
    printf "Search for an animal: ";
    my $input = <>;
    chomp $input;
    if ( $input =~ /quit/ ) {
        break;
    }
    $taxon->search_term($input)->wait;
    say '===' x 60;
}

exit 0;
