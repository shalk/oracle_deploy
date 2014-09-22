#!/usr/bin/env perl

use strict;
use warnings;
use Socket;
my $ip      = $ARGV[0];
my $netmask = $ARGV[1];
print  inet_ntoa( inet_aton($ip) & inet_aton($netmask) );


