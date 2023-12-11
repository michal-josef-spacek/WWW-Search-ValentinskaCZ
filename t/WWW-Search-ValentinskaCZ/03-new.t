use strict;
use warnings;

use WWW::Search;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
my $obj = WWW::Search->new('ValentinskaCZ');
isa_ok($obj, 'WWW::Search');
