package Bio::Taxon::Services::WoRMS;
use Mojo::Base -base, -signatures, -async_await;
use Role::Tiny::With;
use Mojo::URL;
use namespace::autoclean;
use constant URL => 'https://www.marinespecies.org/';

with 'Bio::Roles::Service';

#
# singleton class
# 
sub new( $class, @args ) {
    return $class if ref( $class ) && $class->isa(__PACKAGE__);
    my $o = $class->SUPER::new(@args, name => 'WoRMS', base_url => Mojo::URL->new(URL));
    return $o;
}


async sub search_p($self, $term) {
    my @list = split/,/, $term;
    my $args = [];

    for my $arg (@list) {
        push @$args, 'scientificnames[]' => $arg;
    }

    my $url = $self->base_url->clone
    ->path('/rest/AphiaRecordsByMatchNames')
    ->query($args);
    return $self->ua->get_p($url);
}

1;
