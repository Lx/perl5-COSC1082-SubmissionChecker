package COSC1082::WebChecker::Test::HasErrorFreeLST;

use strict;
use warnings;

use base qw(COSC1082::WebChecker::Test);

sub _getTitle {
    return 'LST file reports error-free assembly';
}

sub _getOrder {
    return 8;
}

sub run {
    my $self = shift;
    my $lstFile = $self->_getSubmission->getLSTFile;

    return unless $lstFile;

    my $lstPath = $lstFile->getPath;
    # Yay for crappy untainting...
    ($lstPath) = ($lstPath =~ /^(.*)$/);

    my $result = system(
        '/usr/local/bin/grep',
        '-q',
        'No errors detected\.',
        $lstPath,
    );
    if ($result == 0) {
        $self->_pass;
    }
    else {
        $self->_fail;
        $self->_showDetails;
    }
}

1;
