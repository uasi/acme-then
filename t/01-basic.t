use strict;
use warnings;
use Test::More tests => 5;

use Acme::Then;

{
    my @values;
    Acme::Then::do {
        push @values, 1;
    } then {
        push @values, 2;
    } then {
        push @values, 3;
    } done;

    is_deeply \@values, [1, 2, 3], 'do-then-done';
}

{
    my @values;
    Acme::Then::do {
        push @values, 1;
    } then {
        push @values, 2;
        return LAST;
    } then {
        push @values, 3;
    } done;

    is_deeply \@values, [1, 2], 'LAST';
}

{
    my @values;
    Acme::Then::do {
        push @values, 1;
        Acme::Then::do {
            push @values, 2;
            return LAST;
        } then {
            push @values, 'X';
        } done;
    } then {
        push @values, 3;
    } done;

    is_deeply \@values, [1, 2, 3], 'nested do-then-done';
}

{
    my @values;
    my @responses;
    my $count = 0;
    my $do_something = sub {
        my (undef, $cb) = @_;
        push @values, ++$count;
        $cb->("res $count");
    };

    Acme::Then::do {
        $do_something->(cb => NEXT);
    } then {
        my ($res) = @_;
        push @responses, $res;
        $do_something->(cb => NEXT);
    } then {
        my ($res) = @_;
        push @responses, $res;
    } done;

    is_deeply \@values, [1, 2], 'NEXT';
    is_deeply \@responses, ['res 1', 'res 2'], 'NEXT';
}
