package COSC1082::WebChecker::Test::HasOneASM;

use strict;
use warnings;

use base qw(COSC1082::WebChecker::Test);

sub _getTitle {
    return 'ZIP contains precisely one ASM file';
}

sub _getOrder {
    return 6;
}

sub run {
    my $self = shift;
    my $submission = $self->_getSubmission;

    return unless $submission->isUnzippable;

    if ($submission->getASMFile) {
        $self->_pass;
    }
    else {
        $self->_fail;
        $self->_showDetails(
            asmList => [$submission->getASMFilenames],
        );
    }
}

1;
