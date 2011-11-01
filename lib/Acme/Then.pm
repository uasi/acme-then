package Acme::Then;
use parent 'Exporter';
our $VERSION = '0.01';

use 5.008009;
use strict;
use warnings;
use Carp;

our @EXPORT = qw(LAST NEXT then done);

our $_NEXT;
our $_NEXTCALL;

sub LAST {
    goto _ACME_THEN_LAST;
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
        _call($code_list, @args);
        @args = ();
    }
    _ACME_THEN_LAST:
}

sub _call {
    my ($code_list, @args) = @_;

    return unless @$code_list;

    my $code = shift @$code_list;
    local $_NEXTCALL = 0;
    local $_NEXT = sub {
        _call_each($code_list, @_);
    };
    $code->(@args);
    goto _ACME_THEN_LAST if $_NEXTCALL;
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
        ...
    } then {
        ...
        LAST if ...;
    } then {
        ...
    } done;

You can turn a callback chain

    do_something(cb => sub {
        do_something(cb => sub {
            do_something(cb => sub {
                my ($res) = @_;
                say $res;
            });
        });
    });

into

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

=head1 DESCRIPTION

Do this, then do that.

=head1 FUNCTIONS

=head2 do

C<do> {} then {} done;

=head2 then

do {} C<then> {} done;

=head2 done

do {} then {} C<done>;

=head2 LAST

Exits from a do-then-done construct.

=head2 NEXT

Returns a coderef. The arguments to the coderef are set to
the next block's C<@_>. The coderef should not be called more than once
within the same block.

=head1 AUTHOR

Tomoki Aonuma E<lt>uasi@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
