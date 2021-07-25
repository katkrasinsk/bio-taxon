use strictures 2;
use Bio::Taxon;
use 5.028;
use Term::Choose qw(choose);
use Term::Size;
use DDP;

my ($cols, $rows) = Term::Size::chars();
my $taxon = Bio::Taxon->new( timeout => 12 );
say "Choose one Service";
my $choose = choose($taxon->enabled);
$taxon->enabled( [$choose] );
$taxon->on( 
    found => sub {
        my (undef, $results) = @_;
        p $results;
    }
);

while( 1 ) {
    printf "Search for an animal (Empty or 'quit' to exit): ";
    chomp( my $input = <> || "");
    if ( !$input || $input =~ /quit/ ) {
        last;
    }
    $taxon->search_concurrently($input)->wait;
    say '===' x $cols;
}

exit 0;

__END__

Tool to help checkout search_concurrently() output for specified
service
