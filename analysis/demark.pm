use screen_data;

use constant {
LOOKBACK => 55
};

sub DEMARK_Lookback {
    return LOOKBACK;
}

sub DEMARK_SETUP_Lookback {
    return 9;
}

#entry points to this module for use
#by macro expander and the rest of the code

sub td_buy_setup { return setup(\&buy_comp, \&buy_setup_perfect, 8) == 0  }
sub td_sell_setup { return setup(\&sell_comp, \&sell_setup_perfect, 8) == 0 }

sub td_combo_buy {  combo_signal(\&buy_comp, \&sell_comp, 
				 \&buy_setup_perfect, \&buy_countdown_perfect) }
sub td_combo_sell { combo_signal(\&sell_comp, \&buy_comp, 
				 \&sell_setup_perfect, \&sell_countdown_perfect) }
sub td_sequential_buy { sequential_signal(\&buy_comp, \&sell_comp, 
					  \&buy_setup_perfect, \&buy_countdown_perfect,
			                  \&cancel_buy_setup) };
sub td_sequential_sell { sequential_signal(\&sell_comp, \&buy_comp, 
					   \&sell_setup_perfect, \&sell_countdown_perfect,
			                   \&cancel_sell_setup) };


#and from here on out is the "guts" of
#the demark indicators

sub buy_comp {

    my $index = shift;
    my $span = shift;

    return $current_prices->[$index][CLOSE_IND] < 
	$current_prices->[$index + $span][CLOSE_IND];
}

sub sell_comp {

    my $index = shift;
    my $span = shift;

    return $current_prices->[$index][CLOSE_IND] > 
	$current_prices->[$index + $span][CLOSE_IND];
}

#to perfect a buy setup the low of price bar
#eight or nine must be less than the low of both
#bars six and seven
sub buy_setup_perfect {
   
    my $index = shift;  #assumed to be bar nine

    #establish the lowest low of bars six and seven
    my $low = ($current_prices->[$index + 2][LOW_IND] <
	       $current_prices->[$index + 3][LOW_IND]) ?
	       $current_prices->[$index + 2][LOW_IND] :
	       $current_prices->[$index + 3][LOW_IND];


    #establish the lowest low of bars eight and nine
    my $perf_low = ($current_prices->[$index + 1][LOW_IND] <
	       $current_prices->[$index][LOW_IND]) ?
	       $current_prices->[$index + 1][LOW_IND] :
	       $current_prices->[$index][LOW_IND];

    return $perf_low < $low;
}


#to perfect a sell setup the high of price bar
#eight or nine must be more than the high of both
#bars six and seven
sub sell_setup_perfect {
    
    my $index = shift;  #assumed to be bar nine

    #establish the highest high of bars six and seven
    my $hi = ($current_prices->[$index + 2][HIGH_IND] >
	       $current_prices->[$index + 3][HIGH_IND]) ?
	       $current_prices->[$index + 2][HIGH_IND] :
	       $current_prices->[$index + 3][HIGH_IND];


    #establish the highest high of bars eight and nine
    my $perf_hi = ($current_prices->[$index + 1][HIGH_IND] >
	       $current_prices->[$index][HIGH_IND]) ?
	       $current_prices->[$index + 1][HIGH_IND] :
	       $current_prices->[$index][HIGH_IND];


    return $perf_hi > $hi;

}

#to perfect a sell countdown the 13th bar high 
#must be greater than or equal to the 8th bar high
sub sell_countdown_perfect {

    my $eight = shift;
    my $thirteen = shift;

    return $current_prices->[$thirteen][HIGH_IND] >=
	$current_prices->[$eight][HIGH_IND];
}

#to perfect a buy countdown the 13th bar low
#must be less thn or equal to the 8th bar low
sub buy_countdown_perfect {

    my $eight = shift;
    my $thirteen = shift;

    return $current_prices->[$thirteen][LOW_IND] <=
	$current_prices->[$eight][LOW_IND];
}

#Cancel a sequential buy setup if, during the countdown
#phase of the indicator, a close exceeds the max high 
#registered during the setup (nine count) phase
sub cancel_buy_setup {

    my $flipindex = shift;
    my $setup_last = shift;
    my $countdown_last = shift;

    my $max = 0;

    for(my $i = $flipindex - 1; $i >= $setup_last; $i--) {

	if($current_prices->[$i][HIGH_IND] > $max) {
	    $max = $current_prices->[$i][HIGH_IND];
	}
    }

    for(my $x = $setup_last; $x >= $countdown_last; $x--) {

	if($current_prices->[$x][CLOSE_IND] > $max) {
	    return $x;
	}
    }
}

sub cancel_sell_setup {

    my $flipindex = shift;
    my $setup_last = shift;
    my $countdown_last = shift;

    my $min = 1000000;

    for(my $i = $flipindex - 1; $i >= $setup_last; $i--) {

	if($current_prices->[$i][LOW_IND] < $min) {
	    $min = $current_prices->[$i][LOW_IND];
	}
    }

    for(my $x = $setup_last; $x >= $countdown_last; $x--) {

	if($current_prices->[$x][CLOSE_IND] < $min) {
	    return $x;
	}
    }
}


#locate the price flip, which initializes
#the setup phase.  Look for a close that's
#higher or lower than the close four bars ago

sub locate_price_flip {

    my $cmp = shift;
    my $start = shift;
    my $idx;

    for($idx = $start; $idx >= 0; $idx--) {
	
	if(&$cmp($idx, 4)) {
	    return $idx;
	}
    }

    return -1;
}

#check the setup phase of the indicator.  Look
#for nine consecutive closes higher or lower than
#the close four bars earlier.  Once we have that,
#we "perfect" the setup by looking for criteria as
#shown in setup perfection functions

sub setup {

   my $cmp = shift;
   my $perfected = shift;
   my $start = shift;
   my $extend = shift;
   my $idx;

   #look for at least nine bars - remember we're off by one
   for($idx = $start; $idx > ($start - 9); $idx--) {
       return -1 if not &$cmp($idx, 4);
   }

   #see if there are more than nine
   if($extend) {

       while($idx > 0) {

	   if(&$cmp($idx - 1, 4)) {
	       $idx--;
	   } else {
	       last;
	   }
       }
   }

   if(($start - $idx) >= 9 && &$perfected($idx + 1)) {
       return $idx + 1;
   } else {
       return -1;
   }
}

sub countdown {

    my $cmp = shift;
    my $perfected = shift;
    my $start = shift;
    my $count = 0;
    my $eigth = -1;

    #start off one past where we need to be
    #so decrement can come at start of the loop
    #and we don't waste time with needless off-by-one

    my $i = $start + 1;
    while($i >= 0 && $count < 13) {

	$i--;
	
	if(&$cmp($i, 2)) {
	    $count++;
	}

	#since countdown days needn't be consecutive,
	#this value could be set more than once
	#unless we're careful to do otherwise 

	if($count == 8 && $eigth < 0) {
	    $eigth = $i;
	}
    }

    if($count == 13 && &$perfected($eigth, $i)) {
	return $i;
    } else {
	return -1;
    }
}

#TD Combo, not to be confused with sequential - for this one the 
#countdown phase retroactively overlaps the setup phase

sub combo_signal {

    my $cmp = shift;
    my $init = shift;
    my $perfect = shift;
    my $countperf = shift;

    my $index = LOOKBACK - 4;

    while($index >= 0) {

	my $flip = locate_price_flip($init, $index);

	#have to have enough space for both 
	#setup and countdown, a minimum of 13, zero indexed

	if($flip >= 12) {

	    my $setup = setup($cmp, $perfect, $flip - 1);
	    
	    if($setup > 0) {

		my $cdi = countdown($cmp, $countperf, $flip - 1);
		return 1 if $cdi == 0;
	    }

	} else {
	    last;
	}
	
	$index--;
    }
}

#TD sequential, NOT to be confused with TD combo

sub sequential_signal {

    my $cmp = shift;
    my $init = shift;
    my $perfect = shift;
    my $countperf = shift;
    my $cancel = shift;
    my $index = LOOKBACK - 4;

    print "\nCHECK SELL on $current_prices->[0][0]";

    while($index >= 0) {

	my $flip = locate_price_flip($init, $index);

	if($flip >= 20) {

	    my $setup = setup($cmp, $perfect, $flip - 1);

	    if($setup > 0) {

		my $cdi = countdown($cmp, $countperf, $setup);
		return 1 if $cdi == 0 && ! &$cancel($flip, $setup, $cdi);
	    }

	} else {
	    last;
	}
	
	$index--;
    }
}

1;
