#!/usr/bin/env perl

# Pragmas.
use strict;
use warnings;

# Modules.
use Data::Printer;
use WWW::Search::ValentinskaCZ;

# Arguments.
if (@ARGV < 1) {
        print STDERR "Usage: $0 match\n";
        exit 1;
}
my $match = $ARGV[0];

# Object.
my $obj = WWW::Search->new('ValentinskaCZ');
$obj->maximum_to_retrieve(1);

# Search.
$obj->native_query($match);
while (my $result_hr = $obj->next_result) {
       p $result_hr;
}

# Output like:
# Usage: /tmp/1Ytv23doz5 match

# Output with 'Čapek' argument like:
# \ {
#     author      "Norbert F. Čapek",
#     cover_url   "http://valentinska.cz/images/0506fdc6967e087e3aa666301b530864.jpg",
#     price       "80 Kč",
#     title       " Myšlenky",
#     url         "http://valentinska.cz/index.php?lang=&idvyrb=380039&akc=detail"
# }