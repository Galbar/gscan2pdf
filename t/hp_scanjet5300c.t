# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Gscan2pdf.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 2;
BEGIN { use_ok('Gscan2pdf') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $filename = 'scanners/hp_scanjet5300c';
my $output = do { local( @ARGV, $/ ) = $filename ; <> } ;
my %this = Gscan2pdf::options2hash($output);
my %that = (
          'source' => {
                        'tip' => 'Selects the scan source (such as a document-feeder).',
                        'default' => 'Normal',
                        'values' => ['Normal','ADF']
                      },
          'mode' => {
                      'tip' => 'Selects the scan mode (e.g., lineart, monochrome, or color).',
                      'default' => 'Color',
                      'values' => ['Lineart','Dithered','Gray','12bit Gray','Color','12bit Color']
                    },
          'red-gamma-table' => {
                                 'tip' => 'Gamma-correction table for the red band.',
                                 'default' => 'inactive',
                                   'min' => 0,
                            'max' => 255,
                               },
          'green-gamma-table' => {
                                   'tip' => 'Gamma-correction table for the green band.',
                                   'default' => 'inactive',
                                   'min' => 0,
                            'max' => 255,
                                 },
          'contrast' => {
                          'tip' => 'Controls the contrast of the acquired image.',
                          'default' => '0',
                                   'min' => -100,
                            'max' => 100,
                            'step' => 1,
                        },
          'quality-cal' => {
                             'tip' => 'Do a quality white-calibration',
                             'default' => 'yes',
                             'values' => ['yes','no']
                           },
          'frame' => {
                       'tip' => 'Selects the number of the frame to scan',
                       'default' => 'inactive',
                                   'min' => 0,
                            'max' => 0,
                     },
          'brightness' => {
                            'tip' => 'Controls the brightness of the acquired image.',
                            'default' => '0',
                            'min' => -100,
                            'max' => 100,
                            'step' => 1,
                          },
          'preview' => {
                         'tip' => 'Request a preview-quality scan.',
                         'default' => 'no',
                         'values' => ['yes','no']
                       },
          'speed' => {
                       'tip' => 'Determines the speed at which the scan proceeds.',
                       'default' => '0',
                                   'min' => 0,
                            'max' => 4,
                            'step' => 1,
                     },
          'resolution' => {
                            'tip' => 'Sets the resolution of the scanned image.',
                            'default' => '150',
                                   'min' => 100,
                            'max' => 1200,
                            'step' => 5,
                          },
          'power-save-time' => {
                                 'tip' => 'Allows control of the scanner\'s power save timer, dimming or turning off the light.',
                                 'default' => '65535',
                                 'values' => ['<int>']
                               },
          'quality-scan' => {
                              'tip' => 'Turn on quality scanning (slower but better).',
                              'default' => 'yes',
                              'values' => ['yes','no']
                            },
          'blue-gamma-table' => {
                                  'tip' => 'Gamma-correction table for the blue band.',
                                  'default' => 'inactive',
                                  'min' => 0,
                            'max' => 255,
                                }
        );
is_deeply(\%this, \%that, 'hp_scanjet5300c');
