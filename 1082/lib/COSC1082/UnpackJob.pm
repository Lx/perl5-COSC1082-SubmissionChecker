package COSC1082::UnpackJob;

use strict;
use warnings;

use constant UNZIP_UTILITY
    => '/usr/local/pkg/oracle/10g/product/10.2.0.1.0/bin/unzip';

use English qw(-no_match_vars);

sub new {
    my ($class, %args) = @_;

    my $archive = $args{'archive'};
    $archive = $archive->getPath
        if ref($archive) eq 'COSC1082::File';

    my $self = {
        archive     => $archive,
        outputDir   => delete $args{'outputDir'},
    };
    return bless($self, $class);
}

sub getArchivePath {
    return shift->{'archive'};
}

sub getOutputDir {
    return shift->{'outputDir'};
}

sub isSuccessful {
    my $self = shift;
    $self->_doUnzip if not exists $self->{'isSuccessful'};
    return $self->{'isSuccessful'};
}

sub getUnpackOutput {
    my $self = shift;
    $self->_doUnzip if not exists $self->{'unpackOutput'};
    return $self->{'unpackOutput'};
}

sub _doUnzip {
    my $self = shift;
    my $unzipCmd = sprintf(
        q{"%s" -P 0 -d "%s" "%s"},
        UNZIP_UTILITY,
        $self->getOutputDir,
        $self->getArchivePath,
    );
    my $oldUmask = umask 077;
    # Best untaint hack evar
    ($unzipCmd) = ($unzipCmd =~ /^(.*)$/);
    $self->{'unpackOutput'}  = `/bin/sh -c '$unzipCmd' 2>&1`;
    $self->{'isSuccessful'} = $CHILD_ERROR == 0;
    umask $oldUmask;
}

1;
