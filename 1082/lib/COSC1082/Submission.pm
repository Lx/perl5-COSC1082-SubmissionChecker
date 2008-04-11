package COSC1082::Submission;

use strict;
use warnings;

use COSC1082::File qw();
use COSC1082::UnpackJob qw();
use File::Find qw();
use File::Temp qw();

sub new {
    my ($class, $submittedFile) = @_;
    my $self = {
        'submittedFile' => COSC1082::File->new($submittedFile),
    };
    return bless($self, $class);
}

sub getSubmittedFile {
    return shift->{'submittedFile'};
}

sub getForeignFilenames {
    my $self = shift;
    $self->_processSubmittedFile if not exists $self->{'foreignFiles'};
    return @{ $self->{'foreignFiles'} };
}

sub getPDFFile {
    my $self = shift;
    $self->_processSubmittedFile if not exists $self->{'pdfFile'};
    return $self->{'pdfFile'};
}

sub getPDFFilenames {
    my $self = shift;
    $self->_processSubmittedFile if not exists $self->{'pdfFiles'};
    return @{ $self->{'pdfFiles'} };
}

sub getASMFile {
    my $self = shift;
    $self->_processSubmittedFile if not exists $self->{'asmFile'};
    return $self->{'asmFile'};
}

sub getASMFilenames {
    my $self = shift;
    $self->_processSubmittedFile if not exists $self->{'asmFiles'};
    return @{ $self->{'asmFiles'} };
}

sub getLSTFile {
    my $self = shift;
    $self->_processSubmittedFile if not exists $self->{'lstFile'};
    return $self->{'lstFile'};
}

sub getLSTFilenames {
    my $self = shift;
    $self->_processSubmittedFile if not exists $self->{'lstFiles'};
    return @{ $self->{'lstFiles'} };
}

sub getSFile {
    my $self = shift;
    $self->_processSubmittedFile if not exists $self->{'sFile'};
    return $self->{'sFile'};
}

sub getSFilenames {
    my $self = shift;
    $self->_processSubmittedFile if not exists $self->{'sFiles'};
    return @{ $self->{'sFiles'} };
}

sub isUnzippable {
    return shift->_getUnpackJob->isSuccessful;
}

sub _processSubmittedFile {
    my $self = shift;

    my $pdfFile = undef;
    my $asmFile = undef;
    my $lstFile = undef;
    my $sFile   = undef;

    my (@pdfFiles, @asmFiles, @lstFiles, @sFiles, @foreignFiles);

    my $submittedFile = $self->getSubmittedFile;
    my $extension = lc $submittedFile->getExtension;
    if ($extension eq 'pdf') {
        $pdfFile = $submittedFile;
    }
    elsif ($extension eq 'asm') {
        $asmFile = $submittedFile;
    }
    elsif ($extension eq 'lst') {
        $lstFile = $submittedFile;
    }
    elsif ($extension eq 's') {
        $sFile = $submittedFile;
    }
    elsif ($self->isUnzippable) {
        # We are dealing with an archive, which is what we want anyway.
        # ->isUnzippable currently guarantees a successful unpack.
        File::Find::find(
            {
                no_chdir    => 1,
                wanted      => sub {
                    my $path = $File::Find::name;
                    return unless -f $path;

                    my $file = COSC1082::File->new($path);
                    my $extension = lc $file->getExtension;

                    my $destinationList
                        = $extension eq 'pdf' ? \@pdfFiles
                        : $extension eq 'asm' ? \@asmFiles
                        : $extension eq 'lst' ? \@lstFiles
                        : $extension eq 's'   ? \@sFiles
                        :                       \@foreignFiles;

                    push @$destinationList, $file->getPath;
                },
            },
            $self->_getUnpackDir
        );

        $pdfFile = COSC1082::File->new($pdfFiles[0]) if @pdfFiles == 1;
        $asmFile = COSC1082::File->new($asmFiles[0]) if @asmFiles == 1;
        $lstFile = COSC1082::File->new($lstFiles[0]) if @lstFiles == 1;
        $sFile   = COSC1082::File->new($sFiles[0])   if @sFiles   == 1;

        # Filenames are only for display in the online submission
        # checker; they shouldn't contain unnecessary path info.
        my $dir = $self->_getUnpackDir;
        for my $list (
            \@pdfFiles,
            \@asmFiles,
            \@lstFiles,
            \@sFiles,
            \@foreignFiles,
        ) {
            s{^\Q$dir\E/?}{} for @$list;
        }
    }
    else {
        # We are dealing with something stupid, evidently.  Can't
        # include the submission itself as a 'foreign' file because it
        # loses its name...what do we do in this situation?

        # RAR files fit this bill.
    }

    $self->{'pdfFile'}      = $pdfFile;
    $self->{'asmFile'}      = $asmFile;
    $self->{'lstFile'}      = $lstFile;
    $self->{'sFile'}        = $sFile;
    $self->{'pdfFiles'}     = \@pdfFiles;
    $self->{'asmFiles'}     = \@asmFiles;
    $self->{'lstFiles'}     = \@lstFiles;
    $self->{'sFiles'}       = \@sFiles;
    $self->{'foreignFiles'} = \@foreignFiles;
}

sub _getUnpackJob {
    my $self = shift;
    if (not exists $self->{'unpackJob'}) {
        $self->{'unpackJob'} = COSC1082::UnpackJob->new(
            archive     => $self->getSubmittedFile,
            outputDir   => $self->_getUnpackDir,
        );
    }
    return $self->{'unpackJob'};
}

sub getUnpackOutput {
    return shift->_getUnpackJob->getUnpackOutput;
}

sub _getUnpackDir {
    my $self = shift;
    if (not exists $self->{'unpackDir'}) {
        $self->{'unpackDir'} = File::Temp::tempdir(
            'apeters-subchecker-unpack-XXXX',
            TMPDIR  => 1,
            CLEANUP => 1,
        );
    }
    return $self->{'unpackDir'};
}

1;

__END__

=head1 NAME

C<COSC1082::Submission> - Object-oriented representation of an
assignment submission

=head1 TODO

This documentation is severely out of date!

=head1 SYNOPSIS

    use COSC1082::Submission qw();
    my $submission = COSC1082::Submission->new('3123456.zip');
    
    my $submittedFile = $submission->getSubmittedFile;
    ENFORCE_RULES_ON $submittedFile;

=head1 METHODS

=head2 C<< COSC1082::File->new >>

Given the path to the file submitted to WebLearn, creates and returns a
C<COSC1082::Submission> instance.

    my $submission = COSC1082::Submission->new('3123456.zip');

=head2 C<< $submission->getSubmittedFile >>

Returns a C<COSC1082::File> instance of the file submitted to WebLearn.

=head1 EXPORTS

None.
