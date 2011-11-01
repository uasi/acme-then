use strict;
use warnings;
use Test::More tests => 1;

use Acme::Then;
use AE;

{
    my $cv = AE::cv;
    my @values;
    Acme::Then::do {
        push @values, 1;
        $_ = AE::timer 0.1, 0, NEXT;
        push @values, 2;
    } then {
        push @values, 4;
        $cv->send;
    };

    push @values, 3;
    $cv->recv;
    push @values, 5;

    is_deeply \@values, [1..5];
}
