;PortableApps.com Installer Copyright 2004-2007 John T. Haller
;Perl Portable additions Copyright 2007 Shawn Faucher

;Website: http://PerlPortable.Sourceforge.net

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

;EXCEPTION: Can be used with non-GPLed open source apps distributed by PortableApps.com

;=== BEGIN: BASIC INFORMATION
!define NAME "Perl Portable"
!define SHORTNAME "PerlPortable"
!define APP "Perl"
!define VERSION "5.10.0.1"
!define FILENAME "Perl_Portable_5.10.0.1_Development_Test_1_en_us"
!define CHECKRUNNING "notapplicable"
!define CLOSENAME "Perl Portable"
!define ADDONSDIRECTORYPRESERVE "NONE"
!define PORTABLEAPPSINSTALLERVERSION "0.9.9.1"
!define INSTALLERCOMMENTS "For additional details, visit PortableApps.com"
;!define INSTALLERADDITIONALTRADEMARKS ". " ;end this entry with a period and a space if used
!define INSTALLERLEGALCOPYRIGHT "PortableApps.com and contributors"
;!define LICENSEAGREEMENT "eula.rtf"
; NOTE: For no license agreement, comment out the above line by placing a semicolon at the start of it
!define MAINSECTIONTITLE "Perl Portable (CommonFiles) [Required]"
!define OPTIONALSECTIONTITLE "Development Tools"
!define OPTIONALSECTIONDESCRIPTION "Development tools for compiling Perl Modules"
;=== END: BASIC INFORMATION

;=== Program Details
Name "${NAME}"
OutFile "..\..\..\${FILENAME}.paf.exe"
InstallDir "\${SHORTNAME}"
Caption "${NAME} | PortableApps.com Installer"
VIProductVersion "${VERSION}"
VIAddVersionKey ProductName "${NAME}"
VIAddVersionKey Comments "${INSTALLERCOMMENTS}"
VIAddVersionKey CompanyName "PortableApps.com"
VIAddVersionKey LegalCopyright "${INSTALLERLEGALCOPYRIGHT}"
VIAddVersionKey FileDescription "${NAME}"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey InternalName "${NAME}"
VIAddVersionKey LegalTrademarks "${INSTALLERADDITIONALTRADEMARKS}PortableApps.com is a Trademark of Rare Ideas, LLC."
VIAddVersionKey OriginalFilename "${FILENAME}.paf.exe"
VIAddVersionKey PortableApps.comInstallerVersion "${PORTABLEAPPSINSTALLERVERSION}"
;VIAddVersionKey PrivateBuild ""
;VIAddVersionKey SpecialBuild ""

;=== Runtime Switches
SetCompress Auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize On
CRCCheck on
AutoCloseWindow True
RequestExecutionLevel user

;=== Include
!include MUI.nsh
!include FileFunc.nsh
!include LogicLib.nsh
!insertmacro DriveSpace
!insertmacro GetOptions
!insertmacro GetDrives
!insertmacro GetRoot
!insertmacro GetSize
!insertmacro GetParent

;=== Program Icon
Icon "..\..\App\AppInfo\appicon.ico"

;=== Icon & Stye ===
!define MUI_ICON "..\..\App\AppInfo\appicon.ico"
BrandingText "PortableApps.com - Your Digital Life, Anywhere�"

;=== Pages
!define MUI_WELCOMEFINISHPAGE_BITMAP "PortableApps.comInstaller.bmp"
!define MUI_WELCOMEPAGE_TITLE "${NAME}"
!define MUI_WELCOMEPAGE_TEXT "$(welcome)"
!define MUI_COMPONENTSPAGE_SMALLDESC
!insertmacro MUI_PAGE_WELCOME
!ifdef LICENSEAGREEMENT
    !define MUI_LICENSEPAGE_CHECKBOX
    !insertmacro MUI_PAGE_LICENSE "${LICENSEAGREEMENT}"
!endif
!insertmacro MUI_PAGE_COMPONENTS
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE LeaveDirectory
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_TEXT "$(finish)"
!insertmacro MUI_PAGE_FINISH

;=== Languages
!insertmacro MUI_LANGUAGE "English"

LangString welcome ${LANG_ENGLISH} "This wizard will guide you through the installation of ${NAME}.\r\n\r\nIf you are upgrading an existing installation of ${NAME}, please close it before proceeding.\r\n\r\nClick Next to continue."
LangString finish ${LANG_ENGLISH} "${NAME} has been installed on your device.\r\n\r\nClick Finish to close this wizard."
LangString runwarning ${LANG_ENGLISH} "Please close all instances of ${CLOSENAME} and then click OK.  The portable app can not be upgraded while it is running."
LangString invaliddirectory ${LANG_ENGLISH} "The destination folder you selected is invalid.  Please choose a valid folder."
LangString notenoughspace ${LANG_ENGLISH} "The device you have selected to install to does not have enough free space for this app."
LangString checkforplatform ${LANG_ENGLISH} "Checking for PortableApps.com Platform"
LangString refreshmenu ${LANG_ENGLISH} "Refreshing PortableApps.com Menu"

;=== Variables
Var FOUNDPORTABLEAPPSPATH
Var OPTIONAL1DONE

Function .onInit
	${GetOptions} "$CMDLINE" "/DESTINATION=" $R0

	IfErrors CheckLegacyDestination
		StrCpy $INSTDIR "$R0CommonFiles"
		Goto InitDone

	CheckLegacyDestination:
		ClearErrors
		${GetOptions} "$CMDLINE" "-o" $R0
		IfErrors NoDestination
			StrCpy $INSTDIR "$R0CommonFiles"
			Goto InitDone

	NoDestination:
		ClearErrors
		${GetDrives} "HDD+FDD" GetDrivesCallBack
		StrCmp $FOUNDPORTABLEAPPSPATH "" DefaultDestination
			StrCpy $INSTDIR "$FOUNDPORTABLEAPPSPATH\CommonFiles"
			Goto InitDone
		
	DefaultDestination:
		StrCpy $INSTDIR "\CommonFiles"

	InitDone:
FunctionEnd

Function LeaveDirectory
	GetInstDirError $0
  
	;=== Does it already exist? (upgrade)
	IfFileExists "$INSTDIR" "" CheckInstallerError
		;=== Check if app is running?
		StrCmp ${CHECKRUNNING} "NONE" CheckInstallerError
			FindProcDLL::FindProc "${CHECKRUNNING}"
			StrCmp $R0 "1" "" CheckInstallerError
				MessageBox MB_OK|MB_ICONINFORMATION `$(runwarning)`
				Abort
  
  
	CheckInstallerError:
		${Switch} $0
		    ${Case} 0 ;=== Valid directory and enough free space
				${Break}
		    ${Case} 1
				MessageBox MB_OK `$(invaliddirectory)`
				Abort
				${Break}
		    ${Case} 2
				IfFileExists `$INSTDIR` "" NotEnoughSpaceNoUpgrade ;=== Is upgrade
					SectionGetSize ${SecApp} $1 ;=== Space Required for App
					StrCmp $OPTIONAL1DONE "true" NoOptions
					SectionGetSize ${SecOptional1} $2 ;=== Space Required for App
					IntOp $1 $1 + $2
				NoOptions:
					${GetRoot} `$INSTDIR` $2
					${DriveSpace} `$2\` "/D=F /S=K" $3 ;=== Space Free on Device
					${GetSize} `$INSTDIR` "/M=*.* /S=0K /G=1" $4 $5 $6 ;=== Current installation size
					IntOp $7 $3 + $4 ;=== Space Free + Current Install Size
					IfFileExists `$INSTDIR\Data` "" CheckPluginsDirectory
						${GetSize} `$INSTDIR\Data` "/M=*.* /S=0K /G=1" $4 $5 $6 ;=== Size of Data directory
						IntOp $7 $7 - $4 ;=== Remove the data directory from the free space calculation
				CheckPluginsDirectory:
					StrCmp `${ADDONSDIRECTORYPRESERVE}` "NONE" CalculateSpaceLeft
						IfFileExists `$INSTDIR\${ADDONSDIRECTORYPRESERVE}` "" CalculateSpaceLeft
							${GetSize} `$INSTDIR\${ADDONSDIRECTORYPRESERVE}` "/M=*.* /S=0K /G=1" $4 $5 $6 ;=== Size of Data directory
							IntOp $7 $7 - $4 ;=== Remove the plugins directory from the free space calculation
				CalculateSpaceLeft:
					IntCmp $7 $1 NotEnoughSpaceNoUpgrade NotEnoughSpaceNoUpgrade
					Goto EndNotEnoughSpace
				NotEnoughSpaceNoUpgrade:
					MessageBox MB_OK `$(notenoughspace)`
					Abort
				EndNotEnoughSpace:
				${Break}
		${EndSwitch}
FunctionEnd

Function GetDrivesCallBack
	;=== Skip usual floppy letters
	StrCmp $8 "FDD" "" CheckForPortableAppsPath
	StrCmp $9 "A:\" End
	StrCmp $9 "B:\" End
	
	CheckForPortableAppsPath:
		IfFileExists "$9PortableApps" "" End
			StrCpy $FOUNDPORTABLEAPPSPATH "$9PortableApps"

	End:
		Push $0
FunctionEnd

Section "${MAINSECTIONTITLE}"
	SectionIn RO
	SetOutPath "$INSTDIR"
	
	;=== BEGIN: PRE-INSTALL CODE
	;=== END: PRE-INSTALL CODE

	CreateDirectory "$INSTDIR"
	SetOutPath $INSTDIR\Perl
	File /r "..\..\..\CommonFiles\Perl\*.*"
	
	;=== BEGIN: POST-INSTALL CODE
	;=== END: POST-INSTALL CODE
	
	;=== Refresh PortableApps.com Menu (not final version)
	${GetParent} `$INSTDIR` $0
	;=== Check that it exists at the right location
	DetailPrint '$(checkforplatform)'
	IfFileExists `$0\PortableApps.com\App\PortableAppsPlatform.exe` "" TheEnd
		;=== Check that it's the real deal so we aren't hanging with no response
		MoreInfo::GetProductName `$0\PortableApps.com\App\PortableAppsPlatform.exe`
		Pop $1
		StrCmp $1 "PortableApps.com Platform" "" TheEnd
		MoreInfo::GetCompanyName `$0\PortableApps.com\App\PortableAppsPlatform.exe`
		Pop $1
		StrCmp $1 "PortableApps.com" "" TheEnd
		
		;=== Check that it's running
		FindProcDLL::FindProc "PortableAppsPlatform.exe"
		StrCmp $R0 "1" "" TheEnd
		
		;=== Send message for the Menu to refresh
		StrCpy $2 'PortableApps.comPlatformWindowMessageToRefresh$0\PortableApps.com\App\PortableAppsPlatform.exe'
		System::Call "user32::RegisterWindowMessage(t r2) i .r3"
		DetailPrint '$(refreshmenu)'
		SendMessage 65535 $3 0 0
	TheEnd:
SectionEnd

Section /o "${OPTIONALSECTIONTITLE}" SecOptional1
	${GetParent} `$INSTDIR` $0
	SetOutPath $0\${SHORTNAME}
	File "..\..\*.*"
	SetOutPath $0\${SHORTNAME}\App
	File /r "..\..\App\*.*"
	SetOutPath $0\${SHORTNAME}\Other
	File /r "..\..\Other\*.*"
	CreateDirectory "$0\${SHORTNAME}\Data"
	StrCpy $OPTIONAL1DONE "true"
SectionEnd

Section "-Cleanup" SecCleanup
	StrCmp $OPTIONAL1DONE "true" TheEnd
	DetailPrint "Cleaning up old files"
	;=== BEGIN: OPTIONAL NOT SELECTED POST-INSTALL CODE
	;=== END: OPTIONAL NOT SELECTED POST-INSTALL CODE
	TheEnd:
SectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${SecOptional1} "${OPTIONALSECTIONDESCRIPTION}"
!insertmacro MUI_FUNCTION_DESCRIPTION_END
