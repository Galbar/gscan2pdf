use warnings;
use strict;
use Test::More tests => 3;

BEGIN {
    use Gscan2pdf::Document;
    use Gtk2 -init;    # Could just call init separately
}

#########################

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($FATAL);
my $logger = Log::Log4perl::get_logger;
Gscan2pdf::Document->setup($logger);

# Create test images
system('touch test.ppm');
system('convert rose: test.tif');
my $old = `identify -format '%m %G %g %z-bit %r' test.tif`;

my $slist = Gscan2pdf::Document->new;

# dir for temporary files
my $dir = File::Temp->newdir;
$slist->set_dir($dir);

$slist->import_files(
    paths          => ['test.ppm'],
    error_callback => sub {
        my ($text) = @_;
        is(
            $text,
            'test.ppm is not a recognised image type',
            'message opening empty image'
        );
        $slist->import_files(
            paths          => ['test.png'],
            error_callback => sub {
                my ($text) = @_;
                is(
                    $text,
                    'File test.png not found',
                    'message opening non-existent image'
                );
                $slist->import_files(
                    paths             => ['test.tif'],
                    finished_callback => sub {
                        is(
`identify -format '%m %G %g %z-bit %r' $slist->{data}[0][2]{filename}`,
                            $old,
                            'TIFF imported correctly after previous errors'
                        );
                        Gtk2->main_quit;
                    },
                    error_callback => sub {
                        fail('error callback triggered after previous errors');
                        Gtk2->main_quit;
                    }
                );
            },
            finished_callback => sub {
                Gtk2->main_quit;
            }
        );
    },
    finished_callback => sub {
        Gtk2->main_quit;
    }
);
Gtk2->main;

#########################

unlink 'test.ppm', 'test.tif', <$dir/*>;
rmdir $dir;
Gscan2pdf::Document->quit();
