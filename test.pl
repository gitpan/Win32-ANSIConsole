#!/usr/bin/perl -w
use strict;

# 'Visual' tests for Win32::ANSIConsole
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################
use Win32::ANSIConsole;
use Term::ANSIColor;

my $In = new Win32::Console (-10) or die $^E;
sub ReadK {
  my $nt = shift;
  $In->Flush();
  while(1) {
    my @event = $In->Input();
    if ($event[0] and !$event[1] and $event[5]) {
      my $t = uc(chr($event[5]));
      if ( $t eq 'Y' ) {
        return;
      }
      elsif ( $t eq 'N' ) {
        print "\n\nTest #$nt failed !!!\n";;
        exit;
      }
    }
  }
}

sub ReadD {
  my $nt = shift;
  $In->Flush();
  while(1) {
    my @event = $In->Input();
    if ($event[0] and !$event[1] and $event[5]) {
      my $t = uc(chr($event[5]));
      if ( $t eq 'Y' ) {
        return;
      }
      elsif ( $t eq 'N' ) {
        print "\n\nTest #$nt failed !!!\n";;
        exit;
      }
    }
    if ($event[0]) {
      print "\e[1D" if $event[3] == 37;
      print "\e[1A" if $event[3] == 38;
      print "\e[1C" if $event[3] == 39;
      print "\e[1B" if $event[3] == 40;
    }
  }
}


# test 01 - load
print "Module loaded Ok\n";

# test 02 - Erase Display
print "\e[2JHas the screen been cleared? ([y] or [n])";
ReadK(2);

# test 03 - Cursor Position
print "\n\nThe cursor is here -->\n\n";
print "Is the cursor at the end of the arrow? ([y] or [n])\e[2;22H";
ReadK(3);

# test 04 - Cursor Movement
print "\e[2JMove the cursor in the four directions with the keys of the keyboard.\n\n";
print "Is it Okay ? ([y] or [n])\e[10;40H";
ReadD(4);

# test 05 - Save and Restore Cursor Position
print "\e[2JDoes this countdown work?\n\n";
print "Response in \e[s";
foreach (qw (ten nine eight seven six five four three two)) {
  print "\e[u$_ seconds\e[K";
  sleep 1;
}
print "\e[uone second\e[K";
sleep 1;
print "\n\e[1Aand the response is ... [y] or [n]?\e[K";
ReadK(5);

# test 06 - Colors rendition
print "\e[2J\n  Normal:\n\n";
print "BLACK   \e[40;30m black \e[31mred \e[32mgreen \e[33myellow \e[34mblue \e[35mmagenta \e[36mcyan \e[37mwhite \e[0m\n";
print "RED     \e[41;30m black \e[31mred \e[32mgreen \e[33myellow \e[34mblue \e[35mmagenta \e[36mcyan \e[37mwhite \e[0m\n";
print "GREEN   \e[42;30m black \e[31mred \e[32mgreen \e[33myellow \e[34mblue \e[35mmagenta \e[36mcyan \e[37mwhite \e[0m\n";
print "YELLOW  \e[43;30m black \e[31mred \e[32mgreen \e[33myellow \e[34mblue \e[35mmagenta \e[36mcyan \e[37mwhite \e[0m\n";
print "BLUE    \e[44;30m black \e[31mred \e[32mgreen \e[33myellow \e[34mblue \e[35mmagenta \e[36mcyan \e[37mwhite \e[0m\n";
print "MAGENTA \e[45;30m black \e[31mred \e[32mgreen \e[33myellow \e[34mblue \e[35mmagenta \e[36mcyan \e[37mwhite \e[0m\n";
print "CYAN    \e[46;30m black \e[31mred \e[32mgreen \e[33myellow \e[34mblue \e[35mmagenta \e[36mcyan \e[37mwhite \e[0m\n";
print "WHITE   \e[47;30m black \e[31mred \e[32mgreen \e[33myellow \e[34mblue \e[35mmagenta \e[36mcyan \e[37mwhite \e[0m\n\n";
print "\n  Bold:\n\n";
print "BLACK   \e[40;30;1m black \e[31mred \e[32mgreen \e[33myellow \e[34mblue \e[35mmagenta \e[36mcyan \e[37mwhite \e[0m\n";
print "RED     \e[41;30;1m black \e[31mred \e[32mgreen \e[33myellow \e[34mblue \e[35mmagenta \e[36mcyan \e[37mwhite \e[0m\n";
print "GREEN   \e[42;30;1m black \e[31mred \e[32mgreen \e[33myellow \e[34mblue \e[35mmagenta \e[36mcyan \e[37mwhite \e[0m\n";
print "YELLOW  \e[43;30;1m black \e[31mred \e[32mgreen \e[33myellow \e[34mblue \e[35mmagenta \e[36mcyan \e[37mwhite \e[0m\n";
print "BLUE    \e[44;30;1m black \e[31mred \e[32mgreen \e[33myellow \e[34mblue \e[35mmagenta \e[36mcyan \e[37mwhite \e[0m\n";
print "MAGENTA \e[45;30;1m black \e[31mred \e[32mgreen \e[33myellow \e[34mblue \e[35mmagenta \e[36mcyan \e[37mwhite \e[0m\n";
print "CYAN    \e[46;30;1m black \e[31mred \e[32mgreen \e[33myellow \e[34mblue \e[35mmagenta \e[36mcyan \e[37mwhite \e[0m\n";
print "WHITE   \e[47;30;1m black \e[31mred \e[32mgreen \e[33myellow \e[34mblue \e[35mmagenta \e[36mcyan \e[37mwhite \e[0m\n";
print "\nAre the colors correct? ([y] or [n])";
ReadK(6);

# test 07 - Reverse video

print "\e[2J\n* Test for reverse video\n\n";
print "End of line normal:        \e[31m red on black \e[32;46m green on cyan \e[33;45m yellow on magenta \e[0m\n";
print "the same in reverse video: \e[31;7m red on black \e[32;46m green on cyan \e[33;45m yellow on magenta \e[0m\n";
print "\n\nIs this correct? ([y] or [n])\n(In reverse video the background and foreground colors are reversed).";
ReadK(7);

# test 08 -  Concealed mode
print "\n\n* Test on the concealed mode\n\n";
print "The word between the < and > is concealed: <\e[8minvisible\e[0m>";
print "\n\nIs this true? ([y] or [n])";
ReadK(8);


# test 09 - Characters table

my $tab = << "TAB";
\e(U
    º  0³  1³  2³  3³  4³  5³  6³  7³  8³  9³  A³  B³  C³  D³  E³  Fº
 ÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
  80º   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   º
 ÄÄÄºÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄº
  90º   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   º
 ÄÄÄºÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄº
  A0º   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   º
 ÄÄÄºÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄº
  B0º   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   º
 ÄÄÄºÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄº
  C0º   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   º
 ÄÄÄºÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄº
  D0º   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   º
 ÄÄÄºÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄº
  E0º   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   º
 ÄÄÄºÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄº
  F0º   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   ³   º
 ÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼\e(K
TAB
;
my $cp = $In->OutputCP();
print"\e[2J\nCP$cp\n";
print $tab;
print "\e[16A\e[6C\e[s\e(U";
my $c = 128;
for (my $i=0; $i<16; $i+=2) {
  print "\e[u\e[${i}B";
  for (my $j=0; $j<16; $j++) {
    print "\e[1m", chr($c++), "\e[0m\e[3C";
  }
}
print "\n\n\nThis is the current character table. Is this correct ([y] or [n]) ?";
ReadK(9);

# test 10 - Conversion

if ($cp == 850) {
  print "\e[2JAfter conversion to CP1252 (WinLatin1):\n";
  print $tab;
  print "\e[16A\e[6C\e[s";
  $c = 128;
  for (my $i=0; $i<16; $i+=2) {
    print "\e[u\e[${i}B";
    for (my $j=0; $j<16; $j++) {
      print "\e[1m", chr($c++), "\e[0m\e[3C";
    }
  }
  print "\e[2B";
  print "\nIs this correct ([y] or [n]) ?";
  ReadK(10);
}

# end of test
print "\e[2J\nAll tests succeeded!\n";
