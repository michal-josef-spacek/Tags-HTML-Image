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
		['css_image', 'img_src_cb', 'img_width', 'title'], @params);
	my $self = $class->SUPER::new(@{$other_params_ar});

	# Form CSS style.
	$self->{'css_image'} = 'image';

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
	if (! blessed($image) || ! $image->isa('Data::Commons::Vote::Image')) {
		err "Image object must be a instance of 'Data::Commons::Vote::Image'.";
	}

	$self->{'tags'}->put(
		['b', 'div'],
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
	my $image_url;
	if (defined $self->{'img_src_cb'}) {
		$image_url = $self->{'img_src_cb'}->($image);
	} else {
		$image_url = $image->image;
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
		['e', 'div'],
	);

	return;
}

sub _process_css {
	my $self = shift;

	$self->{'css'}->put(

		# Grid center on page.
		['s', '.'.$self->{'css_image'}.' img'],
		defined $self->{'img_width'} ? (
			['d', 'width', $self->{'img_width'}],
		) : (
			['d', 'width', '100%'],
		),
		['e'],
	);

	return;
}

1;

__END__

