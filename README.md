# bloom-filter

```
perl -I. -MHash::BloomFilter -nle 'use Hash::BloomFilter; my $bf = Hash::BloomFilter->new; my $sets = ["abc","123"]; $bf->add($_) for @$sets; print $bf->probably_exists($_) ? "yes" : "no"'
```