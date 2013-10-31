use strict;
use warnings;
use utf8;
use Text::Xslate;
use JSON;
use Furl;
use Path::Tiny;
use URI;
use Data::Dumper;

my($url) = @ARGV;

my $uri = URI->new('https://api.twitter.com/1/statuses/oembed.json');
$uri->query_form(url => $url, maxwidth => 550, hide_media => 'true', hide_thread => 'true', omit_script => 'true', align => 'center');

my $ua = Furl->new(timeout => 3);
my $twitter_api_response = $ua->get($uri->as_string);
if ($twitter_api_response->is_success) {
	my $result = decode_json($twitter_api_response->body);
	my $tx = Text::Xslate->new(
		path => 'views',
	);
	my $path = Path::Tiny->new('htdocs/screen.html');
	$path->spew_utf8($tx->render('tweet.tx', { tweet_html => $result->{html} }));
}
else {
	print Dumper($twitter_api_response);
}

