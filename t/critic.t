use strict;
use warnings;

BEGIN {
  unless ($ENV{AUTHOR_TESTING}) {
    print qq{1..0 # SKIP these tests are for testing by the author\n};
    exit
  }
}

use Test::Perl::Critic;

my $filenames = [ qw(
./lib/Bio/Roles/Service.pm
./lib/Bio/Utils.pm
./lib/Bio/Taxon/Services/WoRMS.pm
./lib/Bio/Taxon/Services/WikiAves.pm
./lib/Bio/Taxon/Services/COL.pm
./lib/Bio/Taxon/Services/GBIF.pm
./lib/Bio/Taxon/Cache.pm
./lib/Bio/Taxon.pm
    )
];

unless ($filenames && @$filenames) {
    $filenames = -d "blib" ? ["blib"] : ["lib"];
}

all_critic_ok(@$filenames);
