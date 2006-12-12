#line 1
package HTTP::Server::Simple::Static;
use strict;
use warnings;

use File::MMagic ();
use MIME::Types  ();
use URI::Escape  ();
use IO::File     ();
use File::Spec::Functions qw(canonpath);

require Exporter;

our $VERSION = '0.05';
our @ISA     = qw(Exporter);
our @EXPORT  = qw(serve_static);

my $mime  = MIME::Types->new();
my $magic = File::MMagic->new();

sub serve_static {
    my ( $self, $cgi, $base ) = @_;
    my $path = $cgi->url( -absolute => 1, -path_info => 1 );

    # Sanitize the path and try it.
    $path = $base . canonpath( URI::Escape::uri_unescape($path) );

    my $fh = IO::File->new();
    if ( -e $path and $fh->open($path) ) {
        binmode $fh;
        binmode $self->stdout_handle;

        my $content;
        {
            local $/;
            $content = <$fh>;
        }
        $fh->close;

        my $mimeobj = $mime->mimeTypeOf($path);
        my $mime    = ($mimeobj ? $mimeobj->type :
                       $magic->checktype_contents($content));

        use bytes;      # Content-Length in bytes, not characters
        print "HTTP/1.1 200 OK\015\012";
        print "Content-type: " . $mime . "\015\012";
        print "Content-length: " . length($content) . "\015\012\015\012";
        print $content;
        return 1;
    }
    return 0;
}

1;
__END__

#line 103
