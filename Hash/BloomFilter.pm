package Hash::BloomFilter;

use Digest::MurmurHash;
use Devel::Peek;
use Carp qw(croak);

sub new {
    my ($class, %params) = @_;
    my $self = {
        m => $params{m} // 1000,
        k => $params{k} // 5,
        b => [],
    };
    bless $self, $class;
}

sub _mapped_index {
    my ($self, $string) = @_;
    my $digest = Digest::MurmurHash::murmur_hash($string); # think: cryptographic unsafe. it's ok?
    return $digest % $self->{m};
}

sub add {
    my ($self, $string) = @_;
    unless ($self->{m} > 0) {
        croak "'m' should be positive.";
    }
    for (my $i = 0; $i < $self->{k}; ++$i) {
        $self->{b}->[$self->_mapped_index($string . $i)] = 1;
    }
}

sub probably_exists {
    my ($self, $string) = @_;
    for (my $i = 0; $i < $self->{k}; ++$i) {
        unless ($self->{b}->[$self->_mapped_index($string . $i)]) {
            return 0;
        }
    }
    return 1;
}

1
