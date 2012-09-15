use warnings;
use strict;
use Test::More tests => 1;

#########################

my $output = `perl bin/scanadf-perl --device=test --help`;

my $example = <<'END';
Usage: scanadf-perl [OPTION]...

Start image acquisition on a scanner device and write image data to
output files.

   [ -d | --device-name <device> ]   use a given scanner device.
   [ -h | --help ]                   display this help message and exit.
   [ -L | --list-devices ]           show available scanner devices.
   [ -v | --verbose ]                give even more status messages.
   [ -V | --version ]                print version information.
   [ -N | --no-overwrite ]           don't overwrite existing files.

   [ -o | --output-file <name> ]     name of file to write image data
                                     (%d replacement in output file name).
   [ -S | --scan-script <name> ]     name of script to run after every scan.
   [ --script-wait ]                 wait for scripts to finish before exit
   [ -s | --start-count <num> ]      page count of first scanned image.
   [ -e | --end-count <num> ]        last page number to scan.
   [ -r | --raw ]                    write raw image data to file.

Options specific to device `test':
  Scan Mode:
    --mode Gray|Color [Gray]
        Selects the scan mode (e.g., lineart, monochrome, or color).
    --depth 1|8|16 [8]
        Number of bits per sample, typical values are 1 for "line-art" and 8
        for multibit scans.
    --hand-scanner[=(yes|no)] [no]
        Simulate a hand-scanner.  Hand-scanners do not know the image height a
        priori.  Instead, they return a height of -1.  Setting this option
        allows to test whether a frontend can handle this correctly.  This
        option also enables a fixed width of 11 cm.
    --three-pass[=(yes|no)] [inactive]
        Simulate a three-pass scanner. In color mode, three frames are
        transmitted.
    --three-pass-order RGB|RBG|GBR|GRB|BRG|BGR [inactive]
        Set the order of frames in three-pass color mode.
    --resolution 1..1200dpi (in steps of 1) [50]
        Sets the resolution of the scanned image.
    --source Flatbed|Automatic Document Feeder [Flatbed]
        If Automatic Document Feeder is selected, the feeder will be 'empty'
        after 10 scans.
  Special Options:
    --test-picture Solid black|Solid white|Color pattern|Grid [Solid black]
        Select the kind of test picture. Available options:
Solid black: fills
        the whole scan with black.
Solid white: fills the whole scan with
        white.
Color pattern: draws various color test patterns depending on
        the mode.
Grid: draws a black/white grid with a width and height of 10
        mm per square.
    --invert-endianess[=(yes|no)] [inactive]
        Exchange upper and lower byte of image data in 16 bit modes. This
        option can be used to test the 16 bit modes of frontends, e.g. if the
        frontend uses the correct endianness.
    --read-limit[=(yes|no)] [no]
        Limit the amount of data transferred with each call to sane_read().
    --read-limit-size 1..65536 (in steps of 1) [inactive]
        The (maximum) amount of data transferred with each call to
        sane_read().
    --read-delay[=(yes|no)] [no]
        Delay the transfer of data to the pipe.
    --read-delay-duration 1000..200000us (in steps of 1000) [inactive]
        How long to wait after transferring each buffer of data through the
        pipe.
    --read-return-value Default|SANE_STATUS_UNSUPPORTED|SANE_STATUS_CANCELLED|SANE_STATUS_DEVICE_BUSY|SANE_STATUS_INVAL|SANE_STATUS_EOF|SANE_STATUS_JAMMED|SANE_STATUS_NO_DOCS|SANE_STATUS_COVER_OPEN|SANE_STATUS_IO_ERROR|SANE_STATUS_NO_MEM|SANE_STATUS_ACCESS_DENIED [Default]
        Select the return-value of sane_read(). "Default" is the normal
        handling for scanning. All other status codes are for testing how the
        frontend handles them.
    --ppl-loss 0..128pel (in steps of 1) [0]
        The number of pixels that are wasted at the end of each line.
    --fuzzy-parameters[=(yes|no)] [no]
        Return fuzzy lines and bytes per line when sane_parameters() is called
        before sane_start().
    --non-blocking[=(yes|no)] [no]
        Use non-blocking IO for sane_read() if supported by the frontend.
    --select-fd[=(yes|no)] [no]
        Offer a select filedescriptor for detecting if sane_read() will return
        data.
    --enable-test-options[=(yes|no)] [no]
        Enable various test options. This is for testing the ability of
        frontends to view and modify all the different SANE option types.
    --print-options
        Print a list of all options.
  Geometry:
    -l 0..200mm (in steps of 1) [0]
        Top-left x position of scan area.
    -t 0..200mm (in steps of 1) [0]
        Top-left y position of scan area.
    -x 0..200mm (in steps of 1) [80]
        Width of scan-area.
    -y 0..200mm (in steps of 1) [100]
        Height of scan-area.
  Bool test options:
    --bool-soft-select-soft-detect[=(yes|no)] [inactive]
        (1/6) Bool test option that has soft select and soft detect (and
        advanced) capabilities. That's just a normal bool option.
    --bool-soft-select-soft-detect-emulated[=(yes|no)] [inactive]
        (5/6) Bool test option that has soft select, soft detect, and emulated
        (and advanced) capabilities.
    --bool-soft-select-soft-detect-auto[=(auto|yes|no)] [inactive]
        (6/6) Bool test option that has soft select, soft detect, and
        automatic (and advanced) capabilities. This option can be automatically
        set by the backend.
  Int test options:
    --int <int> [inactive]
        (1/6) Int test option with no unit and no constraint set.
    --int-constraint-range 4..192pel (in steps of 2) [inactive]
        (2/6) Int test option with unit pixel and constraint range set.
        Minimum is 4, maximum 192, and quant is 2.
    --int-constraint-word-list -42|-8|0|17|42|256|65536|16777216|1073741824bit [inactive]
        (3/6) Int test option with unit bits and constraint word list set.
    --int-constraint-array <int>,... [inactive]
        (4/6) Int test option with unit mm and using an array without
        constraints.
    --int-constraint-array-constraint-range 4..192dpi,... (in steps of 2) [inactive]
        (5/6) Int test option with unit dpi and using an array with a range
        constraint. Minimum is 4, maximum 192, and quant is 2.
    --int-constraint-array-constraint-word-list -42|-8|0|17|42|256|65536|16777216|1073741824%,... [inactive]
        (6/6) Int test option with unit percent and using an array with a word
        list constraint.
  Fixed test options:
    --fixed <float> [inactive]
        (1/3) Fixed test option with no unit and no constraint set.
    --fixed-constraint-range -42.17..32768us (in steps of 2) [inactive]
        (2/3) Fixed test option with unit microsecond and constraint range
        set. Minimum is -42.17, maximum 32767.9999, and quant is 2.0.
    --fixed-constraint-word-list -32.6999969482422|12.0999908447266|42|129.5 [inactive]
        (3/3) Fixed test option with no unit and constraint word list set.
  String test options:
    --string <string> [inactive]
        (1/3) String test option without constraint.
    --string-constraint-string-list First entry|Second entry|This is the very long third entry. Maybe the frontend has an idea how to display it [inactive]
        (2/3) String test option with string list constraint.
    --string-constraint-long-string-list First entry|Second entry|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46 [inactive]
        (3/3) String test option with string list constraint. Contains some
        more entries...
  Button test options:
    --button
        (1/1) Button test option. Prints some text...

Type ``scanadf --help -d DEVICE'' to get list of all options for DEVICE.

List of available devices:
    test:0 test:1
END

my @output  = split( "\n", $output );
my @example = split( "\n", $example );
is_deeply( \@output, \@example, "basic help functionality" );

#########################

#unlink 'out1.pnm';