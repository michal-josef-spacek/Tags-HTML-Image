package Tags::HTML::Image;

use base qw(Tags::HTML);
use strict;
use warnings;

use Class::Utils qw(set_params split_params);
use Error::Pure qw(err);
use Scalar::Util qw(blessed);

our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my ($object_params_ar, $other_params_ar) = split_params(
		['css_image', 'css_init', 'fit_minus', 'img_src_cb',
		'img_width', 'title'], @params);
	my $self = $class->SUPER::new(@{$other_params_ar});

	# Form CSS style.
	$self->{'css_image'} = 'image';

	# Init CSS style.
	$self->{'css_init'} = [
		['s', '*'],
		['d', 'box-sizing', 'border-box'],
		['d', 'margin', 0],
		['d', 'padding', 0],
		['e'],
	];

	# Length to minus of image fit.
	$self->{'fit_minus'} = undef;

	# Image src callback across data object.
	$self->{'img_src_cb'} = undef;

	# Image width in pixels.
	$self->{'img_width'} = undef;

	# Form title.
	$self->{'title'} = undef;

	# Process params.
	set_params($self, @{$object_params_ar});

	# Check callback code.
	if (defined $self->{'img_src_cb'}
		&& ref $self->{'img_src_cb'} ne 'CODE') {

		err "Parameter 'img_src_cb' must be a code.";
	}

	# Object.
	return $self;
}

# Process 'Tags'.
sub _process {
	my ($self, $image) = @_;

	if (! defined $image) {
		err 'Image object is required.';
	}
	if (! blessed($image) || ! $image->isa('Data::Image')) {
		err "Image object must be a instance of 'Data::Image'.";
	}

	my $image_url;
	if (defined $image->url) {
		$image_url = $image->url;
	} elsif (defined $image->url_cb) {
		$image_url = $image->url_cb->($image);
	} elsif (defined $self->{'img_src_cb'}) {
		$image_url = $self->{'img_src_cb'}->($image);
	} else {
		err 'No image URL.';
	}

	$self->{'tags'}->put(
		['b', 'figure'],
		['a', 'class', $self->{'css_image'}],
	);
	if (defined $self->{'title'}) {
		$self->{'tags'}->put(
			['b', 'fieldset'],
			['b', 'legend'],
			['d', $self->{'title'}],
			['e', 'legend'],
		);
	}
	$self->{'tags'}->put(
		['b', 'img'],
		['a', 'src', $image_url],
		['e', 'img'],
	);
	if (defined $self->{'title'}) {
		$self->{'tags'}->put(
			['e', 'fieldset'],
		);
	}
	$self->{'tags'}->put(
		['e', 'figure'],
	);

	return;
}

sub _process_css {
	my $self = shift;

	my $calc;
	if (! defined $self->{'img_width'}) {
		$calc .= 'calc(100vh';
		if (defined $self->{'fit_minus'}) {
			$calc .= ' - '.$self->{'fit_minus'};
		}
		$calc .= ')';
	}

	$self->{'css'}->put(
		@{$self->{'css_init'}},

		['s', '.'.$self->{'css_image'}.' img'],
		['d', 'height', '100%'],
		['d', 'width', '100%'],
		['d', 'object-fit', 'contain'],
		['e'],

		['s', '.'.$self->{'css_image'}],
		defined $self->{'img_width'} ? (
			['d', 'width', $self->{'img_width'}],
		) : (
			['d', 'height', $calc],
		),
		['e'],
	);

	return;
}

1;

__END__

