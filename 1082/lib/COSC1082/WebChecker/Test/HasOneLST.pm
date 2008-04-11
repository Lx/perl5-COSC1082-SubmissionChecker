package COSC1082::WebChecker::Test::HasOneLST;

use strict;
use warnings;

use base qw(COSC1082::WebChecker::Test);

sub _getTitle {
    return 'ZIP contains precisely one LST file';
}

sub _getOrder {
    return 7;
}

sub run {
    my $self = shift;
    my $submission = $self->_getSubmission;

    return unless $submission->isUnzippable;

    if ($submission->getLSTFile) {
        $self->_pass;
    }
    else {
        $self->_fail;
        $self->_showDetails(
            lstList => [$submission->getLSTFilenames],
        );
    }
}

1;
