package COSC1082::WebChecker::Test::HasOneS;

use strict;
use warnings;

use base qw(COSC1082::WebChecker::Test);

sub _getTitle {
    return 'ZIP contains precisely one S file';
}

sub _getOrder {
    return 9;
}

sub run {
    my $self = shift;
    my $submission = $self->_getSubmission;

    return unless $submission->isUnzippable;

    if ($submission->getSFile) {
        $self->_pass;
    }
    else {
        $self->_fail;
        $self->_showDetails(
            sList => [$submission->getSFilenames],
        );
    }
}

1;
