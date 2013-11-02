use strict;
use warnings;
use utf8;
use Text::Xslate;
use JSON;
use Furl;
use Path::Tiny;
use URI;
use Data::Dumper;
use Getopt::Long;
use DBI;

GetOptions('theme=i' => \my $theme);

my $dbh = DBI->connect('dbi:SQLite:dbname=commentators.db', '', '');
my $ua = Furl->new(timeout => 3);

my $theme_titles = +{
	0 => 'Opening',
	1 => 'LEVEL3 100% トーク!',
	2 => '2013年の Perfume について',
	3 => 'ドームツアーの予想！',
	4 => 'Ending',
	5 => '2部',
};

my $commentator_twitter_ids = +{
	0 => [ qw/Notridfcchi/ ],
	1 => [ qw/poronnotei koeda11 dokuroflower/ ],
	2 => [ qw/bakushin2300 pittanko_pta jaqwatdas toshi110 santgva kokubucamera BoBpp/ ],
	3 => [ qw/hcaaabok buchibuchi nanno2009/ ],
	4 => [ qw/Notridfcchi/ ],
	5 => [ qw/Notridfcchi BoBpp/ ],
};

my $commentators = [ map { +{ twitter_id => $_ } } @{ $commentator_twitter_ids->{ $theme } } ];
for (@$commentators) {
	my $c = $dbh->selectrow_hashref(
		'SELECT * FROM commentators WHERE twitter_id = ?',
		undef,
		$_->{twitter_id},
	);

	if ($c) {
		$_->{icon_url} = $c->{icon_url};
	}
	else {
		my $res = $ua->request(
			method => 'GET',
			url => sprintf('http://furyu.nazo.cc/twicon/%s/original', $_->{twitter_id}),
			max_redirects => 0,
		);
		$_->{icon_url} = $res->headers->header('location');

		$dbh->do(
			'INSERT INTO commentators (twitter_id, icon_url, created_at, updated_at) VALUES (?, ?, ?, ?)',
			undef,
			$_->{twitter_id}, $_->{icon_url}, time, time,
		);
	}
}

my $stash = +{
	theme_title => $theme_titles->{ $theme },
	commentators => $commentators,
};

my($id) = @ARGV;
if ($id eq 'DEFAULT') {
}
else {
	my $uri = URI->new('https://api.twitter.com/1/statuses/oembed.json');
	$uri->query_form(id => $id, maxwidth => 550, hide_media => 'true', hide_thread => 'true', omit_script => 'true', align => 'center');

	my $twitter_api_response = $ua->get($uri->as_string);
	if ($twitter_api_response->is_success) {
		my $result = decode_json($twitter_api_response->body);
		$stash->{tweet_html} = $result->{html};
	}
	else {
		print Dumper($twitter_api_response);
		die;
	}
}

Path::Tiny->new('htdocs/screen.html')->spew_utf8(
	Text::Xslate->new(path => 'views')->render('tweet.tx', $stash)
);

