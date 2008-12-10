package conf;
require Exporter;

use vars qw/@ISA @EXPORT $VERSION/;
@ISA = qw/Exporter/;
@EXPORT = qw/process_commandline/;

$VERSION = 1.0;

my %configure_info;

sub process_commandline {

    while($_ = shift @_) {

	if($_ =~ /-(.+)/) {
	    $configure_info{$_} = shift @_;
	}
    }
}

sub date { return $configure_info{'-date'}; }
sub screen { return $configure_info{'-screen'}; }
sub list { return $configure_info{'-list'}; }
sub enter_sig { return $configure_info{'-entry'}; }
sub exit_sig { return $configure_info{'-exit'}; }
sub start { return $configure_info{'-start'}; }
sub finish { return $configure_info{'-finish'}; }

sub portfolio { 
    return $configure_info{'-portfolio'} if exists $configure_info{'-portfolio'};
    return "portfolio";
}

sub strategy { 
    return $configure_info{'-strategy'} if exists $configure_info{'-strategy'};
    return "default";
}

sub startwith {

    return $configure_info{'-startwith'} if exists $configure_info{'-startwith'};
    return 5000;
}

sub risk_percent {

    return ($configure_info{'-risk'} / 100) if exists $configure_info{'-risk'};
    return 0.01;
}

sub draw_curve {

    return $configure_info{'-curve'} if exists $configure_info{'-curve'};
    return 0;
}

sub check_backtest_args {

    die "missing -list (ticker list file)" if not exists $configure_info{'-list'};
    die "missing -start (start date)" if not exists $configure_info{'-start'};
    die "missing -entry (entry signal)" if not exists $configure_info{'-entry'};
    die "missing -exit (exit signal)" if not exists $configure_info{'-exit'};
}


1;
