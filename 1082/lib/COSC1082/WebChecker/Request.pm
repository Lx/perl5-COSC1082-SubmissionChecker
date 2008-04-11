package COSC1082::WebChecker::Request;

use strict;
use warnings;

use base qw(Class::Singleton);

use CGI qw();
use COSC1082::File qw();
use COSC1082::WebChecker::FormParams qw(
    PARAM_SUBMISSION
    PARAM_TICKBOX
);
use File::Spec qw();
use File::Temp qw();

sub _new_instance {
    my $class = shift;
    my $self = {
        'cgi'   => CGI->new,
    };
    return bless($self, $class);
}

sub _getCGI {
    my $self = shift;
    return $self->{'cgi'};
}

sub isFormSubmitted {
    my $self = shift;
    if (not exists $self->{'isFormSubmitted'}) {
        $self->{'isFormSubmitted'} = $self->_getCGI->param;
    }
    return $self->{'isFormSubmitted'};
}

sub getSubmission {
    my $self = shift;
    if (not exists $self->{'submission'}) {
        if (my $fh = $self->_getCGI->upload(PARAM_SUBMISSION)) {
            my $tempFile = $self->_getTempFile;
            binmode $tempFile;
            while (my $line = <$fh>) {
                print $tempFile $line;
            }
            close $tempFile;
            $self->{'submission'} = COSC1082::Submission->new(
                $tempFile->filename
            );
        }
        else {
            $self->{'submission'} = undef;
        }
    }
    return $self->{'submission'};
}

sub _getTempFile {
    my $self = shift;
    if (not exists $self->{'tempFile'}) {
        $self->{'tempFile'} = File::Temp->new(
            TEMPLATE    => 'apeters-subchecker-upload-XXXX',
            DIR         => File::Spec->tmpdir,
        );
    }
    return $self->{'tempFile'};
}

sub isBoxTicked {
    my $self = shift;
    if (not exists $self->{'isBoxTicked'}) {
        $self->{'isBoxTicked'} = $self->_getCGI->param(PARAM_TICKBOX);
    }
    return $self->{'isBoxTicked'};
}

sub getSubmittedFilename {
    my $self = shift;
    if (not exists $self->{'submittedFilename'}) {
        $self->{'submittedFilename'}
            = $self->_getCGI->param(PARAM_SUBMISSION);
    }
    return $self->{'submittedFilename'};
}

1;

__END__

=head1 NAME

C<COSC1082::WebChecker::Request> - Object-oriented representation of a
CGI request

=head1 SYNOPSIS

    # Fictitious methods are written in ALL CAPS
    
    use COSC1082::WebChecker::Request qw();
    my $request = COSC1082::WebChecker::Request->instance;
    
    if ($request->isFormSubmitted) {
        if (
            my $submission = $request->getSubmission
            and $request->isBoxTicked
        ) {
            PROCESS $submission;
        }
        else {
            NO_FILE_ERROR unless $request->getSubmission;
            NOT_TICKED_ERROR unless $request->isBoxTicked;
        }
        FEED_TEMPLATE $request->isBoxTicked;
    }

=head1 METHODS

=head2 C<< COSC1082::WebChecker::Request->instance >>

Returns the single instance of this object (use this where you would
expect to use C<< ->new >>).

=head2 C<< $request->isFormSubmitted >>

Returns a true value if this request was generated as the result of
submitting a form.

=head2 C<< $request->getSubmission >>

Returns a C<COSC1082::Submission> instance built from the file
submitted with the request, or C<undef> if no file was submitted.

=head2 C<< $request->isBoxTicked >>

Returns a true value if the tick box shown on the form was ticked.
This provides a means for the form to provide a cautionary message
stating that the submission checker won't submit work for assessment.

=head2 C<< $request->getSubmittedFilename >>

Returns the filename of the submitted file as named on the user's
machine.  This may or may not include the full path to the file
(using the path conventions of the user's machine) depending on the
browser used.

=head1 EXPORTS

None.
