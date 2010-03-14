;Copyright (C) 2004-2008 John T. Haller
;Copyright (C) 2007-2008 Shawn Faucher
;Copyright (C) 2009-2010 Chazz Wolcott

;Website: http://PortableApps.com/PerlPortable

;This software is OSI Certified Open Source Software.
;OSI Certified is a certification mark of the Open Source Initiative.

;This program is free software; you can redistribute it and/or
;modify it under the terms of the GNU General Public License
;as published by the Free Software Foundation; either version 2
;of the License, or (at your option) any later version.

;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.

;You should have received a copy of the GNU General Public License
;along with this program; if not, write to the Free Software
;Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

!define PORTABLEAPPNAME "Perl Portable"
!define NAME "PerlPortable"
!define APPNAME "Perl"
!define VER "0.0.0.1"
!define WEBSITE "PortableApps.com/PerlPortable"
!define DEFAULTEXE "NA"
!define DEFAULTAPPDIR "Strawberry"
!define DEFAULTSETTINGSPATH "Settings"

;=== Program Details
Name "${PORTABLEAPPNAME}"
OutFile "..\..\${NAME}.exe"
Caption "${PORTABLEAPPNAME} | PortableApps.com"
VIProductVersion "${VER}"
VIAddVersionKey ProductName "${PORTABLEAPPNAME}"
VIAddVersionKey Comments "Allows ${APPNAME} to be run from a removable drive.  For additional details, visit ${WEBSITE}"
VIAddVersionKey CompanyName "PortableApps.com"
VIAddVersionKey LegalCopyright "PortableApps.com and contributors"
VIAddVersionKey FileDescription "${PORTABLEAPPNAME}"
VIAddVersionKey FileVersion "${VER}"
VIAddVersionKey ProductVersion "${VER}"
VIAddVersionKey InternalName "${PORTABLEAPPNAME}"
VIAddVersionKey LegalTrademarks "PortableApps.com is a Trademark of Rare Ideas, LLC."
VIAddVersionKey OriginalFilename "${NAME}.exe"
;VIAddVersionKey PrivateBuild ""
;VIAddVersionKey SpecialBuild ""

;=== Runtime Switches
CRCCheck On
WindowIcon Off
SilentInstall Silent
AutoCloseWindow True
RequestExecutionLevel user

; Best Compression
SetCompress Auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize On

;=== Include
!include "GetParameters.nsh"
!include "MUI.nsh"
!include "FileFunc.nsh"
!include "ReplaceInFile.nsh"
!include "StrRep.nsh"
!insertmacro GetParent
!insertmacro GetRoot

;=== Program Icon
Icon "..\..\App\AppInfo\appicon.ico"

;=== Icon & Stye ===
!define MUI_ICON "..\..\App\AppInfo\appicon.ico"

;=== Languages
!insertmacro MUI_LANGUAGE "English"

LangString LauncherFileNotFound ${LANG_ENGLISH} "${PORTABLEAPPNAME} cannot be started. You may wish to re-install to fix this issue. (ERROR: $MISSINGFILEORPATH could not be found)"
LangString LauncherAlreadyRunning ${LANG_ENGLISH} "Another instance of ${APPNAME} is already running. Please close other instances of ${APPNAME} before launching ${PORTABLEAPPNAME}."
LangString LauncherAskCopyLocal ${LANG_ENGLISH} "${PORTABLEAPPNAME} appears to be running from a location that is read-only. Would you like to temporarily copy it to the local hard drive and run it from there?$\n$\nPrivacy Note: If you say Yes, your personal data within ${PORTABLEAPPNAME} will be temporarily copied to a local drive. Although this copy of your data will be deleted when you close ${PORTABLEAPPNAME}, it may be possible for someone else to access your data later."
LangString LauncherNoReadOnly ${LANG_ENGLISH} "${PORTABLEAPPNAME} can not run directly from a read-only location and will now close."

Var PROGRAMDIRECTORY
Var SETTINGSDIRECTORY
Var SCRIPTSDIRECTORY
Var PORTABLEAPPSDIRECTORY
Var ADDITIONALPARAMETERS
Var EXECSTRING
Var PROGRAMEXECUTABLE
Var INIPATH
Var DISABLESPLASHSCREEN
Var ISDEFAULTDIRECTORY
Var SECONDARYLAUNCH
Var MISSINGFILEORPATH


Section "Main"
	;=== Check if already running
	System::Call 'kernel32::CreateMutexA(i 0, i 0, t "${NAME}2") i .r1 ?e'
	Pop $0
	StrCmp $0 0 CheckForINI
		StrCpy $SECONDARYLAUNCH "true"

	CheckForINI:
	;=== Find the INI file, if there is one
		IfFileExists "$EXEDIR\${NAME}.ini" "" NoINI
			StrCpy "$INIPATH" "$EXEDIR"

			;=== Read the parameters from the INI file
			ReadINIStr $0 "$INIPATH\${NAME}.ini" "${NAME}" "${APPNAME}Directory"
			StrCpy "$PROGRAMDIRECTORY" "$EXEDIR\$0"
			ReadINIStr $0 "$INIPATH\${NAME}.ini" "${NAME}" "${APPNAME}Executable"
			StrCpy "$PROGRAMEXECUTABLE" $0
			ReadINIStr $0 "$INIPATH\${NAME}.ini" "${NAME}" "SettingsDirectory"
			StrCpy "$SETTINGSDIRECTORY" "$EXEDIR\$0"

			;=== Check that the above required parameters are present
			IfErrors NoINI

			ReadINIStr $0 "$INIPATH\${NAME}.ini" "${NAME}" "AdditionalParameters"
			StrCpy "$ADDITIONALPARAMETERS" $0
			ReadINIStr $0 "$INIPATH\${NAME}.ini" "${NAME}" "DisableSplashScreen"
			StrCpy "$DISABLESPLASHSCREEN" $0
			StrCpy $SCRIPTSDIRECTORY "$EXEDIR\Data\Scripts"

			;=== Any missing unrequired INI entries will be an empty string, ignore associated errors
			ClearErrors

			;=== Correct PROGRAMEXECUTABLE if blank
			StrCmp $PROGRAMEXECUTABLE "" "" CheckForProgramINI
				StrCpy "$PROGRAMEXECUTABLE" "${DEFAULTEXE}"
			
	CheckForProgramINI:
		IfFileExists "$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE" "" NoProgramEXE
			StrCpy $EXECSTRING "$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE"
			Goto CheckForSettings

	NoINI:
		;=== No INI file, so we'll use the defaults
		StrCpy "$ADDITIONALPARAMETERS" ""
		StrCpy "$DISABLESPLASHSCREEN" "false"
		StrCpy "$SETTINGSDIRECTORY" "$EXEDIR\Data\${DEFAULTSETTINGSPATH}"
		StrCpy "$SCRIPTSDIRECTORY" "$EXEDIR\Data\Scripts"
		StrCpy "$ISDEFAULTDIRECTORY" "true"
		Goto CheckForSettings

	NoProgramEXE:
		;=== Program executable not where expected
		StrCpy $MISSINGFILEORPATH $PROGRAMEXECUTABLE
		MessageBox MB_OK|MB_ICONEXCLAMATION `$(LauncherFileNotFound)`
		Abort
		
	CheckForSettings:
		IfFileExists "$SETTINGSDIRECTORY\${NAME}Settings.ini" CheckEXECSTRING
		;=== No settings found
		StrCmp $ISDEFAULTDIRECTORY "true" CopyDefaultSettings
		CreateDirectory $SETTINGSDIRECTORY
		CreateDirectory $SCRIPTSDIRECTORY
	
	CopyDefaultSettings:
		CreateDirectory "$EXEDIR\Data"
		CreateDirectory "$EXEDIR\Data\Settings"
		CreateDirectory "$EXEDIR\Data\Scripts"
		CopyFiles /SILENT $EXEDIR\App\DefaultData\Settings\*.* $EXEDIR\Data\Settings

	CheckEXECSTRING:
		;=== If $EXECSTRING is not null an alternate shell was passed in and shell checking is skipped.
		StrCmp $EXECSTRING "" CheckShells DisplaySplash
		
	CheckShells:
		;=== Check for Console Portable
		${GetParent} "$EXEDIR" $PORTABLEAPPSDIRECTORY 
		IFFileExists "$PORTABLEAPPSDIRECTORY\ConsolePortable\ConsolePortable.exe" "" UseCOMSPEC
			StrCpy $EXECSTRING `"$PORTABLEAPPSDIRECTORY\ConsolePortable\ConsolePortable.exe"`
			IfFileExists "$SETTINGSDIRECTORY\autorun.bat" "" DisplaySplash
				StrCpy $EXECSTRING `$EXECSTRING -r "/k $SETTINGSDIRECTORY\autorun.bat"`
				Goto DisplaySplash
			
	UseCOMSPEC:
		ReadEnvStr $0 COMSPEC
		IfFileExists "$0" "" NoCOMSPEC
			StrCpy $EXECSTRING `"$0" /d`
			IfFileExists "$SETTINGSDIRECTORY\autorun.bat" "" DisplaySplash
				StrCpy $EXECSTRING `$EXECSTRING /k $SETTINGSDIRECTORY\autorun.bat`
				Goto DisplaySplash

	NoCOMSPEC:
		;=== Program executable not where expected
		StrCpy $MISSINGFILEORPATH "command.com/cmd.exe"
		MessageBox MB_OK|MB_ICONEXCLAMATION `$(LauncherFileNotFound)`
		Abort

	DisplaySplash:
		StrCmp $DISABLESPLASHSCREEN "true" CheckSettings
			;=== Show the splash screen before processing the files
			InitPluginsDir
			File /oname=$PLUGINSDIR\splash.jpg "${NAME}.jpg"	
			newadvsplash::show /NOUNLOAD 1200 0 0 -1 /L $PLUGINSDIR\splash.jpg

	CheckSettings:
		;=== Update settings files for new location
		${GetRoot} $SETTINGSDIRECTORY $0
		ReadINIStr $1 "$SETTINGSDIRECTORY\${NAME}Settings.ini" "${NAME}Settings" "LastDriveLetter"
		StrCmp $1 "" StoreCurrentSettings
		StrCmp $1 $0 SetEnv
		IfFileExists "$SETTINGSDIRECTORY\autorun.bat" "" StoreCurrentSettings
			${ReplaceInFile} "$SETTINGSDIRECTORY\autorun.bat" "$1\" "$0\"
			Delete "$SETTINGSDIRECTORY\autorun.bat.old"
		
	StoreCurrentSettings:
		WriteINIStr "$SETTINGSDIRECTORY\${NAME}Settings.ini" "${NAME}Settings" "LastDriveLetter" "$0"
			
	SetEnv:
		ReadEnvStr $0 PATH
		ReadEnvStr $1 LIB
		ReadEnvStr $2 INCLUDE
		System::Call "Kernel32::SetEnvironmentVariableA(t, t) i('PATH', '$EXEDIR\App\${DEFAULTAPPDIR}\c\bin;$EXEDIR\App\${DEFAULTAPPDIR}\Perl\bin;$0').r0"
		System::Call "Kernel32::SetEnvironmentVariableA(t, t) i('LIB', '$EXEDIR\App\${DEFAULTAPPDIR}\c\lib;$EXEDIR\App\${DEFAULTAPPDIR}\Perl\bin;$1').r0"
		System::Call "Kernel32::SetEnvironmentVariableA(t, t) i('INCLUDE', '$EXEDIR\App\${DEFAULTAPPDIR}\c\include;$EXEDIR\App\${DEFAULTAPPDIR}\Perl\lib\CORE;$2').r0"
		System::Call "Kernel32::SetEnvironmentVariableA(t, t) i('PERLDEVROOT', '$EXEDIR\App\${DEFAULTAPPDIR}').r0"

		;=== Get any passed parameters
		Call GetParameters
		Pop $0
		StrCmp "'$0'" "''" "" LaunchProgramParameters
			;=== No parameters
			Goto AdditionalParameters

	LaunchProgramParameters:
		StrCpy $EXECSTRING `$EXECSTRING $0`

	AdditionalParameters:
		StrCmp $ADDITIONALPARAMETERS "" LaunchNow

		;=== Additional Parameters
		StrCpy $EXECSTRING `$EXECSTRING $ADDITIONALPARAMETERS`
	
	LaunchNow:
		SetOutPath "$SCRIPTSDIRECTORY"
		Exec $EXECSTRING
		newadvsplash::stop /WAIT
SectionEnd
