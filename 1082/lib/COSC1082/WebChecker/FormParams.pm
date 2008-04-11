package COSC1082::WebChecker::FormParams;

use strict;
use warnings;

use base qw(Exporter);

our @EXPORT_OK = qw(
    PARAM_SUBMISSION
    PARAM_TICKBOX
);

use constant PARAM_SUBMISSION   => 's';
use constant PARAM_TICKBOX      => 't';

1;

__END__

=head1 NAME

C<COSC1082::WebChecker::FormParams> - Form parameter names

=head1 DESCRIPTION

This module is used by C<COSC1082::WebChecker::Request> to determine
which CGI parameters contain which information.  It is also used by
the code responsible for generating the form HTML.

=head1 EXPORTS

None by default.  C<PARAM_SUBMISSION> and C<PARAM_TICKBOX> can be
exported on request.
