use strict;
use warnings;

use Path::Tiny qw( path );

my $file = 'big.txt';
my $text = path($file)->slurp_utf8;

print $text;
