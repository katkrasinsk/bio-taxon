package Bio::Taxon::Services::GBIF;
use Mojo::Base -base, -signatures, -async_await;
use Carp;
use Mojo::URL;
use namespace::autoclean;
use constant URL => 'https://api.gbif.org/v1/';

#
# singleton class
# 
sub new( $class, @args ) {
    return $class if ref( $class ) && $class->isa(__PACKAGE__);
    my $o = $class->SUPER::new(@args)->with_roles('Bio::Roles::Service');
    $o->name('GBIF');
    $o->base_url(Mojo::URL->new(URL));
    return $o;
}

#
# Search for animals that match search $term
#
async sub search_p($self, $term) {
    my $url = $self->base_url->clone->path('species')->query( { name => $term } );
    return $self->ua->get_p($url);
}

1;
