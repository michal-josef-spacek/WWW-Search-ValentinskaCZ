package WWW::Search::ValentinskaCZ;

# Pragmas.
use base qw(WWW::Search);
use strict;
use warnings;

# Modules.
use Encode qw(decode_utf8);
use LWP::UserAgent;
use Readonly;
use Text::Iconv;
use Web::Scraper;

# Constants.
Readonly::Scalar our $MAINTAINER => 'Michal Spacek <skim@cpan.org>';
Readonly::Scalar my $VALENTINSKA_CZ => 'http://valentinska.cz/';
Readonly::Scalar my $VALENTINSKA_CZ_ACTION1 => 'index.php?hledani=Vyhledej&hltex=';

# Version.
our $VERSION = 0.03;

# Setup.
sub native_setup_search {
	my ($self, $query) = @_;
	$self->{'_def'} = scraper {

		# Get list of books.
		process '//table[@class="ProductTable"]/tr/td',
			'books[]' => scraper {

			process '//h2/a', 'title' => 'TEXT';
			process '//h2/a', 'url' => '@href';
			process '//img', 'cover_url' => '@src';
			process '//p[@class="AuthorName"]',
				'author' => 'TEXT';
			process '//p[@class="BookPrice"]/span',
				'price' => 'TEXT';
			return;
		};
		return;
	};
	$self->{'_query'} = $query;
	return 1;
}

# Get data.
sub native_retrieve_some {
	my $self = shift;

	# Query.
	my $i1 = Text::Iconv->new('utf-8', 'windows-1250');
	my $query = $i1->convert(decode_utf8($self->{'_query'}));

	# Get content.
	my $ua = LWP::UserAgent->new(
		'agent' => "WWW::Search::KacurCZ/$VERSION",
	);
	my $response = $ua->get($VALENTINSKA_CZ.
		$VALENTINSKA_CZ_ACTION1.$query,
	);

	# Process.
	if ($response->is_success) {
		my $i2 = Text::Iconv->new('windows-1250', 'utf-8');
		my $content = $i2->convert($response->content);

		# Get books structure.
		my $books_hr = $self->{'_def'}->scrape($content);

		# Process each book.
		foreach my $book_hr (@{$books_hr->{'books'}}) {
			_fix_url($book_hr, 'url');
			_fix_url($book_hr, 'cover_url');
			$self->_remove_tr($book_hr, 'title');
			push @{$self->{'cache'}}, $book_hr;
		}
	}

	return;
}

# Fix URL to absolute path.
sub _fix_url {
	my ($book_hr, $url) = @_;
	if (exists $book_hr->{$url}) {
		$book_hr->{$url} = $VALENTINSKA_CZ.$book_hr->{$url};
	}
	return;
}

# Remove trailing whitespace.
sub _remove_tr {
	my ($self, $book_hr, $key) = @_;
	if (! exists $book_hr->{$key}) {
		return;
	}
	$book_hr->{$key} =~ s/^\s+//gms;
	$book_hr->{$key} =~ s/\s+$//gms;
	return;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

WWW::Search::ValentinskaCZ - Class for searching http://valentinska.cz .

=head1 SYNOPSIS

 use WWW::Search::ValentinskaCZ;
 my $obj = WWW::Search->new('ValentinskaCZ');
 $obj->native_query($query);
 my $maintainer = $obj->maintainer; 
 my $res_hr = $obj->next_result;
 my $version = $obj->version;

=head1 METHODS

=over 8

=item C<native_setup_search($query)>

 Setup.

=item C<native_retrieve_some()>

 Get data.

=back

=head1 EXAMPLE

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
 #     title       "Myšlenky",
 #     url         "http://valentinska.cz/index.php?lang=&idvyrb=380039&akc=detail"
 # }

=head1 DEPENDENCIES

L<HTTP::Cookies>,
L<LWP::UserAgent>,
L<Readonly>,
L<Web::Scraper>,
L<WWW::Search>.

=head1 SEE ALSO

=item L<WWW::Search>

Virtual base class for WWW searches

=item L<Task::WWW::Search::Antiquarian::Czech>

Install the WWW::Search modules for Czech antiquarian bookstores.

=back

=head1 REPOSITORY

L<https://github.com/tupinek/WWW-Search-ValentinskaCZ>

=head1 AUTHOR

Michal Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

BSD license.

=head1 VERSION

0.03

=cut
