package COSC1082::WebChecker::Test::BinariesSucceedASM;

use strict;
use warnings;

use base qw(COSC1082::WebChecker::Test);

sub _getTitle {
    return 'LST and/or S files were created after the ASM file was last modified';
}

sub _getOrder {
    return 11;
}

sub run {
    my $self = shift;
    my $submission = $self->_getSubmission;

    my $asmFile = $submission->getASMFile;
    my $lstFile = $submission->getLSTFile;
    my $sFile   = $submission->getSFile;

    return unless $asmFile and ($lstFile or $sFile);

    if (
        ($lstFile and $asmFile->getModifiedTime > $lstFile->getModifiedTime)
        or ($sFile and $asmFile->getModifiedTime > $sFile->getModifiedTime)
    ) {
        $self->_fail;
        $self->_showDetails;
    }
    else {
        $self->_pass;
    }
}

1;
