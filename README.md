# NAME

Bio::Taxon - Searches through different web services for animal scientific taxa data.

# SYNOPSIS

    use Bio::Taxon;
    my $bt = Bio::Taxon->new(timeout => 5);
    my @res;
    $bt->on( found => sub { push @res, $_[1] } );
    $bt->search_concurrently('egretta thula')->wait;
    say @res;

# DESCRIPTION

Bio::Taxon is module to search various scientific Web API about animals data
given species name.

# LICENSE

Copyright (C) Marco Arthur.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Marco Arthur <arthurpbs@gmail.com>
