package COSC1082::WebChecker::Tests;

use strict;
use warnings;

use Module::Pluggable (
    search_path => 'COSC1082::WebChecker::Test',
    require     => 1,
    sub_name    => '_getUnorderedTestTypes',
);

sub getAllTestTypes {
    my $class = shift;

    my %testsByNumber;
    for my $testClass ($class->_getUnorderedTestTypes) {
        my $testOrder = $testClass->_getOrder;
        if (not exists $testsByNumber{$testOrder}) {
            $testsByNumber{$testOrder} = [];
        }
        push @{ $testsByNumber{$testOrder} }, $testClass;
    }

    return
        map { @{$testsByNumber{$_}} }
        sort { $a <=> $b }
        keys %testsByNumber;
}

1;

__END__

=head1 NAME

C<COSC1082::WebChecker::Tests> - Collection of available test types

=head1 SYNOPSIS

    use COSC1082::WebChecker::Tests qw();
    my @testClasses
        = COSC1082::WebChecker::Tests->getAllTestTypes;
    
    for my $testClass (@testClasses) {
        my $test = $testClass->new(...);
        # ...
    }

=head1 METHODS

=head2 C<< COSC1082::WebChecker::Tests->getAllTestTypes >>

Returns a list of C<COSC1082::WebChecker::Test> module names, instances
of which can then be created via C<< $_->new(...) >>.

=head1 EXPORTS

None.
