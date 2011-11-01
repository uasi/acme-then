package Acme::Then;
use parent 'Exporter';
our $VERSION = '0.01';

use 5.008009_01;
use strict;
use warnings;
use Carp;

our @EXPORT = qw(LAST NEXT then done);

our $_LAST;
our $_NEXT;
our $_NEXTCALL;

sub LAST {
    $_LAST = 1;
}

sub NEXT {
    if (++$_NEXTCALL > 1) {
        croak 'NEXT called more than once in the same block';
    }
    $_NEXT;
}

sub do (&$) {
    my ($code, $code_list) = @_;
    unshift @$code_list, $code;
    local $_LAST;
    local $_NEXT;
    _call_each($code_list);
}

sub then (&$) {
    my ($code, $code_list) = @_;
    unshift @$code_list, $code;
    $code_list;
}

sub done {
    [sub {}];
}

sub _call_each {
    my ($code_list, @args) = @_;
    while (@$code_list) {
        @args = _call($code_list, @args);
        last if $_LAST;
    }
}

sub _call {
    my ($code_list, @args) = @_;

    return @args unless @$code_list;

    my $code = shift @$code_list;
    local $_NEXTCALL = 0;
    local $_NEXT = sub {
        _call_each($code_list, @_);
    };
    $code->(@args);
    return;
}

1;

__END__

=head1 NAME

Acme::Then - The do-this-then-do-that utility

=begin readme

=head1 INSTALLATION

To install this module, run the following commands:

    perl Makefile.PL
    make
    make test
    make install

=end readme

=head1 SYNOPSIS

    Acme::Then::do {
        print '1';
    } then {
        print '2';
    } then {
        print '3';
    } done; # => 123

    Acme::Then::do {
        print '1';
    } then {
        print '2';
        return LAST;
    } then {
        print '3';
    } done; # => 12

    sub do_something {
        my (undef, $cb) = @_;
        say 'doing something';
        $cb->('did something');
    }

    do_something(cb => sub {
        do_something(cb => sub {
            do_something(cb => sub {
                my ($res) = @_;
                say $res;
            });
        });
    });

    # Turns into

    Acme::Then::do {
        do_something(cb => NEXT);
    } then {
        do_something(cb => NEXT);
    } then {
        do_something(cb => NEXT);
    } then {
        my ($res) = @_;
        say $res;
    } done;

=head1 AUTHOR

Tomoki Aonuma E<lt>uasi@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
