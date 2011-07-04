# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Gscan2pdf.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 2;
BEGIN {
  use Gscan2pdf;
  use Gscan2pdf::Document;
#  use File::Copy;
};

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

SKIP: {
 skip 'unpaper not installed', 1 unless (system("which unpaper > /dev/null 2> /dev/null") == 0);

 use Log::Log4perl qw(:easy);
 Log::Log4perl->easy_init($DEBUG);
 our $logger = Log::Log4perl::get_logger;
 my $prog_name = 'gscan2pdf';
 use Locale::gettext 1.05;    # For translations
 our $d = Locale::gettext->domain($prog_name);
 Gscan2pdf->setup($d, $logger);

 # Create test image
 system('convert +matte -depth 1 -border 2x2 -bordercolor black -pointsize 12 -density 300 label:"The quick brown fox" 1.pnm');
 system('convert +matte -depth 1 -border 2x2 -bordercolor black -pointsize 12 -density 300 label:"The slower lazy dog" 2.pnm');
 system('convert -size 100x100 xc:black black.pnm');
 system('convert 1.pnm black.pnm 2.pnm +append test.pnm');

 my $slist = Gscan2pdf::Document->new;
 $slist->get_file_info( 'test.pnm', sub {
  $slist->import_file( $Gscan2pdf::_self->{data_queue}->dequeue, 1, 1, sub {
   $slist->unpaper( $slist->{data}[0][2], '--output-pages 2 --layout double', sub {
    system("cp $slist->{data}[0][2]{filename} lh.pnm;cp $slist->{data}[1][2]{filename} rh.pnm;");
#    copy( $slist->{data}[0][2]{filename}, 'lh.pnm' ) if (defined $slist->{data}[0][2]{filename}); FIXME: why does copy() not work when cp does?
#    copy( $slist->{data}[1][2]{filename}, 'rh.pnm' ) if (defined $slist->{data}[1][2]{filename});
    Gtk2->main_quit;
   }, sub {}, sub {}, sub {} );
  }, sub {}, sub {} );
 }, sub {}, sub{} );
 Gtk2->main;

 is( -s 'lh.pnm', 5934, 'LH PNM created with expected size' );
 is( -s 'rh.pnm', 5934, 'RH PNM created with expected size' );

 unlink 'test.pnm', '1.pnm', '2.pnm', 'black.pnm', 'lh.pnm', 'rh.pnm';
 Gscan2pdf->kill();
}
