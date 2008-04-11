package COSC1082::WebChecker::Test::IsZipArchive;

use strict;
use warnings;

use base qw(COSC1082::WebChecker::Test);

sub _getTitle {
    return 'Submitted file seems to contain ZIP content';
}

sub _getOrder {
    return 2;
}

sub run {
    my $self = shift;

    my $fileType = $self->_getSubmission->getSubmittedFile->getType;
    if ($fileType eq 'ZIP archive') {
        $self->_pass;
    }
    else {
        $self->_fail;
        $self->_showDetails(
            fileType    => $fileType,
        );
    }
}

1;
