package COSC1082::WebChecker::Test;

use strict;
use warnings;

# As defined within the template itself
use constant PASS => 'pass';
use constant WARN => 'warn';
use constant FAIL => 'fail';

sub new {
    my ($class, $submission, $template) = @_;

    my $self = {
        'submission'    => $submission,
        'template'      => $template,
    };
    return bless($self, $class);
}

sub _getSubmission {
    return shift->{'submission'};
}

sub __getTemplate {
    return shift->{'template'};
}

sub _getTitle {
    die "Abstract method '_getTitle' not implemented in " . ref shift;
}

sub _getOrder {
    die "Abstract method '_getOrder' not implemented in " . ref shift;
}

sub run {
    die "Abstract method 'run' not implemented in " . ref shift;
}

sub _pass {
    shift->{'status'} = PASS;
}

sub _warn {
    shift->{'status'} = WARN;
}

sub _fail {
    shift->{'status'} = FAIL;
}

sub __getStatus {
    return shift->{'status'};
}

sub _showDetails {
    my ($self, %templateVars) = @_;

    $self->{'showDetails'} = 1;
    $self->{'detailsVars'} = \%templateVars;
}

sub getHTMLOutput {
    my $self = shift;
    if (not exists $self->{'htmlOutput'}) {
        my $testDetails;
        if ($self->{'showDetails'}) {
            my $templateName = ref($self);
            $templateName =~ s{^.*::}{};
            $templateName = "test$templateName.tt2";
            $self->__getTemplate->process(
                $templateName,
                $self->{'detailsVars'},
                \$testDetails
            ) or die $self->__getTemplate->error->as_string;
        }
        my $output;
        $self->__getTemplate->process(
            'test.tt2',
            {
                testTitle   => $self->_getTitle,
                testStatus  => $self->__getStatus,
                testDetails => $testDetails,
            },
            \$output
        ) or die $self->__getTemplate->error->as_string;
        $self->{'htmlOutput'} = $output;
    }
    return $self->{'htmlOutput'};
}

1;

__END__

=head1 NAME

C<COSC1082::WebChecker::Test> - Abstract object-oriented representation
of a single test on a COSC1082 submission

=head1 SYNOPSIS

    # Test objects aren't instantiated directly
    use COSC1082::WebChecker::Tests qw();
    my @testClasses
        = COSC1082::WebChecker::Tests->getAllTestTypes;
    
    my $submission  = ...;
    my $template    = ...;
    
    for my $testClass (@testClasses) {
        my $test = $testClass->new($submission, $template);
        # ...
    }

=head1 METHODS

=head2 C<< $testClass->new >>

Given C<COSC1082::Submission> and C<Template> instances, creates and
returns a new C<COSC1082::WebChecker::Test> instance.

    my $test = $testClass->new($submission, $template);

Don't attempt to instantiate this class directly; it is abstract.

=head2 C<< $test->run >>

Runs the test on the supplied submission.  There is no meaningful
return value.

=head2 C<< $test->getHTMLOutput >>

Returns a string of HTML indicating the test's purpose, its outcome and
any further details.

=head1 SUBCLASSING

Subclasses of this class must implement the following methods:

=head2 C<< _getTitle >>

Returns a string summarising what is tested by this test.  It should
make sense as a true/false statement, where if the test passes the
statement is true.

=head2 C<< _getOrder >>

Returns an integer representing the order in which this test should be
run relative to other tests.  A test returning a smaller number than
that returned by other tests will be provided first by
C<< COSC1082::WebChecker::Tests->getAllTestTypes >>.

=head2 C<< run >>

Contains the necessary logic to determine whether this test should
indeed run, and if so, sets the test's status and optionally details.

The following methods are available to subclasses in order to achieve
this outcome:

=head3 C<< $self->_getSubmission >>

Returns the submission to be tested.

=head3 C<< $self->_pass >>

Marks this test as passed.

=head3 C<< $self->_warn >>

Marks this test as 'warned' (i.e. not a clean pass, but not a fail).

=head3 C<< $self->_fail >>

Marks this test as failed.

=head3 C<< $self->_showDetails >>

Indicate that the test should display further details.

These details will be sourced from a Template Toolkit source file whose
name is based on the name of the test class.  For instance, if the name
of the test class is C<COSC1082::WebChecker::Test::IsZipped>, the test
will retrieve its details from C<testIsZipped.tt2>.

Key/value pairs passed to this method will be passed to the template,
e.g.--

    $self->_showDetails(
        sizeInMB    => $sizeInMB,
        fileType    => $fileType,
    );

...where the corresponding template may contain:

    <p>
      Your submission is [% sizeInMB | html_entity %] MB in
      size and is of type '[% fileType | html_entity %]'.
    </p>
