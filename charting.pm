package charting;
require Exporter;
use Chart::Lines;

use vars qw/@ISA @EXPORT $VERSION/;
@EXPORT = qw/draw_line_chart/;
@ISA = qw/Exporter/;
$VERSION = 1.0;

sub draw_line_chart {

    my $points = shift;
    my $filename = shift;

    @data = (@$points);
    return if @data == 0;

    $linechart = Chart::Lines->new(800, 600);
    $linechart->set('title' => 'Equity Curve');
    $linechart->set('legend' => 'none');
    $linechart->set('brush_size' => 3);

    $i = 0;
    foreach (@data) {
	$linechart->add_pt($i++, $_);
    }

    $linechart->png($filename);
}

1;
