package Gscan2pdf::Canvas;

use strict;
use warnings;
use Goo::Canvas;
use Glib 1.220 qw(TRUE FALSE);    # To get TRUE and FALSE
use Readonly;
Readonly my $_100_PERCENT => 100;
Readonly my $_360_DEGREES => 360;
my $SPACE = q{ };
my $EMPTY = q{};

BEGIN {
    use Exporter ();
    our ( $VERSION, @EXPORT_OK, %EXPORT_TAGS );

    $VERSION = '1.8.0';

    use base qw(Exporter Goo::Canvas);
    %EXPORT_TAGS = ();    # eg: TAG => [ qw!name1 name2! ],

    # your exported package globals go here,
    # as well as any optionally exported functions
    @EXPORT_OK = qw();
}

sub new {
    my ( $class, $page, $edit_callback ) = @_;

    # Set up the canvas
    my $self = Goo::Canvas->new;
    my $root = $self->get_root_item;
    if ( not defined $page->{w} ) {

        # quotes required to prevent File::Temp object being clobbered
        my $pixbuf = Gtk2::Gdk::Pixbuf->new_from_file("$page->{filename}");
        $page->{w} = $pixbuf->get_width;
        $page->{h} = $pixbuf->get_height;
    }
    $self->set_bounds( 0, 0, $page->{w}, $page->{h} );

    # Attach the text to the canvas
    for my $box ( @{ $page->boxes } ) {
        boxed_text( $self->get_root_item, $box, $edit_callback );
    }
    $self->{page} = $page;
    bless $self, $class;
    return $self;
}

# Draw text on the canvas with a box around it

sub boxed_text {
    my ( $root, $box, $edit_callback ) = @_;
    my ( $x1, $y1, $x2, $y2 ) = @{ $box->{bbox} };
    my $x_size = abs $x2 - $x1;
    my $y_size = abs $y2 - $y1;
    my $g      = Goo::Canvas::Group->new($root);
    $g->translate( $x1, $y1 );

    # add box properties to group properties
    map { $g->{$_} = $box->{$_}; } keys %{$box};

    # draw the rect first to make sure the text goes on top
    # and receives any mouse clicks
    my $confidence =
      defined $box->{confidence} ? $box->{confidence} : $_100_PERCENT;
    $confidence = $confidence > 64    ## no critic (ProhibitMagicNumbers)
      ? 2 * int( ( $confidence - 65 ) / 12 ) ## no critic (ProhibitMagicNumbers)
      + 10                                   ## no critic (ProhibitMagicNumbers)
      : 0;
    my $color = defined $box->{confidence}
      ? sprintf '#%xfff%xfff%xfff',
      0xf - int( $confidence / 10 ),         ## no critic (ProhibitMagicNumbers)
      $confidence, $confidence
      : '#7fff7fff7fff';
    my $rect = Goo::Canvas::Rect->new( $g, 0, 0, $x_size, $y_size,
        'stroke-color' => $color );

    if ( $box->{text} ) {

        #        # show text baseline (currently of no use)
        #        if ($box->{baseline} and $box->{baseline} >= $y1) {
        #            $rect = Goo::Canvas::Rect->new( $g,
        #                 0, $box->{baseline} - $y1, $x_size, 1,
        #                'stroke-color' => 'yellow');
        #        }

        my $text;
        if ( $box->{type} eq 'page' ) {

            # only basic info on text, so simply create it
            $text = Goo::Canvas::Text->new( $g, $box->{text}, 0, 0, $x_size,
                'nw', 'height' => $y_size );
        }
        else {
           # create text and then scale, shift & rotate it into the bounding box
            my $angle =
              defined( $box->{textangle} )
              ? ( -$box->{textangle} % $_360_DEGREES )
              : 0;
            $text = Goo::Canvas::Text->new(
                $g,
                $box->{text},
                $x_size / 2,
                $y_size / 2,
                -1, 'center',    ## no critic (ProhibitMagicNumbers)
                'font' => 'Sans '
                  . (
                      $angle
                    ? $x_size
                    : $y_size
                  )
            );
            my $bounds = $text->get_bounds;
            my $scale =
              ( $angle ? $y_size : $x_size ) / ( $bounds->x2 - $bounds->x1 );
            $text->set_simple_transform( 0, 0, $scale, $angle );
            $bounds = $text->get_bounds;
            my $x_offset = ( $x1 + $x2 - $bounds->x1 - $bounds->x2 ) / 2;
            my $y_offset = ( $y1 + $y2 - $bounds->y1 - $bounds->y2 ) / 2;
            $text->set_simple_transform( $x_offset, $y_offset, $scale, $angle );
        }

        # clicking text box produces a dialog to edit the text
        if ($edit_callback) {
            $text->signal_connect( 'button-press-event' => $edit_callback );
        }
    }
    if ( $box->{contents} ) {
        for my $box ( @{ $box->{contents} } ) {
            boxed_text( $g, $box, $edit_callback );
        }
    }

    # $rect->signal_connect(
    #  'button-press-event' => sub {
    #   my ( $widget, $target, $ev ) = @_;
    #   print "rect button-press-event\n";
    #   #  return TRUE;
    #  }
    # );
    # $g->signal_connect(
    #  'button-press-event' => sub {
    #   my ( $widget, $target, $ev ) = @_;
    #   print "group $widget button-press-event\n";
    #   my $n = $widget->get_n_children;
    #   for ( my $i = 0 ; $i < $n ; $i++ ) {
    #    my $item = $widget->get_child($i);
    #    if ( $item->isa('Goo::Canvas::Text') ) {
    #     print "contains $item\n", $item->get('text'), "\n";
    #     last;
    #    }
    #   }
    #   #  return TRUE;
    #  }
    # );
    return;
}

# Set the text in the given widget

sub set_box_text {
    my ( $self, $widget, $text ) = @_;

    # per above: group = text's parent, group's 1st child = rect
    my $g    = $widget->get_property('parent');
    my $rect = $g->get_child(0);
    if ( length $text ) {
        $widget->set( text => $text );
        $g->{text}       = $text;
        $g->{confidence} = $_100_PERCENT;

        # color for 100% confidence
        $rect->set_property( 'stroke-color' => '#efffefffefff' );

        # re-adjust text size & position
        if ( $g->{type} ne 'page' ) {
            my ( $x1, $y1, $x2, $y2 ) = @{ $g->{bbox} };
            my $x_size = abs $x2 - $x1;
            my $y_size = abs $y2 - $y1;
            $widget->set_simple_transform( 0, 0, 1, 0 );
            my $angle =
              defined( $g->{textangle} )
              ? ( -$g->{textangle} % $_360_DEGREES )
              : 0;
            my $bounds = $widget->get_bounds;
            my $scale =
              ( $angle ? $y_size : $x_size ) / ( $bounds->x2 - $bounds->x1 );
            $widget->set_simple_transform( 0, 0, $scale, $angle );
            $bounds = $widget->get_bounds;
            my $x_offset = ( $x1 + $x2 - $bounds->x1 - $bounds->x2 ) / 2;
            my $y_offset = ( $y1 + $y2 - $bounds->y1 - $bounds->y2 ) / 2;
            $widget->set_simple_transform( $x_offset,
                $y_offset, $scale, $angle );
        }
    }
    else {
        delete $g->{text};
        $g->remove_child(0);
        $g->remove_child(1);
    }
    $self->canvas2hocr();
    return;
}

# Convert the canvas into hocr

sub canvas2hocr {
    my ($self) = @_;
    my ( $x, $y, $w, $h ) = $self->get_bounds;
    my $root   = $self->get_root_item;
    my $string = _group2hocr($root);
    $self->{page}{hocr} = <<"EOS";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN
 http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
 <title>OCR Output</title>
</head>
<body>
$string
</body>
</html>
EOS
    return;
}

sub _group2hocr {
    my ($parent) = @_;
    my $string = $EMPTY;

    for my $i ( 0 .. $parent->get_n_children - 1 ) {
        my $group = $parent->get_child($i);

        if ( ref($group) eq 'Goo::Canvas::Group' ) {

            # try to preserve as much information as possible
            if ( $group->{bbox} and $group->{type} ) {
                my $block_type = (
                         $group->{type} eq 'page'
                      or $group->{type} eq 'column'
                ) ? 'div' : 'span';
                my $type =
                  $group->{type} eq 'column' ? 'carea' : $group->{type};
                $string .= "<$block_type class='ocr_$type'";
                if ( $group->{id} ) { $string .= " id='$group->{id}'" }
                my $title = " title='bbox " . join $SPACE, @{ $group->{bbox} };
                if ( $group->{text} ) {
                    if ( $group->{textangle} ) {
                        $title .= '; textangle ' . $group->{textangle};
                    }
                    if ( $group->{baseline} ) {
                        $title .= '; baseline ' . $group->{baseline};
                    }
                    if ( $group->{confidence} ) {
                        $title .= '; x_wconf ' . $group->{confidence};
                    }
                    $title .= "'>$group->{text}";
                }
                else {
                    $title .= "'>";
                }
                $string .= $title . _group2hocr($group) . "</$block_type>";
            }
        }
    }
    return $string;
}

1;

__END__
