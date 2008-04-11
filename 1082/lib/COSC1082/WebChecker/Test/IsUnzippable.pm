package COSC1082::WebChecker::Test::IsUnzippable;

use strict;
use warnings;

use base qw(COSC1082::WebChecker::Test);

sub _getTitle {
    return 'ZIP can be unzipped without any errors';
}

sub _getOrder {
    return 3;
}

sub run {
    my $self = shift;

    my $submission = $self->_getSubmission;
    my $fileType = $submission->getSubmittedFile->getType;
    return if $fileType ne 'ZIP archive';

    if ($submission->isUnzippable) {
        $self->_pass;
    }
    else {
        $self->_fail;
        $self->_showDetails(
            zipOutput   => $submission->getUnpackOutput,
        );
    }
}

1;
