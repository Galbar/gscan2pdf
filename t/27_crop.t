# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Gscan2pdf.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 4;

BEGIN {
 use_ok('Gscan2pdf');
 use_ok('Gscan2pdf::Document');
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

# Thumbnail dimensions
our $widtht  = 100;
our $heightt = 100;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($WARN);
our $logger = Log::Log4perl::get_logger;
my $prog_name = 'gscan2pdf';
use Locale::gettext 1.05;    # For translations
our $d = Locale::gettext->domain($prog_name);
Gscan2pdf->setup( $d, $logger );

# Create test image
system('convert rose: test.jpg');

my $slist = Gscan2pdf::Document->new;
$slist->get_file_info(
 'test.jpg',
 undef, undef, undef,
 sub {
  my ($info) = @_;
  $slist->import_file(
   $info, 1, 1, undef, undef, undef,
   sub {
    $slist->crop(
     $slist->{data}[0][2],
     10, 10, 10, 10, undef, undef, undef,
     sub {
      $slist->save_image( 'test2.jpg', [ $slist->{data}[0][2] ],
       undef, undef, undef, sub { Gtk2->main_quit } );
     }
    );
   }
  );
 }
);
Gtk2->main;

is( system('identify test2.jpg'), 0, 'valid JPG created' );
cmp_ok(
 -s 'test2.jpg',
 '<',
 -s 'test.jpg',
 'cropped JPG smaller than original'
);

#########################

unlink 'test.jpg', 'test2.jpg';
Gscan2pdf->quit();
