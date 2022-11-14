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
		['css_image', 'css_init', 'fit_minus', 'img_comment_cb', 'img_src_cb',
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

	# Image comment callback.
	$self->{'img_comment_cb'} = undef;

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

sub _cleanup {
	my $self = shift;

	delete $self->{'_image'};
	$self->{'_image_comment_tags'} = [];
	$self->{'_image_comment_css'} = [];

	return;
}

sub _init {
	my ($self, $image, @params) = @_;

	if (! defined $image) {
		err 'Image object is required.';
	}
	if (! blessed($image) || ! $image->isa('Data::Image')) {
		err "Image object must be a instance of 'Data::Image'.";
	}

	$self->{'_image'} = $image;

	if (defined $self->{'img_comment_cb'}) {
		($self->{'_image_comment_tags'}, $self->{'_image_comment_css'})
			= $self->{'img_comment_cb'}->($image, @params);
	} else {
		if (defined $image->comment) {
			$self->{'_image_comment_tags'} = [
				['d', $image->comment],
			];
		}
	}
	if (@{$self->{'_image_comment_tags'}}) {
		push @{$self->{'_image_comment_css'}}, (
			['s', '.'.$self->{'css_image'}.' figcaption'],
			['d', 'position', 'absolute'],
			['d', 'bottom', 0],
			['d', 'background', 'rgb(0, 0, 0)'],
			['d', 'background', 'rgba(0, 0, 0, 0.5)'],
			['d', 'color', '#f1f1f1'],
			['d', 'width', '100%'],
			['d', 'transition', '.5s ease'],
			['d', 'opacity', 0],
			['d', 'font-size', '20px'],
			['d', 'padding', '20px'],
			['d', 'text-align', 'center'],
			['e'],

			['s', 'figure.'.$self->{'css_image'}.':hover figcaption'],
			['d', 'opacity', 1],
			['e'],
		);
	}

	return;
}

# Process 'Tags'.
sub _process {
	my $self = shift;

	# Begin of figure.
	$self->{'tags'}->put(
		['b', 'figure'],
		['a', 'class', $self->{'css_image'}],
	);

	# Begin of image title.
	if (defined $self->{'title'}) {
		$self->{'tags'}->put(
			['b', 'fieldset'],
			['b', 'legend'],
			['d', $self->{'title'}],
			['e', 'legend'],
		);
	}

	# Image.
	my $image_url;
	if (defined $self->{'_image'}->url) {
		$image_url = $self->{'_image'}->url;
	} elsif (defined $self->{'_image'}->url_cb) {
		$image_url = $self->{'_image'}->url_cb->($self->{'_image'});
	} elsif (defined $self->{'img_src_cb'}) {
		$image_url = $self->{'img_src_cb'}->($self->{'_image'});
	} else {
		err 'No image URL.';
	}
	$self->{'tags'}->put(
		['b', 'img'],
		['a', 'src', $image_url],
		['e', 'img'],
	);

	# Image comment.
	if (@{$self->{'_image_comment_tags'}}) {
		$self->{'tags'}->put(
			['b', 'figcaption'],
			@{$self->{'_image_comment_tags'}},
			['e', 'figcaption'],
		);
	}

	# End of image title.
	if (defined $self->{'title'}) {
		$self->{'tags'}->put(
			['e', 'fieldset'],
		);
	}

	# End of figure.
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

		@{$self->{'_image_comment_css'}},
	);

	return;
}

1;

__END__

