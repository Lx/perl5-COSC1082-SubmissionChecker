package COSC1082::WebChecker::Test::IsReasonableSize;

use strict;
use warnings;

use base qw(COSC1082::WebChecker::Test);

sub _getTitle {
    return 'Submitted file is of an expected size';
}

sub _getOrder {
    return 1;
}

sub run {
    my $self = shift;

    my $sizeInMB = sprintf(
        '%.1f',
        $self->_getSubmission->getSubmittedFile->getByteSize
            / 1024 / 1024
    );
    if ($sizeInMB > 2) {
        $self->_warn;
        $self->_showDetails(
            sizeInMB    => $sizeInMB,
        );
    }
    else {
        $self->_pass;
    }
}

1;
