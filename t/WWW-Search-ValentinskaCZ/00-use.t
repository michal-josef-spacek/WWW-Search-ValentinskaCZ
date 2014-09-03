# Pragmas.
use strict;
use warnings;

# Modules.
use Test::More 'tests' => 3;
use Test::NoWarnings;

BEGIN {

	# Test.
	use_ok('WWW::Search::ValentinskaCZ');
}

# Test.
require_ok('WWW::Search::ValentinskaCZ');
