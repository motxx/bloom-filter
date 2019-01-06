package Hash::BloomFilter;

use Digest::MurmurHash3 qw( murmur128_x86 );
use Carp qw(croak);

use constant BSIZE => 64;

sub new {
    my ($class, %params) = @_;
    my $self = {
        m => $params{m} // 100000,
        k => $params{k} // 5,
        b => [],
    };
    bless $self, $class;
}

sub _index {
    my ($self, $string) = @_;
    my ($d1, $d2) = murmur128_x86($string); # FIXME: 巨大な入力に耐えられるような実装があると旨味が出る
    return $digest % $self->{m};
}

sub _set_bit {
    my ($self, $index) = @_;
    my $bidx = $index / BSIZE;
    my $eidx = $index % BSIZE;
    $self->{b}->[$bidx] //= 0;
    $self->{b}->[$bidx] |= 1 << $eidx;
}

sub _get_bit {
    my ($self, $index) = @_;
    my $bidx = $index / BSIZE;
    my $eidx = $index % BSIZE;
    $self->{b}->[$bidx] //= 0;
    return ($self->{b}->[$bidx] & (1 << $eidx)) > 0;
}

sub add {
    my ($self, $string) = @_;
    unless ($self->{m} > 0) {
        croak "'m' should be positive.";
    }
    for (my $i = 0; $i < $self->{k}; ++$i) {
        $self->_set_bit($self->_index($string . $i));
    }
}

sub probably_exists {
    my ($self, $string) = @_;
    for (my $i = 0; $i < $self->{k}; ++$i) {
        my $gb = $self->_index($string . $i);
        print("index: $gb\n");
        unless ($self->_get_bit($gb)) {
            return 0;
        }
    }
    return 1;
}

1
