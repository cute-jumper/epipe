#!/usr/bin/perl

use warnings;
use strict;
use POSIX;
use File::Temp q{tempfile};

$/=undef;

my ($tty)=POSIX::ttyname(2);
if (! defined $tty)
{
    $tty = "/dev/tty";
}
my ($fh, $tmp)=tempfile();
die "cannot create tempfile" unless $fh;
print ($fh <STDIN>) || die "write temp: $!";
close $fh;
close STDIN;
open(STDIN, "<" . $tty) || die "reopen stdin: $!";
open(OUT, ">&STDOUT") || die "save stdout: $!";
close STDOUT;
open(STDOUT, ">" . $tty) || die "reopen stdout: $!";

my @editor="emacs";
if (-x "/usr/bin/editor") {
	@editor="/usr/bin/editor";
}
if (exists $ENV{EDITOR}) {
	@editor=split(' ', $ENV{EDITOR});
}
if (exists $ENV{VISUAL}) {
	@editor=split(' ', $ENV{VISUAL});
}
my $ret=system(@editor, $tmp);
if ($ret != 0) {
	die "@editor exited nonzero, aborting\n";
}

open (IN, $tmp) || die "$0: cannot read $tmp: $!\n";
print (OUT <IN>) || die "write failure: $!";
close IN;
unlink($tmp);
