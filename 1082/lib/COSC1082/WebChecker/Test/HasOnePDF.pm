package COSC1082::WebChecker::Test::HasOnePDF;

use strict;
use warnings;

use base qw(COSC1082::WebChecker::Test);

sub _getTitle {
    return 'ZIP contains precisely one PDF file';
}

sub _getOrder {
    return 4;
}

sub run {
    my $self = shift;
    my $submission = $self->_getSubmission;

    return unless $submission->isUnzippable;

    if ($submission->getPDFFile) {
        $self->_pass;
    }
    else {
        my @pdfList = $submission->getPDFFilenames;
        if (@pdfList) {
            $self->_warn;
        }
        else {
            $self->_fail;
        }
        $self->_showDetails(
            pdfList => \@pdfList,
        );
    }
}

1;
