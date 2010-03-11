Perl Portable
=============
Copyright 2008 Shawn Faucher
PortableApps.com launcher and installer copyright 2004-2008 John T. Haller.

Website: http://portableapps.com

This software is OSI Certified Open Source Software.
OSI Certified is a certification mark of the Open Source Initiative.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


ABOUT PERL
==========
Perl is a dynamic programming language created by Larry Wall and first released in 
1987. Perl borrows features from a variety of other languages including C, shell 
scripting (sh), AWK, sed and Lisp.

Structurally, Perl is based on the brace-delimited block style of AWK and C, and 
was widely adopted for its strengths in string processing and lack of the arbitrary 
limitations of many scripting languages at the time.


ABOUT PERL PORTABLE
===================
Perl Portable provides a portable installation of the open source Strawberry Perl
distribution, including optional support of its ability to compile CPAN modules.
The Perl binaries, scripts and essential modules are installed in the CommonFiles
folder of the PortableApps.com framework for use as a 'library' of sorts for other 
PortableApp.com style applications which require Perl.  The development tools for
Module compilation are optionally installed in PerlPortable, including a launcher
which will open a cmd shell (or suitable PortableApps.com alternative) with the 
required environment variables set to enable Module compilation.

PortableApp.com applications which need Perl should first look for Perl.exe in
CommonFiles\Perl\bin before checking system locations (C:\Perl\bin, etc).


LICENSE
=======
This code is released under the GPL.  The source code for the launcher and 
installer is included with this package as NSIS scripts.  The open source NSIS 
(Nullsoft Scriptable Install System) compiler is needed to compile these scripts 
into Windows executables.  This is available at http://nsis.sourceforge.net.


INSTALLATION / DIRECTORY STRUCTURE
==================================
By default, the following directory structure is expected:

-\CommonFiles
		+\Perl
			+\bin
			+\lib
			+\site
-\PerlPortable (Optional)
		+\App\
			+\AppInfo\
		+\Data\
			+\Scripts
			+\Settings

It can be used in other directory configurations by including the PerlPortable.ini 
file in the PerlPortable directory and configuring it as detailed in the INI file 
section below.


PERLPORTABLE.INI CONFIGURATION
==============================
The Perl Portable Launcher will look for an ini file called PerlPortable.ini within 
its directory (see the paragraph above in the Installation/Directory Structure 
section).  If you are happy with the default options, it is not necessary, though.  
Note that if no INI file is present, the Perl Portable Launcher will check for
Console Portable installed in the directory above Perl Portable, otherwise it will
use the default command shell for your OS.  There is an example INI included with 
this package to get you started.  The INI file is formatted as follows (shown with 
an example configuration):

[PerlPortable]
PerlDirectory=..\CommandPromptPortable
PerlExecutable=CommandPromptPortable.exe
SettingsDirectory=Data\settings
AdditionalParameters=
DisableSplashScreen=false

The PerlDirectory entry should be set to the *relative* path of a command shell to
use for Perl development.

The PerlExecutable entry should be set to the filename for the command shell located
in PerlDirectory.

The SettingsDirectory entry should be set to the *relative* path to the directory 
containing your settings from the current directory.  All must be a subdirectory 
(or multiple subdirectories) of the directory containing PerlPortable.exe.  The 
default entries for these are described in the installation section above.

All three of the above parameters are required or the INI file is ignored.

The AdditionalParameters entry allows you to specify additional parameters to be 
passed to the command shell.

The DisableSplashScreen entry allows you to run the Perl Portable Launcher without 
the splash screen showing up.  The default is false.


NSIS PLUGINS
============
The following NSIS plugins are necessary to compile the source:
	NewAdvSplash - http://nsis.sourceforge.net/NewAdvSplash_plug-in


ABOUT THE AUTHORS
=================
Shawn Faucher aka Rayven01 created the PerlPortable launcher from the PeaZip Portable 
release on PortableApps.com.


PROGRAM HISTORY
===============
6/11/2008 - 5.10.0.1 Development Test 1
- Updated to Strawberry Perl 5.10.0.1-1, which includes ppm support

4/3/2008 - 5.10.0.0 Development Test 1
- Initial test release