# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Gscan2pdf.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 73;
BEGIN { use_ok('Gscan2pdf') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $filename = 'scanners/epson_3490';
my $output = do { local( @ARGV, $/ ) = $filename ; <> } ;
my %this = Gscan2pdf::options2hash($output);
my %that = (
          'source' => {
                        'tip' => 'Selects the scan source (such as a document-feeder).',
                        'default' => 'Flatbed',
                        'values' => 'auto|Flatbed|Transparency Adapter'
                      },
          'gamma-table' => {
                             'tip' => 'Gamma-correction table.  In color mode this option equally affects the red, green, and blue channels simultaneously (i.e., it is an intensity gamma table).',
                             'default' => 'inactive',
                             'values' => '0..65535,... (in steps of 1)'
                           },
          'halftoning' => {
                            'tip' => 'Selects whether the acquired image should be halftoned (dithered).',
                            'default' => 'inactive',
                            'values' => 'yes|no'
                          },
          'threshold' => {
                           'tip' => 'Select minimum-brightness to get a white point',
                           'default' => 'inactive',
                           'values' => '0..100% (in steps of 1)'
                         },
          'mode' => {
                      'tip' => 'Selects the scan mode (e.g., lineart, monochrome, or color).',
                      'default' => 'Color',
                      'values' => 'auto|Color|Gray|Lineart'
                    },
          'analog-gamma-bind' => {
                                   'tip' => 'In RGB-mode use same values for each color',
                                   'default' => 'no',
                                   'values' => 'yes|no'
                                 },
          'red-gamma-table' => {
                                 'tip' => 'Gamma-correction table for the red band.',
                                 'default' => 'inactive',
                                 'values' => '0..65535,... (in steps of 1)'
                               },
          'green-gamma-table' => {
                                   'tip' => 'Gamma-correction table for the green band.',
                                   'default' => 'inactive',
                                   'values' => '0..65535,... (in steps of 1)'
                                 },
          'custom-gamma' => {
                              'tip' => 'Determines whether a builtin or a custom gamma-table should be used.',
                              'default' => 'no',
                              'values' => 'yes|no'
                            },
          'rgb-lpr' => {
                         'tip' => 'Number of scan lines to request in a SCSI read. Changing this parameter allows you to tune the speed at which data is read from the scanner during scans. If this is set too low, the scanner will have to stop periodically in the middle of a scan; if it\'s set too high, X-based frontends may stop responding to X events and your system could bog down.',
                         'default' => '4',
                         'values' => 'auto|1..50 (in steps of 1)'
                       },
          'analog-gamma' => {
                              'tip' => 'Analog gamma-correction',
                              'default' => 'inactive',
                              'values' => '0..4'
                            },
          'blue-gamma-table' => {
                                  'tip' => 'Gamma-correction table for the blue band.',
                                  'default' => 'inactive',
                                  'values' => '0..65535,... (in steps of 1)'
                                },
          'gs-lpr' => {
                        'tip' => 'Number of scan lines to request in a SCSI read. Changing this parameter allows you to tune the speed at which data is read from the scanner during scans. If this is set too low, the scanner will have to stop periodically in the middle of a scan; if it\'s set too high, X-based frontends may stop responding to X events and your system could bog down.',
                        'default' => 'inactive',
                        'values' => 'auto|1..50 (in steps of 1)'
                      },
          'predef-window' => {
                               'tip' => 'Provides standard scanning areas for photographs, printed pages and the like.',
                               'default' => 'None',
                               'values' => 'None|6x4 (inch)|8x10 (inch)|8.5x11 (inch)'
                             },
          'contrast' => {
                          'tip' => 'Controls the contrast of the acquired image.',
                          'default' => '0',
                          'values' => '-100..400% (in steps of 1)'
                        },
          'quality-cal' => {
                             'tip' => 'Do a quality white-calibration',
                             'default' => 'yes',
                             'values' => 'yes|no'
                           },
          'depth' => {
                       'tip' => 'Number of bits per sample, typical values are 1 for "line-art" and 8 for multibit scans.',
                       'default' => '8',
                       'values' => '8|16bit'
                     },
          'brightness' => {
                            'tip' => 'Controls the brightness of the acquired image.',
                            'default' => '0',
                            'values' => '-400..400% (in steps of 1)'
                          },
          'preview-mode' => {
                              'tip' => 'Select the mode for previews. Greyscale previews usually give the best combination of speed and detail.',
                              'default' => 'Auto',
                              'values' => 'auto|Auto|Color|Gray|Lineart'
                            },
          'high-quality' => {
                              'tip' => 'Highest quality but lower speed',
                              'default' => 'no',
                              'values' => 'auto|yes|no'
                            },
          'preview' => {
                         'tip' => 'Request a preview-quality scan.',
                         'default' => 'no',
                         'values' => 'auto|yes|no'
                       },
          'resolution' => {
                            'tip' => 'Sets the resolution of the scanned image.',
                            'default' => '300',
                            'values' => 'auto||50|150|200|240|266|300|350|360|400|600|720|800|1200|1600|3200dpi'
                          },
          'negative' => {
                          'tip' => 'Swap black and white',
                          'default' => 'inactive',
                          'values' => 'auto|yes|no'
                        },
          'halftone-pattern' => {
                                  'tip' => 'Defines the halftoning (dithering) pattern for scanning halftoned images.',
                                  'default' => 'inactive',
                                  'values' => 'DispersedDot8x8|DispersedDot16x16'
                                }
        );
foreach my $option (keys %this) {
 foreach (qw(tip default values)) {
  is ($this{$option}{$_}, $that{$option}{$_}, "$option, $_");
 }
}
eq_hash(\%this, \%that);