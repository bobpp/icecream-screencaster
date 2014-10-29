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
use YAML;

GetOptions(
	'config=s' => \my $config_file_path,
	'theme=i' => \my $theme,
);

my $config = YAML::LoadFile($config_file_path) || die;
my $current_theme_config = $config->{themes}[ $theme ];

my $dbh = DBI->connect('dbi:SQLite:dbname=commentators.db', '', '');
my $ua = Furl->new(timeout => 3);

my $special_modes = [qw/MEMBERS CONTENTS HASH-TAG TEASER/];
my $stash = +{
	title => $config->{title},
	theme_title => $current_theme_config->{title},
	opening_themes => $config->{opening_themes},
};

my($url) = @ARGV;

my $url_scheme = URI->new($url)->scheme || '';
if ($url_scheme !~ /^http/) {
	die "special_mode = $url is not allowed!\nallow: @$special_modes\n" unless grep { $_ eq $url } @$special_modes;
	my $commentators = [ map { +{ twitter_id => $_ } } @{ $current_theme_config->{commentators} } ];
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

	$stash->{special_mode} = $url;
	$stash->{commentators} = $commentators;
}
else {
	my $uri = URI->new('https://api.twitter.com/1/statuses/oembed.json');
	$uri->query_form(url => $url, maxwidth => 550, hide_media => 'true', hide_thread => 'true', omit_script => 'true', align => 'center');

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

