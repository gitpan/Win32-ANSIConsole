package Win32::ANSIConsole;
#
# Copyright (c) 2002 Jean-Louis Morel <jl_morel@bribes.org>
#
# Version 0.01 (01/11/2002)
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either the
# GNU General Public License or the Artistic License for more details.
#

use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';
our $DEBUG = 0;

# print overloading

package Win32::ANSIConsole::IO;
use Win32::Console;

my %color = ( 30 => 0,                                               # black foreground
              31 => FOREGROUND_RED,                                  # red foreground
              32 => FOREGROUND_GREEN,                                # green foreground
              33 => FOREGROUND_RED|FOREGROUND_GREEN,                 # yellow foreground
              34 => FOREGROUND_BLUE,                                 # blue foreground
              35 => FOREGROUND_BLUE|FOREGROUND_RED,                  # magenta foreground
              36 => FOREGROUND_BLUE|FOREGROUND_GREEN,                # cyan foreground
              37 => FOREGROUND_RED|FOREGROUND_GREEN|FOREGROUND_BLUE, # white foreground
              40 => 0,                                               # black background
              41 => BACKGROUND_RED,                                  # red background
              42 => BACKGROUND_GREEN,                                # green background
              43 => BACKGROUND_RED|BACKGROUND_GREEN,                 # yellow background
              44 => BACKGROUND_BLUE,                                 # blue background
              45 => BACKGROUND_BLUE|BACKGROUND_RED,                  # magenta background
              46 => BACKGROUND_BLUE|BACKGROUND_GREEN,                # cyan background
              47 => BACKGROUND_RED|BACKGROUND_GREEN|BACKGROUND_BLUE, # white background
            );

sub new {
  my $self = bless {}, shift;
  $self->{'Out'} = new Win32::Console(STD_OUTPUT_HANDLE);
  $self->{x} = 0;
  $self->{y} = 0;           # to save cursor position
  $self->{foreground} = 7;
  $self->{background} = 0;
  $self->{bold} = 0;
  $self->{revideo} = 0;
  $self->{concealed} = 0;
  $self->{cp} = Win32::Console::OutputCP() == 850 ? 850 : 0; # conversion ok if cp850 (DOSLatin1)
  $self->{conv} = $self->{cp};
  return $self;
}

sub _PrintString {
  my ($self, $s) = @_;
  my ($x, $y, $n);
  if ( $s =~ /([^\e]*)?\e([\[(])([0-9\;\=]*)([a-zA-Z])(.*)/s ) {
    $self->{Out}->Write((_conv($self, $1)));
    if ( $2 eq '[' ) {
      if ($4 eq 'm') {                        # ESC[#;#;....;#m Set display attributes
        my @attributs = split /\;/, $3;
        my $attribut;
        foreach my $attr (@attributs) {
          if ( $attr ) {
            if ( $attr == 1 ) {
              $self->{bold} = 1;
            }
            elsif ( $attr == 7 ) {
              $self->{revideo} = 1;
            }
            elsif ( $attr == 8 ) {
              $self->{concealed} = 1;
            }
            elsif ( $attr>=30 and $attr<=37 ) {
              $self->{foreground} = $attr-30;
            }
            elsif ( $attr>=40 and $attr<=47 ) {
              $self->{background} = $attr-40;
            }
          }
          else {                                # ESC[0m reset
            $self->{foreground} = 7;
            $self->{background} = 0;
            $self->{bold} = 0;
            $self->{revideo} = 0;
            $self->{concealed} = 0;
          }
        }
        if ($self->{revideo}) {
          $attribut = $color{40+$self->{foreground}}|$color{30+$self->{background}};
        }
        else {
          $attribut = $color{30+$self->{foreground}}|$color{40+$self->{background}};
        }
        $attribut |= FOREGROUND_INTENSITY if $self->{bold};
        $self->{Out}->Attr($attribut);
      }
      elsif ($4 eq 'J' and $3 == 2) {         # ESC[2J Clear screen and home cursor
        $self->{Out}->Cls();
        $self->{Out}->Cursor(0, 0);
      }
      elsif ($4 eq 'H' or $4 eq 'f') {        # ESC[#;#H or ESC[#;#f Moves cusor to line #, column #
        ($y, $x) = split /\;/, $3;
        $x = 0 unless $x;    # ESC[;5H == ESC[0;5H ...etc
        $y = 0 unless $y;    # $x et $y should be numbers for Cursor method (not '')
        $self->{Out}->Cursor($x, $y);
      }
      elsif ($4 eq 'A') {                     # ESC[#A Moves cursor up # lines
        ($x, $y) = $self->{Out}->Cursor();
        $n = $3 eq ''? 1 : $3;  # ESC[A == ESC[1A
        $self->{Out}->Cursor($x, $y-$n);
      }
      elsif ($4 eq 'B') {                     # ESC[#B Moves cursor down # lines
        ($x, $y) = $self->{Out}->Cursor();
        $n = $3 eq ''? 1 : $3;  # ESC[B == ESC[1B
        $self->{Out}->Cursor($x, $y+$n);
      }
      elsif ($4 eq 'C') {                     # ESC[#C Moves cursor forward # spaces
        ($x, $y) = $self->{Out}->Cursor();
        $n = $3 eq ''? 1 : $3;  # ESC[C == ESC[1C
        $self->{Out}->Cursor($x+$n, $y);
      }
      elsif ($4 eq 'D') {                     # ESC[#D Moves cursor back # spaces
        ($x, $y) = $self->{Out}->Cursor();
        $n = $3 eq ''? 1 : $3;  # ESC[D == ESC[1D
        $self->{Out}->Cursor($x-$n, $y);
      }
      elsif ($4 eq 's') {                     # ESC[s Saves cursor position for recall later
        ($x, $y) = $self->{Out}->Cursor();
        $self->{x} = $x;
        $self->{y} = $y;
      }
      elsif ($4 eq 'u') {                     # ESC[u Return to saved cursor position
        $self->{Out}->Cursor($self->{x}, $self->{y});
      }
      elsif ($4 eq 'K') {                     # ESC[K Clear to end of line
        my @info = $self->{Out}->Info();
        my $s = ' 'x($info[7]-$info[2]+1);
        $self->{Out}->Write($s);
        $self->{Out}->Cursor($info[2], $info[3]);
      }
      else {
        print STDERR "\e$2$3$4" if $DEBUG;     # if ESC-code not implemented
      }
    }
    else {
      if ($4 eq 'U') {                         # ESC(U no mapping
        $self->{conv} = 0;
      }
      elsif ($4 eq 'K') {                      # ESC(K mapping if it exist
        $self->{conv} = $self->{cp};
      }
      else {
        print STDERR "\e$2$3$4" if $DEBUG;     # if ESC-code not implemented
      }
    }
    _PrintString($self, $5);
  }
  else {
    $self->{Out}->Write(_conv($self, $s));
  }
}

sub _conv {                     # conversion
  my $self = shift;
  my $s = shift;
  if ( $self->{concealed} ) {
    $s =~ s/\S/ /g;
  }
  elsif ( $self->{conv} == 850 ) {     # map cp1252 --> cp850
    $s =~ s/ú/oe/g;
    $s =~ s/å/OE/g;
    $s =~ tr{ÄÅÇÉÑÖÜáàâäãçéèêëíìîïñóòôöõùûü†°¢£§•¶ß®©™´¨≠ÆØ∞±≤≥¥µ∂∑∏π∫ªºΩæø¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷◊ÿŸ⁄€‹›ﬁﬂ‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ˜¯˘˙˚¸˝˛ˇ}
            {E ,ü__≈Œ^_S< Z  ''""˙ƒ~©s> zY ≠Ωúœæ›ı˘∏¶Æ™ƒ©Ó¯Ò˝¸ÔÊÙ˙˜˚ßØ¨´Û®∑µ∂«éèíÄ‘ê“”ﬁ÷◊ÿ—•„‡‚ÂôûùÎÈÍöÌË·Ö†É∆ÑÜëáäÇàâç°åã–§ï¢ì‰îˆõó£ñÅÏÁò}
  }
return $s;
}

sub print {
  my $self = shift;
  foreach my $s (@_) {
    $self->_PrintString($s)
  }
}

sub TIEHANDLE { shift->new(@_)             }
sub PRINT     { shift->print(@_)           }
sub PRINTF    { shift->print(sprintf(@_))  }
1;

# end print overloading

## Win32::ANSIConsole Module Interface

package Win32::ANSIConsole;

# Create tied filehandle for print overloading.

tie *NEW_OUT, 'Win32::ANSIConsole::IO';
select NEW_OUT;

1;
__END__

# POD documentation

=head1 NAME

Win32::ANSIConsole - Perl extension to emulate ANSI console on Win32 system.

=head1 SYNOPSIS

  use Win32::ANSIConsole;

  print "\e[1;34mThis text is bold blue.\e[0m\n";
  print "This text is normal.\n";
  print "\e[33;45;1mBold yellow on magenta.\e[0m\n";
  print "This text is normal.\n";

With the Term::ANSIColor module one increases the legibility:

  use Win32::ANSIConsole;
  use Term::ANSIColor;

  print color 'bold blue';
  print "This text is bold blue.\n";
  print color 'reset';
  print "This text is normal.\n";
  print colored ("Bold yellow on magenta.\n", 'bold yellow on_magenta');
  print "This text is normal.\n";

=head1 DESCRIPTION

Windows NT/2000/XP does not support ANSI escape sequences in Win32 Console
applications.

This module emulate an ANSI console for the script which uses it.
Only the escape codes of the ansi.sys driver has been implemented.

Caution: this module is still in beta stage; don't use it in a production script.

=head2 Escape sequences for Cursor Movement

=item * \e[#;#H

CUP: Cursor Position: Moves the cursor to the specified position. The first #
specifies the line number, the second # specifies the column.
If you do not specify a position, the cursor moves to the
home position: the upper-left corner of the screen (line 0, column 0).

=item * \e[#;#f

Works the same way as the preceding escape sequence.

=item * \e[#A

CUU: Cursor Up: Moves the cursor up by the specified number of lines without
changing columns. If the cursor is already on the top line, this sequence
is ignored.

=item * \e[#B

CUD: Cursor Down: Moves the cursor down by the specified number of lines
without changing columns. If the cursor is already on the bottom line,
this sequence is ignored.

=item * \e[#C

CUF: Cursor Forward: Moves the cursor forward by the specified number of
columns without changing lines. If the cursor is already in the
rightmost column, this sequence is ignored.

=item * \e[#D

CUB: Cursor Backward: Moves the cursor back by the specified number of
columns without changing lines. If the cursor is already in the leftmost
column, this sequence is ignored.

=item * \e[s

SCP: Save Cursor Position: Saves the current cursor position. You can move
the cursor to the saved cursor position by using the Restore Cursor
Position sequence.

=item * \e[u

RCP: Restore Cursor Position: Returns the cursor to the position stored
by the Save Cursor Position sequence.

=item * \e[2J

ED: Erase Display: Clears the screen and moves the cursor to the home
position (line 0, column 0).

=item* \e[K

EL: Erase Line: Clears all characters from the cursor position to the
end of the line (including the character at the cursor position).

=head2 Escape sequences for Set Graphics Rendition

=item * \e[#;...;#m

SGM: Set Graphics Mode: Calls the graphics functions specified by the
following values. These specified functions remain active until the next
occurrence of this escape sequence. Graphics mode changes the colors and
attributes of text (such as bold and underline) displayed on the
screen.

=over

=item * Text attributes

       0    All attributes off
       1    Bold on
       4    Underscore on (not implemented)
       5    Blink on      (not implemented)
       7    Reverse video on
       8    Concealed on

=item * Foreground colors

       30    Black
       31    Red
       32    Green
       33    Yellow
       34    Blue
       35    Magenta
       36    Cyan
       37    White

=item * Background colors

       40    Black
       41    Red
       42    Green
       43    Yellow
       44    Blue
       45    Magenta
       46    Cyan
       47    White

=back

=head2 Escape sequences for Select Character Set

=item * \e(U

Select null mapping - straight to character from the codepage of the console.

=item * \e(K

Select Windows to DOS mapping, if the corresponding map exist; no effect otherwise.
This is the default mapping (if the map exist, of course).

Currently, only the conversion from cp1250 (WinLatin1) to cp850 (DOSLatin1) is
there processed. Contact me for other mapping.

=head1 SEE ALSO

L<Win32::Console>, L<Term::ANSIColor>.

=head1 AUTHOR

J-L Morel E<lt>jl_morel@bribes.orgE<gt>

Home page: http://www.bribes.org/perl/wANSIConsole.html

=head1 CREDITS

Render unto CÊsar the things which are CÊsar's...

This module use the module Win32::Console. Thanks to Aldo Calpini.

The method used to overload the print function is due to Matt Sergeant
(see his module Win32::ASP).

=head1 COPYRIGHT

Copyright (c) 2002 J-L Morel. All rights reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
