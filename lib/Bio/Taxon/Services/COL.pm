package Bio::Taxon::Services::COL;
use Mojo::Base -base, -signatures, -async_await;
use Carp;
use Mojo::URL;
use namespace::autoclean;
use constant BASE => 'https://api.catalogueoflife.org/';

#
# singleton class
# 
sub new( $class, @args ) {
    return $class if ref( $class ) && $class->isa(__PACKAGE__);
    my $o = $class->SUPER::new(@args)->with_roles('Bio::Roles::Service');
    $o->name('COL');
    $o->base_url(Mojo::URL->new(BASE));
    return $o;
}

#
# Search for animals that match search $term
#
async sub search_p($self, $term) {
    my $url = $self->base_url->clone->path('nameusage/search')->query( { q => $term } );
    return $self->ua->get_p($url);
}

1;
