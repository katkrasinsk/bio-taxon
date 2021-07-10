# NAME

Bio::Taxon - Searches through different web services for animal scientific taxa data.

# SYNOPSIS

    use Bio::Taxon;
    my $promises = Bio::Taxon->new->search_term('larus dominicanus');
    my @res;
    $promises->each( sub { $_->then( sub { push @res, shift } } );
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
