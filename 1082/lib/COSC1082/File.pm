package COSC1082::File;

use strict;
use warnings;

use constant FILE_UTILITY => '/usr/bin/file';

use Cwd qw();
use DateTime qw();
use File::stat qw(stat);

sub new {
    my ($class, $path) = @_;

    my $self = {
        'path'  => Cwd::abs_path($path),
    };
    return bless($self, $class);
}

sub getPath {
    return shift->{'path'};
}

sub getByteSize {
    my $self = shift;
    if (not exists $self->{'size'}) {
        $self->{'size'} = -s $self->getPath;
    }
    return $self->{'size'};
}

sub getType {
    my $self = shift;
    if (not exists $self->{'type'}) {
        my $filename = $self->getPath;
        my $fileCmd = sprintf(
            q{"%s" "%s"},
            FILE_UTILITY,
            $filename,
        );
        # Dodgiest untaint evar
        ($fileCmd) = ($fileCmd =~ /^(.*)$/);
        my $fileOutput = `$fileCmd`;
        $fileOutput =~ s{^\Q$filename\E:\s*}{};
        $fileOutput =~ s{\s*$}{};
        $self->{'type'} = $fileOutput;
    }
    return $self->{'type'};
}

sub getModifiedTime {
    my $self = shift;
    if (not exists $self->{'modifiedTime'}) {
        # AAARRRGGGHHH!!!  DateTime isn't taint-safe, dammit!
        $self->{'modifiedTime'} = DateTime->from_epoch(
            epoch   => File::stat::stat($self->getPath)->mtime,
        );
    }
    return $self->{'modifiedTime'};
}

sub getExtension {
    my $self = shift;
    if (not exists $self->{'extension'}) {
        my $extension = '';
        if ($self->getPath =~ m{\.([^\./]+)$}) {
            $extension = $1;
        }
        $self->{'extension'} = $extension;
    }
    return $self->{'extension'};
}

1;

__END__

=head1 NAME

C<COSC1082::File> - Object-oriented representation of a file

=head1 SYNOPSIS

    use COSC1082::File qw();
    my $file = COSC1082::File->new('somefile.ext');

    $file->getPath;             # '/path/to/somefile.ext'
    $file->getExtension;        # 'ext'
    $file->getByteSize;         # 12345
    $file->getType;             # 'ASCII text'
    $file->getModifiedTime;     # (DateTime instance)

=head1 METHODS

=head2 C<< COSC1082::File->new >>

Given an absolute or relative path to a file, creates and returns a new
C<COSC1082::File> instance.

    my $file = COSC1082::File->new($path);

=head2 C<< $file->getPath >>

Returns the file's absolute path.

=head2 C<< $file->getExtension >>

Returns the portion of the file's name after its final period, or an
empty string if the filename contains no periods.

=head2 C<< $file->getByteSize >>

Returns the file's size in bytes.

=head2 C<< $file->getType >>

Issues the UNIX C<file> command against this file and returns its
response (just the type--the filename and trailing newline are
removed).

=head2 C<< $file->getModifiedTime >>

Returns a C<DateTime> instance representing the time at which this file
was last modified.  This is evaluated only once during the lifetime of
the object; subsequent changes to the underlying file will not cause
this method to return a different value.

=head1 EXPORTS

None.
