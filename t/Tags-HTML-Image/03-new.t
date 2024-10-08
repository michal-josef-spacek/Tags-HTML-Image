use strict;
use warnings;

use English;
use Error::Pure::Utils qw(clean);
use Tags::HTML::Image;
use Test::More 'tests' => 7;
use Test::NoWarnings;

# Test.
my $obj = Tags::HTML::Image->new;
isa_ok($obj, 'Tags::HTML::Image');

# Test.
eval {
	Tags::HTML::Image->new(
		'css_class' => '1bad',
	);
};
is($EVAL_ERROR, "Parameter 'css_class' has bad CSS class name (number on begin).\n",
	"Parameter 'css_class' has bad CSS class name (number on begin) (1bad).");
clean();

# Test.
eval {
	Tags::HTML::Image->new(
		'css_class' => '@bad',
	);
};
is($EVAL_ERROR, "Parameter 'css_class' has bad CSS class name.\n",
	"Parameter 'css_class' has bad CSS class name (\@bad).");
clean();

# Test.
eval {
	Tags::HTML::Image->new(
		'img_comment_cb' => 'bad',
	);
};
is($EVAL_ERROR, "Parameter 'img_comment_cb' must be a code.\n",
	"Parameter 'img_comment_cb' must be a code.");
clean();

# Test.
eval {
	Tags::HTML::Image->new(
		'img_select_cb' => 'bad',
	);
};
is($EVAL_ERROR, "Parameter 'img_select_cb' must be a code.\n",
	"Parameter 'img_select_cb' must be a code.");
clean();

# Test.
eval {
	Tags::HTML::Image->new(
		'img_src_cb' => 'bad',
	);
};
is($EVAL_ERROR, "Parameter 'img_src_cb' must be a code.\n",
	"Parameter 'img_src_cb' must be a code.");
clean();
