package Bio::Taxon::Cache;
use Mojo::Base -base, -signatures;
use Carp;
use namespace::autoclean;

has _hash => sub { +{} };

sub save($self, $key, $value) {
    $self->_hash->{$key} = $value;
}

sub get($self, $key) {
    return $self->_hash->{$key};
}

1;
