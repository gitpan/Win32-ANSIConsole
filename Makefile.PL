use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Win32::ANSIConsole',
    'VERSION_FROM'	=> 'ANSIConsole.pm', # finds $VERSION
    'PREREQ_PM'		=> {Win32::Console => 0.03}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'ANSIConsole.pm', # retrieve abstract from module
       AUTHOR     => 'J-L. Morel <jl_morel@bribes.org>') : ()),
);
