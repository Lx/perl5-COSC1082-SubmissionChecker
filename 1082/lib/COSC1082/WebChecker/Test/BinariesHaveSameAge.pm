package COSC1082::WebChecker::Test::BinariesHaveSameAge;

use strict;
use warnings;

use base qw(COSC1082::WebChecker::Test);

sub _getTitle {
    return 'LST and S files were created at the same time';
}

sub _getOrder {
    return 10;
}

sub run {
    my $self = shift;
    my $submission = $self->_getSubmission;
    my $lstFile = $submission->getLSTFile;
    my $sFile = $submission->getSFile;

    return unless $lstFile and $sFile;

    my $ageDiff
        = $lstFile->getModifiedTime
        - $sFile->getModifiedTime;
    if ($ageDiff->seconds <= 5) {
        $self->_pass;
    }
    else {
        $self->_fail;
        $self->_showDetails;
    }
}

1;
