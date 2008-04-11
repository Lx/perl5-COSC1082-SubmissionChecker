package COSC1082::WebChecker::Test::HasNoForeignFiles;

use strict;
use warnings;

use base qw(COSC1082::WebChecker::Test);

sub _getTitle {
    return 'All files found in ZIP are expected';
}

sub _getOrder {
    return 12;
}

sub run {
    my $self = shift;
    my $submission = $self->_getSubmission;

    return unless $submission->isUnzippable;

    my @foreignFiles = $submission->getForeignFilenames;
    if (@foreignFiles) {
        $self->_fail;
        $self->_showDetails(
            foreignList => \@foreignFiles,
        );
    }
    else {
        $self->_pass;
    }
}

1;
