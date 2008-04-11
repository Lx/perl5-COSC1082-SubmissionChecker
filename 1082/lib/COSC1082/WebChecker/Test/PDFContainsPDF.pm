package COSC1082::WebChecker::Test::PDFContainsPDF;

use strict;
use warnings;

use base qw(COSC1082::WebChecker::Test);

sub _getTitle {
    return 'PDF file contains PDF content';
}

sub _getOrder {
    return 5;
}

sub run {
    my $self = shift;
    my $submission = $self->_getSubmission;
    my $pdfFile = $submission->getPDFFile;

    return unless $pdfFile;

    my $fileType = $pdfFile->getType;
    if ($fileType =~ /^Adobe Portable Document Format \(PDF\)/) {
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
