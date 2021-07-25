package Bio::Taxon::Services::GBIF;
use Mojo::Base -base, -signatures, -async_await;
use Role::Tiny::With;
use Mojo::URL;
use namespace::autoclean;
use constant BASE => 'https://api.gbif.org/v1/';

with 'Bio::Roles::Service';

#
# singleton class
# 
sub new( $class, @args ) {
    return $class if ref( $class ) && $class->isa(__PACKAGE__);
    my $o = $class->SUPER::new(@args, name => 'GBIF', base_url => Mojo::URL->new(BASE));
    return $o;
}

#
# Search for animals that match search $term
#
async sub search_p($self, $term) {
    my $url = $self->base_url->clone->path('species')->query( { name => $term } );
    return $self->ua->get_p($url);
}

#
# Normalize
#
sub normalize($self, $data) {
    return $data->{results};
}
1;
