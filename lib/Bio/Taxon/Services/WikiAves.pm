package Bio::Taxon::Services::WikiAves;
use Mojo::Base -base, -signatures, -async_await;
use Carp;
use Mojo::URL;
use namespace::autoclean;
use constant URL => 'https://www.wikiaves.com.br/';

#
# singleton class
# 
sub new( $class, @args ) {
    return $class if ref( $class ) && $class->isa(__PACKAGE__);
    my $o = $class->SUPER::new(@args)->with_roles('Bio::Roles::Service');
    $o->name('WikiAves');
    $o->base_url(Mojo::URL->new(URL));
    return $o;
}


async sub search_p($self, $term) {
    my $url = $self->base_url->clone->path('getTaxonsJSON.php')->query( term => $term );
    return $self->ua->get_p($url);
}

1;
