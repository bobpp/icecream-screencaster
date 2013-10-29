use strict;
use warnings;
use utf8;
use Text::Xslate;
use JSON;
use Furl;
use Data::Section::Simple;
use Path::Tiny;
use URI;
use Data::Dumper;

my($url) = @ARGV;

my $uri = URI->new('https://api.twitter.com/1/statuses/oembed.json');
$uri->query_form(url => $url, maxwidth => 550, hide_media => 'true', hide_thread => 'true', omit_script => 'true');

my $ua = Furl->new(timeout => 3);
my $twitter_api_response = $ua->get($uri->as_string);
if ($twitter_api_response->is_success) {
	my $result = decode_json($twitter_api_response->body);

	my $templates_virtual_paths = Data::Section::Simple->new->get_data_section;
	my $tx = Text::Xslate->new(
		path => [ $templates_virtual_paths ],
	);
	my $path = Path::Tiny->new('htdocs/screen.html');
	$path->spew($tx->render('base.tx', { tweet_html => $result->{html} }));
}
else {
	print Dumper($twitter_api_response);
}

__DATA__

@@ base.tx
<: $tweet_html | mark_raw :>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

