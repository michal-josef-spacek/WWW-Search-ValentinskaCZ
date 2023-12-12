use strict;
use warnings;

use Test::More 'tests' => 2;
use Test::NoWarnings;
use WWW::Search::ValentinskaCZ;

# Test.
is($WWW::Search::ValentinskaCZ::VERSION, 0.07, 'Version.');
