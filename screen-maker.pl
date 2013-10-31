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

GetOptions('theme=i' => \my $theme);

my $stash = { theme_id => $theme };

my($id) = @ARGV;
unless ($id eq 'DEFAULT') {
	my $uri = URI->new('https://api.twitter.com/1/statuses/oembed.json');
	$uri->query_form(id => $id, maxwidth => 550, hide_media => 'true', hide_thread => 'true', omit_script => 'true', align => 'center');

	my $ua = Furl->new(timeout => 3);
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

