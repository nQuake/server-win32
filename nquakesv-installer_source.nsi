;nQuakesv NSIS Online Installer Script
;By Empezar 2013-08-03; Last modified 2014-03-16

!define VERSION "1.6"
!define SHORTVERSION "16"

Name "nQuakesv"
OutFile "nquakesv${SHORTVERSION}_installer.exe"
InstallDir "C:\nQuakesv"

!define INSTALLER_URL "http://nquake.com" # Note: no trailing slash!
!define DISTFILES_PATH "$LOCALAPPDATA\nQuakesv\" # Note: no trailing slash!

# Editing anything below this line is not recommended
;---------------------------------------------------

InstallDirRegKey HKCU "Software\nQuakesv" "Install_Dir"
InstallDirRegKey HKCU "Software\nQuakesv" "Setup_Dir"

;----------------------------------------------------
;Header Files

!include "MUI.nsh"
!include "FileFunc.nsh"
!insertmacro GetSize
!insertmacro GetTime
!include "StrStrip.nsh"
!include "LogicLib.nsh"
!include "Time.nsh"
!include "Locate.nsh"
!include "VersionCompare.nsh"
!include "VersionConvert.nsh"
!include "WinMessages.nsh"
!include "MultiUser.nsh"
!include "nquakesv-macros.nsh"

;----------------------------------------------------
;Variables

Var ADDONS_CA
Var ADDONS_CA_HOSTNAME
Var ADDONS_FFA
Var ADDONS_FFA_HOSTNAME
Var ADDONS_FORTRESS
Var ADDONS_FORTRESS_HOSTNAME
Var ADDONS_QTV
Var ADDONS_QTV_HOSTNAME
Var ADDONS_QTV_PASSWORD
Var ADDONS_QWFWD
Var ADDONS_QWFWD_HOSTNAME
Var CONFIG_ADMIN
Var CONFIG_DNS
Var CONFIG_EMAIL
Var CONFIG_HOSTNAME
Var CONFIG_PORTS
Var CONFIG_RCON
Var DISTFILES_DELETE
Var DISTFILES_PATH
Var DISTFILES_REDOWNLOAD
Var DISTFILES_UPDATE
Var DISTFILES_URL
Var DISTFILES
Var DISTLOG
Var DISTLOGTMP
Var PASSWORDCONFIG
Var PORTCONFIG
Var QTVCONFIG
Var QWFWDCONFIG
Var ERRLOG
Var ERRLOGTMP
Var ERRORS
Var INSTALLED
Var INSTLOG
Var INSTLOGTMP
Var INSTSIZE
Var NQUAKE_INI
Var OFFLINE
Var PAK_LOCATION
Var REMOVE_ALL_FILES
Var REMOVE_MODIFIED_FILES
Var REMOVE_SETUP_FILES
Var RETRIES
Var SIZE
Var STARTALLSERVERS
Var STARTMENU_FOLDER
Var i

;----------------------------------------------------
;Interface Settings

!define MUI_ICON "nquakesv.ico"
!define MUI_UNICON "nquakesv.ico"

!define MUI_WELCOMEFINISHPAGE_BITMAP "nquakesv-welcomefinish.bmp"

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "nquakesv-header.bmp"

!define MULTIUSER_EXECUTIONLEVEL Highest

;----------------------------------------------------
;Installer Pages

!define MUI_PAGE_CUSTOMFUNCTION_PRE "WelcomeShow"
!define MUI_WELCOMEPAGE_TITLE "nQuakesv Installation Wizard"
!insertmacro MUI_PAGE_WELCOME

LicenseForceSelection checkbox "I agree to these terms and conditions"
!insertmacro MUI_PAGE_LICENSE "license.txt"

Page custom FULLVERSION

Page custom DOWNLOAD

Page custom CONFIG

Page custom ADDONS

DirText "Setup will install nQuakesv in the following folder. To install in a different folder, click Browse and select another folder. Click Next to continue." "Destination Folder" "Browse" "Select the folder to install nQuakesv in:"
!define MUI_PAGE_CUSTOMFUNCTION_SHOW DirectoryPageShow
!insertmacro MUI_PAGE_DIRECTORY

!insertmacro MUI_PAGE_STARTMENU "Application" $STARTMENU_FOLDER

ShowInstDetails "nevershow"
!insertmacro MUI_PAGE_INSTFILES

Page custom ERRORS

!define MUI_PAGE_CUSTOMFUNCTION_SHOW "FinishShow"
!define MUI_FINISHPAGE_LINK "Click here to visit the QuakeWorld portal"
!define MUI_FINISHPAGE_LINK_LOCATION "http://www.quakeworld.nu/"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR/readme.txt"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Open readme"
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
!insertmacro MUI_PAGE_FINISH

;----------------------------------------------------
;Uninstaller Pages

UninstPage custom un.UNINSTALL

!insertmacro MUI_UNPAGE_INSTFILES

;----------------------------------------------------
;Languages

!insertmacro MUI_LANGUAGE "English"

;----------------------------------------------------
;NSIS Manipulation

LangString ^Branding ${LANG_ENGLISH} "nQuakesv Installer v${VERSION}"
LangString ^SetupCaption ${LANG_ENGLISH} "nQuakesv Installer"
LangString ^SpaceRequired ${LANG_ENGLISH} "Download size: "

;----------------------------------------------------
;Reserve Files

ReserveFile "fullversion.ini"
ReserveFile "config.ini"
ReserveFile "addons.ini"
ReserveFile "download.ini"
ReserveFile "errors.ini"
ReserveFile "uninstall.ini"

!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

;----------------------------------------------------
;Installer Sections

Section "" # Prepare installation

  SetOutPath $INSTDIR

  # Set progress bar
  RealProgress::SetProgress /NOUNLOAD 0

  # Read information from custom pages
  !insertmacro MUI_INSTALLOPTIONS_READ $PAK_LOCATION "fullversion.ini" "Field 3" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $DISTFILES_PATH "download.ini" "Field 3" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $DISTFILES_UPDATE "download.ini" "Field 4" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $DISTFILES_REDOWNLOAD "download.ini" "Field 5" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $DISTFILES_DELETE "download.ini" "Field 6" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $CONFIG_HOSTNAME "config.ini" "Field 15" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $CONFIG_DNS "config.ini" "Field 18" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $CONFIG_PORTS "config.ini" "Field 12" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $CONFIG_ADMIN "config.ini" "Field 4" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $CONFIG_EMAIL "config.ini" "Field 6" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $CONFIG_RCON "config.ini" "Field 9" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $ADDONS_QTV "addons.ini" "Field 3" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $ADDONS_QTV_HOSTNAME "addons.ini" "Field 5" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $ADDONS_QTV_PASSWORD "addons.ini" "Field 7" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $ADDONS_QWFWD "addons.ini" "Field 9" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $ADDONS_QWFWD_HOSTNAME "addons.ini" "Field 11" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $ADDONS_FFA "addons.ini" "Field 16" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $ADDONS_FFA_HOSTNAME "addons.ini" "Field 18" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $ADDONS_CA "addons.ini" "Field 19" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $ADDONS_CA_HOSTNAME "addons.ini" "Field 21" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $ADDONS_FORTRESS "addons.ini" "Field 13" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $ADDONS_FORTRESS_HOSTNAME "addons.ini" "Field 15" "State"

  # Create distfiles folder if it doesn't already exist
  ${Unless} ${FileExists} "$DISTFILES_PATH\*.*"
    CreateDirectory $DISTFILES_PATH
  ${EndUnless}

  # Calculate the installation size
  ${Unless} ${FileExists} "$INSTDIR\ID1\PAK0.PAK"
    ${If} ${FileExists} "$PAK_LOCATION"
      ${GetSize} $R0 "/M=pak0.pak /S=0B /G=0" $7 $8 $9
      ${If} $7 != "18689235"
        ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "qsw106.zip"
        IntOp $INSTSIZE $INSTSIZE + $0
      ${EndIf}
    ${EndIf}
  ${EndUnless}
  ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-bin-win32.zip"
  IntOp $INSTSIZE $INSTSIZE + $0
  ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-win32.zip"
  IntOp $INSTSIZE $INSTSIZE + $0
  ${If} $ADDONS_CA == 1
    ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-ca.zip"
    IntOp $INSTSIZE $INSTSIZE + $0
  ${EndIf}
  ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-configs.zip"
  IntOp $INSTSIZE $INSTSIZE + $0
  ${If} $ADDONS_FFA == 1
    ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-ffa.zip"
    IntOp $INSTSIZE $INSTSIZE + $0
  ${EndIf}
  ${If} $ADDONS_FORTRESS == 1
    ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-fortress.zip"
    IntOp $INSTSIZE $INSTSIZE + $0
  ${EndIf}
  ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-gpl.zip"
  IntOp $INSTSIZE $INSTSIZE + $0
  ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-maps.zip"
  IntOp $INSTSIZE $INSTSIZE + $0
  ${Unless} ${FileExists} "$INSTDIR\id1\pak1.pak"
  ${OrUnless} ${FileExists} "$EXEDIR\pak1.pak"
    ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-maps-gpl.zip"
  ${EndUnless}
  IntOp $INSTSIZE $INSTSIZE + $0
  ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-non-gpl.zip"
  IntOp $INSTSIZE $INSTSIZE + $0

  # Find out what mirror was selected
  !insertmacro MUI_INSTALLOPTIONS_READ $R0 "download.ini" "Field 8" "State"
  ${If} $R0 == "Randomly selected mirror (Recommended)"
    # Get amount of mirrors ($0 = amount of mirrors)
    StrCpy $0 1
    ReadINIStr $1 $NQUAKE_INI "mirror_descriptions" $0
    ${DoUntil} $1 == ""
      ReadINIStr $1 $NQUAKE_INI "mirror_descriptions" $0
      IntOp $0 $0 + 1
    ${LoopUntil} $1 == ""
    IntOp $0 $0 - 2
  
    # Get time (seconds)
    ${time::GetLocalTime} $1
    StrCpy $1 $1 "" -2
    
    # Fix seconds (00 -> 1, 01-09 -> 1-9)
    ${If} $1 == "00"
      StrCpy $1 1
    ${Else}
      StrCpy $2 $1 1 -2
      ${If} $2 == 0
        StrCpy $1 $1 1 -1
      ${EndIf}
    ${EndIf}
  
    # Loop until you get a number that's within the range 0 < x =< $0
    ${DoUntil} $1 <= $0
      IntOp $1 $1 - $0
    ${LoopUntil} $1 <= $0
    ReadINIStr $DISTFILES_URL $NQUAKE_INI "mirror_addresses" $1
    ReadINIStr $0 $NQUAKE_INI "mirror_descriptions" $1
  ${Else}
    ${For} $0 1 1000
      ReadINIStr $R1 $NQUAKE_INI "mirror_descriptions" $0
      ${If} $R0 == $R1
        ReadINIStr $DISTFILES_URL $NQUAKE_INI "mirror_addresses" $0
        ReadINIStr $0 $NQUAKE_INI "mirror_descriptions" $0
        ${ExitFor}
      ${EndIf}
    ${Next}
  ${EndIf}

  # Open temporary files
  GetTempFileName $INSTLOGTMP
  GetTempFileName $DISTLOGTMP
  GetTempFileName $ERRLOGTMP
  FileOpen $INSTLOG $INSTLOGTMP w
  FileOpen $DISTLOG $DISTLOGTMP w
  FileOpen $ERRLOG $ERRLOGTMP a

SectionEnd

Section "nQuakesv" NQUAKESV

  # Download and install pak0.pak (shareware data) unless pak0.pak can be found alongside the installer executable
  ${If} ${FileExists} "$INSTDIR\id1\pak0.pak"
    StrCpy $R0 "$INSTDIR"
  ${ElseIf} ${FileExists} "$EXEDIR\pak0.pak"
    StrCpy $R0 "$EXEDIR"
  ${ElseIf} ${FileExists} "$DISTFILES_PATH\pak0.pak"
    StrCpy $R0 "$DISTFILES_PATH"
  ${EndIf}
  ${GetSize} $R0 "/M=pak0.pak /S=0B /G=0" $7 $8 $9
  ${If} $7 == "18689235"
    CreateDirectory "$INSTDIR\id1"
    ${Unless} ${FileExists} "$INSTDIR\id1\pak0.pak"
      CopyFiles /SILENT "$R0\pak0.pak" "$INSTDIR\id1\pak0.pak"
    ${EndUnless}
    # Keep pak0.pak and remove qsw106.zip in distfile folder if DISTFILES_DELETE is 0
    ${If} $DISTFILES_DELETE == 0
      ${Unless} ${FileExists} "$DISTFILES_PATH\pak0.pak"
        CopyFiles /SILENT "$R0\pak0.pak" "$DISTFILES_PATH\pak0.pak"
      ${EndUnless}
      Delete "$DISTFILES_PATH\qsw106.zip"
    ${EndIf}
    FileWrite $INSTLOG "id1\pak0.pak$\r$\n"
    Goto SkipShareware
  ${EndIf}
  !insertmacro InstallSection qsw106.zip "Quake shareware"
  # Remove crap files extracted from shareware zip
  Delete "$INSTDIR\CWSDPMI.EXE"
  Delete "$INSTDIR\QLAUNCH.EXE"
  Delete "$INSTDIR\QUAKE.EXE"
  Delete "$INSTDIR\GENVXD.DLL"
  Delete "$INSTDIR\QUAKEUDP.DLL"
  Delete "$INSTDIR\PDIPX.COM"
  Delete "$INSTDIR\Q95.BAT"
  Delete "$INSTDIR\COMEXP.TXT"
  Delete "$INSTDIR\HELP.TXT"
  Delete "$INSTDIR\LICINFO.TXT"
  Delete "$INSTDIR\MANUAL.TXT"
  Delete "$INSTDIR\ORDER.TXT"
  Delete "$INSTDIR\README.TXT"
  Delete "$INSTDIR\READV106.TXT"
  Delete "$INSTDIR\SLICNSE.TXT"
  Delete "$INSTDIR\TECHINFO.TXT"
  Delete "$INSTDIR\MGENVXD.VXD"
  Rename "$INSTDIR\ID1" "$INSTDIR\id1"
  Rename "$INSTDIR\id1\PAK0.PAK" "$INSTDIR\id1\pak0.pak"
  # Keep pak0.pak and remove qsw106.zip in distfile folder if DISTFILES_DELETE is 0
  ${If} $DISTFILES_DELETE == 0
    ${Unless} ${FileExists} "$DISTFILES_PATH\pak0.pak"
      CopyFiles /SILENT "$INSTDIR\id1\pak0.pak" "$DISTFILES_PATH\pak0.pak"
    ${EndUnless}
    Delete "$DISTFILES_PATH\qsw106.zip"
  ${EndIf}
  SkipShareware:
  # Add to installed size
  ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "qsw106.zip"
  IntOp $INSTALLED $INSTALLED + $0
  # Set progress bar
  IntOp $0 $INSTALLED * 100
  IntOp $0 $0 / $INSTSIZE
  RealProgress::SetProgress /NOUNLOAD $0

  # Download and install binaries
  !insertmacro InstallSection sv-bin-win32.zip "server binaries"
  # Add to installed size
  ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-bin-win32.zip"
  IntOp $INSTALLED $INSTALLED + $0
  # Set progress bar
  IntOp $0 $INSTALLED * 100
  IntOp $0 $0 / $INSTSIZE
  RealProgress::SetProgress /NOUNLOAD $0

  # Download and install windows specific files
  !insertmacro InstallSection sv-win32.zip "windows specific files"
  # Add to installed size
  ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-win32.zip"
  IntOp $INSTALLED $INSTALLED + $0
  # Set progress bar
  IntOp $0 $INSTALLED * 100
  IntOp $0 $0 / $INSTSIZE
  RealProgress::SetProgress /NOUNLOAD $0

  # Download and install GPL files
  !insertmacro InstallSection sv-gpl.zip "GPL setup files"
  # Add to installed size
  ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-gpl.zip"
  IntOp $INSTALLED $INSTALLED + $0
  # Set progress bar
  IntOp $0 $INSTALLED * 100
  IntOp $0 $0 / $INSTSIZE
  RealProgress::SetProgress /NOUNLOAD $0
  # Move the qtv/qtv/ folder to qtv/ directory
  Rename "$INSTDIR\qtv\qtv\levelshots" "$INSTDIR\qtv\levelshots"
  Rename "$INSTDIR\qtv\qtv\listip.cfg" "$INSTDIR\qtv\listip.cfg"
  Rename "$INSTDIR\qtv\qtv\qtvbg01.png" "$INSTDIR\qtv\qtvbg01.png"
  Rename "$INSTDIR\qtv\qtv\save.png" "$INSTDIR\qtv\listip.png"
  Rename "$INSTDIR\qtv\qtv\stream.png" "$INSTDIR\qtv\stream.png"
  Rename "$INSTDIR\qtv\qtv\style.css" "$INSTDIR\qtv\style.css"
  # Add all files within levelshots directory
  ${locate::Open} "$INSTDIR\qtv\levelshots" "/F=1" $R0
  StrCpy $1 1
  ${DoUntil} $1 == ""
    ${locate::Find} $R0 $0 $1 $2 $3 $4
    ${If} $1 != ""
      ${StrStrip} "$INSTDIR\" "$0\$1" $R1
      FileWrite $INSTLOG "$R1$\r$\n"
    ${EndIf}
  ${LoopUntil} $1 == ""
  FileWrite $INSTLOG "qtv\listip.cfg$\r$\n"
  FileWrite $INSTLOG "qtv\qtvbg01.png$\r$\n"
  FileWrite $INSTLOG "qtv\listip.png$\r$\n"
  FileWrite $INSTLOG "qtv\stream.png$\r$\n"
  FileWrite $INSTLOG "qtv\style.css$\r$\n"
  RMDir /r /REBOOTOK "$INSTDIR\qtv\qtv"
  # Remove stuff that's not needed in Windows
  Delete "$INSTDIR\ktx\portx.cfg"
  Delete "$INSTDIR\run\portx.sh"
  Delete "$INSTDIR\run\qtv.sh"
  Delete "$INSTDIR\run\qwfwd.sh"
  RMDir /r /REBOOTOK "$INSTDIR\run"
  Delete "$INSTDIR\addons\install_ca.sh"
  Delete "$INSTDIR\addons\install_ffa.sh"
  Delete "$INSTDIR\addons\install_fortress.sh"
  RMDir /r /REBOOTOK "$INSTDIR\addons"
  Delete "$INSTDIR\start_servers.sh"
  Delete "$INSTDIR\stop_servers.sh"
  Delete "$INSTDIR\update_binaries.sh"
  Delete "$INSTDIR\update_configs.sh"
  Delete "$INSTDIR\update_maps.sh"
  Delete "$INSTDIR\README"

  # Download and install non-GPL files
  !insertmacro InstallSection sv-non-gpl.zip "non-GPL setup files"
  # Add to installed size
  ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-non-gpl.zip"
  IntOp $INSTALLED $INSTALLED + $0
  # Set progress bar
  IntOp $0 $INSTALLED * 100
  IntOp $0 $0 / $INSTSIZE
  RealProgress::SetProgress /NOUNLOAD $0

  # Download and install maps
  !insertmacro InstallSection sv-maps.zip "custom maps"
  # Add to installed size
  ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-maps.zip"
  IntOp $INSTALLED $INSTALLED + $0
  # Set progress bar
  IntOp $0 $INSTALLED * 100
  IntOp $0 $0 / $INSTSIZE
  RealProgress::SetProgress /NOUNLOAD $0

  # Copy pak1.pak if it can be found alongside the installer executable
  ${If} ${FileExists} "$PAK_LOCATION"
    ${Unless} ${FileExists} "$INSTDIR\id1\pak1.pak"
      CopyFiles /SILENT $PAK_LOCATION "$INSTDIR\id1\pak1.pak"
    ${EndUnless}
    ${If} $DISTFILES_DELETE == 0
      ${Unless} ${FileExists} "$DISTFILES_PATH\pak1.pak"
        CopyFiles /SILENT "$INSTDIR\id1\pak1.pak" "$DISTFILES_PATH\pak1.pak"
      ${EndUnless}
    ${EndIf}
    RMDir /r /REBOOTOK "$INSTDIR\id1\maps"
    RMDir /r /REBOOTOK "$INSTDIR\id1\progs"
    RMDir /r /REBOOTOK "$INSTDIR\id1\sound"
    Delete "$INSTDIR\id1\README"
    FileWrite $INSTLOG "id1\pak1.pak$\r$\n"
    Goto SkipGPLMaps
  ${ElseIf} ${FileExists} "$EXEDIR\pak1.pak"
    ${GetSize} $EXEDIR "/M=pak1.pak /S=0B /G=0" $7 $8 $9
    ${If} $7 == "34257856"
      ${Unless} ${FileExists} "$INSTDIR\id1\pak1.pak"
        CopyFiles /SILENT "$EXEDIR\pak1.pak" "$INSTDIR\id1\pak1.pak"
      ${EndUnless}
      ${If} $DISTFILES_DELETE == 0
        ${Unless} ${FileExists} "$DISTFILES_PATH\pak1.pak"
          CopyFiles /SILENT "$EXEDIR\pak1.pak" "$DISTFILES_PATH\pak1.pak"
        ${EndUnless}
      ${EndIf}
      RMDir /r /REBOOTOK "$INSTDIR\id1\maps"
      RMDir /r /REBOOTOK "$INSTDIR\id1\progs"
      RMDir /r /REBOOTOK "$INSTDIR\id1\sound"
      Delete "$INSTDIR\id1\README"
      FileWrite $INSTLOG "id1\pak1.pak$\r$\n"
      Goto SkipGPLMaps
    ${EndIf}
  ${EndIf}

  # Download and install GPL maps if pak1.pak can't be found in executable folder
  !insertmacro InstallSection sv-maps-gpl.zip "GPL id maps"
  # Add to installed size
  ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-maps-gpl.zip"
  IntOp $INSTALLED $INSTALLED + $0
  # Set progress bar
  IntOp $0 $INSTALLED * 100
  IntOp $0 $0 / $INSTSIZE
  RealProgress::SetProgress /NOUNLOAD $0
  SkipGPLMaps:

  # Download and install configs
  !insertmacro InstallSection sv-configs.zip "configuration files"
  # Add to installed size
  ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-configs.zip"
  IntOp $INSTALLED $INSTALLED + $0
  # Set progress bar
  IntOp $0 $INSTALLED * 100
  IntOp $0 $0 / $INSTSIZE
  RealProgress::SetProgress /NOUNLOAD $0

  # Download and install Free For All mod
  ${If} $ADDONS_FFA == 1
    !insertmacro InstallSection sv-ffa.zip "Free For All"
    # Copy MVDSV configuration files
    CopyFiles /SILENT "$INSTDIR\ktx\mvdsv.cfg" "$INSTDIR\ffa\mvdsv.cfg"
    CopyFiles /SILENT "$INSTDIR\ktx\pwd.cfg" "$INSTDIR\ffa\pwd.cfg"
    CopyFiles /SILENT "$INSTDIR\ktx\vip_ip.cfg" "$INSTDIR\ffa\vip_ip.cfg"
    CopyFiles /SILENT "$INSTDIR\ktx\ban_ip.cfg" "$INSTDIR\ffa\ban_ip.cfg"
    FileWrite $INSTLOG "ffa\mvdsv.cfg$\r$\n"
    FileWrite $INSTLOG "ffa\pwd.cfg$\r$\n"
    FileWrite $INSTLOG "ffa\vip_ip.cfg$\r$\n"
    FileWrite $INSTLOG "ffa\ban_ip.cfg$\r$\n"
    # Add to installed size
    ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-ffa.zip"
    IntOp $INSTALLED $INSTALLED + $0
    # Set progress bar
    IntOp $0 $INSTALLED * 100
    IntOp $0 $0 / $INSTSIZE
    RealProgress::SetProgress /NOUNLOAD $0
  ${EndIf}

  # Download and install Team Fortress
  ${If} $ADDONS_FORTRESS == 1
    !insertmacro InstallSection sv-fortress.zip "Team Fortress"
    # Copy MVDSV configuration files
    CopyFiles /SILENT "$INSTDIR\ktx\mvdsv.cfg" "$INSTDIR\fortress\mvdsv.cfg"
    CopyFiles /SILENT "$INSTDIR\ktx\pwd.cfg" "$INSTDIR\fortress\pwd.cfg"
    CopyFiles /SILENT "$INSTDIR\ktx\vip_ip.cfg" "$INSTDIR\fortress\vip_ip.cfg"
    CopyFiles /SILENT "$INSTDIR\ktx\ban_ip.cfg" "$INSTDIR\fortress\ban_ip.cfg"
    CopyFiles /SILENT "$INSTDIR\ktx\mvdsv.cfg" "$INSTDIR\thundervote\mvdsv.cfg"
    CopyFiles /SILENT "$INSTDIR\ktx\pwd.cfg" "$INSTDIR\thundervote\pwd.cfg"
    CopyFiles /SILENT "$INSTDIR\ktx\vip_ip.cfg" "$INSTDIR\thundervote\vip_ip.cfg"
    CopyFiles /SILENT "$INSTDIR\ktx\ban_ip.cfg" "$INSTDIR\thundervote\ban_ip.cfg"
    FileWrite $INSTLOG "fortress\mvdsv.cfg$\r$\n"
    FileWrite $INSTLOG "fortress\pwd.cfg$\r$\n"
    FileWrite $INSTLOG "fortress\vip_ip.cfg$\r$\n"
    FileWrite $INSTLOG "fortress\ban_ip.cfg$\r$\n"
    FileWrite $INSTLOG "thundervote\mvdsv.cfg$\r$\n"
    FileWrite $INSTLOG "thundervote\pwd.cfg$\r$\n"
    FileWrite $INSTLOG "thundervote\vip_ip.cfg$\r$\n"
    FileWrite $INSTLOG "thundervote\ban_ip.cfg$\r$\n"
    # Add to installed size
    ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-fortress.zip"
    IntOp $INSTALLED $INSTALLED + $0
    # Set progress bar
    IntOp $0 $INSTALLED * 100
    IntOp $0 $0 / $INSTSIZE
    RealProgress::SetProgress /NOUNLOAD $0
  ${EndIf}

  # Download and install Clan Arena
  ${If} $ADDONS_CA == 1
    !insertmacro InstallSection sv-ca.zip "Clan Arena"
    # Copy MVDSV configuration files
    CopyFiles /SILENT "$INSTDIR\ktx\mvdsv.cfg" "$INSTDIR\cace\mvdsv.cfg"
    CopyFiles /SILENT "$INSTDIR\ktx\pwd.cfg" "$INSTDIR\cace\pwd.cfg"
    CopyFiles /SILENT "$INSTDIR\ktx\vip_ip.cfg" "$INSTDIR\cace\vip_ip.cfg"
    CopyFiles /SILENT "$INSTDIR\ktx\ban_ip.cfg" "$INSTDIR\cace\ban_ip.cfg"
    FileWrite $INSTLOG "cace\mvdsv.cfg$\r$\n"
    FileWrite $INSTLOG "cace\pwd.cfg$\r$\n"
    FileWrite $INSTLOG "cace\vip_ip.cfg$\r$\n"
    FileWrite $INSTLOG "cace\ban_ip.cfg$\r$\n"
    # Add to installed size
    ReadINIStr $0 $NQUAKE_INI "distfile_sizes" "sv-ca.zip"
    IntOp $INSTALLED $INSTALLED + $0
    # Set progress bar
    IntOp $0 $INSTALLED * 100
    IntOp $0 $0 / $INSTSIZE
    RealProgress::SetProgress /NOUNLOAD $0
  ${EndIf}

  # Rename readme files
  Rename "$INSTDIR\id1\README" "$INSTDIR\id1\readme.txt"

  # Remove QTV and QWFWD if they were deselected during configuration
  ${If} $ADDONS_QTV == 0
    RMDir /r /REBOOTOK "$INSTDIR\qtv"
  ${EndIf}
  ${If} $ADDONS_QWFWD == 0
    RMDir /r /REBOOTOK "$INSTDIR\qwfwd"
  ${EndIf}

  # Create shortcuts in shortcuts folder
  CreateDirectory "$INSTDIR\shortcuts"
  # Create a batch file for starting all servers
  FileOpen $STARTALLSERVERS "$INSTDIR\shortcuts\start_all_servers.bat" w
  ${ForEach} $i 1 $CONFIG_PORTS + 1
    CreateShortCut "$INSTDIR\shortcuts\ktx 2850$i.lnk" "$INSTDIR\mvdsv.exe" "-port 2850$i -game ktx +exec port$i.cfg" "$INSTDIR\mvdsv.exe" 0
    FileWrite $STARTALLSERVERS "@start $\"$\" /min /b $\"$INSTDIR\shortcuts\ktx 2850$i.lnk$\"$\r$\n"
    FileWrite $INSTLOG "shortcuts\ktx 2850$i.lnk$\r$\n"
  ${Next}
  ${If} $ADDONS_FFA == 1
    CreateShortCut "$INSTDIR\shortcuts\ffa 27500.lnk" "$INSTDIR\mvdsv.exe" "-port 27500 -game ffa +exec port1.cfg" "$INSTDIR\mvdsv.exe" 0
    FileWrite $STARTALLSERVERS "@start $\"$\" /min /b $\"$INSTDIR\shortcuts\ffa 27500.lnk$\"$\r$\n"
    FileWrite $INSTLOG "shortcuts\ffa 27500.lnk$\r$\n"
  ${EndIf}
  ${If} $ADDONS_FORTRESS == 1
    CreateShortCut "$INSTDIR\shortcuts\fortress 27700.lnk" "$INSTDIR\mvdsv.exe" "-port 27700 -game fortress +exec port1.cfg" "$INSTDIR\mvdsv.exe" 0
    FileWrite $STARTALLSERVERS "@start $\"$\" /min /b $\"$INSTDIR\shortcuts\fortress 27700.lnk$\"$\r$\n"
    FileWrite $INSTLOG "shortcuts\fortress 27700.lnk$\r$\n"
  ${EndIf}
  ${If} $ADDONS_CA == 1
    CreateShortCut "$INSTDIR\shortcuts\ca 27800.lnk" "$INSTDIR\mvdsv.exe" "-port 27800 -game cace +exec port1.cfg" "$INSTDIR\mvdsv.exe" 0
    FileWrite $STARTALLSERVERS "@start $\"$\" /min /b $\"$INSTDIR\shortcuts\ca 27800.lnk$\"$\r$\n"
    FileWrite $INSTLOG "shortcuts\ca 27800.lnk$\r$\n"
  ${EndIf}
  ${If} $ADDONS_QTV == 1
    CreateShortCut "$INSTDIR\shortcuts\qtv 28000.lnk" "$INSTDIR\qtv\qtv.exe" "+exec qtv.cfg" "$INSTDIR\qtv\qtv.exe" 0
    FileWrite $STARTALLSERVERS "@start $\"$\" /min /b $\"$INSTDIR\shortcuts\qtv 28000.lnk$\"$\r$\n"
    FileWrite $INSTLOG "shortcuts\qtv 28000.lnk$\r$\n"
  ${EndIf}
  ${If} $ADDONS_QWFWD == 1
    CreateShortCut "$INSTDIR\shortcuts\qwfwd 30000.lnk" "$INSTDIR\qwfwd\qwfwd.exe" "" "$INSTDIR\qwfwd\qwfwd.exe" 0
    FileWrite $STARTALLSERVERS "@start $\"$\" /min /b $\"$INSTDIR\shortcuts\qwfwd 30000.lnk$\"$\r$\n"
    FileWrite $INSTLOG "shortcuts\qwfwd 30000.lnk$\r$\n"
  ${EndIf}
  FileWrite $STARTALLSERVERS "exit$\r$\n"
  FileClose $STARTALLSERVERS
  FileWrite $INSTLOG "shortcuts\start_all_servers.bat$\r$\n"

SectionEnd

Section "" # StartMenu

  # Copy the first char of the startmenu folder selected during installation
  StrCpy $0 $STARTMENU_FOLDER 1

  ${Unless} $0 == ">"
    CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER"

    # Create links
    CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER\Links"
    WriteINIStr "$SMPROGRAMS\$STARTMENU_FOLDER\Links\Latest News.url" "InternetShortcut" "URL" "http://www.quakeworld.nu/"
    WriteINIStr "$SMPROGRAMS\$STARTMENU_FOLDER\Links\Message Board.url" "InternetShortcut" "URL" "http://www.quakeworld.nu/forum/"
    WriteINIStr "$SMPROGRAMS\$STARTMENU_FOLDER\Links\List of Servers.url" "InternetShortcut" "URL" "http://www.quakeservers.net/quakeworld/servers/pl=1/so=8/"
    WriteINIStr "$SMPROGRAMS\$STARTMENU_FOLDER\Links\Custom Graphics.url" "InternetShortcut" "URL" "http://gfx.quakeworld.nu/"

    # Create shortcuts
    CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER\Servers"
    CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER\Proxies"
    ${ForEach} $i 1 $CONFIG_PORTS + 1
      CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Servers\KTX #2850$i.lnk" "$INSTDIR\mvdsv.exe" "-port 2850$i -game ktx +exec port$i.cfg" "$INSTDIR\mvdsv.exe" 0
    ${Next}
    ${If} $ADDONS_FFA == 1
      CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Servers\Free For All #27500.lnk" "$INSTDIR\mvdsv.exe" "-port 27500 -game ffa +exec port1.cfg" "$INSTDIR\mvdsv.exe" 0
    ${EndIf}
    ${If} $ADDONS_FORTRESS == 1
      CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Servers\Team Fortress #27700.lnk" "$INSTDIR\mvdsv.exe" "-port 27700 -game fortress +exec port1.cfg" "$INSTDIR\mvdsv.exe" 0
    ${EndIf}
    ${If} $ADDONS_CA == 1
      CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Servers\Clan Arena #27800.lnk" "$INSTDIR\mvdsv.exe" "-port 27800 -game cace +exec port1.cfg" "$INSTDIR\mvdsv.exe" 0
    ${EndIf}
    ${If} $ADDONS_QTV == 1
      CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Proxies\QTV #28000.lnk" "$INSTDIR\qtv\qtv.exe" "+exec qtv.cfg" "$INSTDIR\qtv\qtv.exe" 0
    ${EndIf}
    ${If} $ADDONS_QWFWD == 1
      CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Proxies\QWFWD #30000.lnk" "$INSTDIR\qwfwd\qwfwd.exe" "" "$INSTDIR\qwfwd\qwfwd.exe" 0
    ${EndIf}
    CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Start all servers.lnk" "$INSTDIR\shortcuts\start_all_servers.bat" "" "$INSTDIR\mvdsv.exe" 0 SW_SHOWMINIMIZED
    CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Readme.lnk" "$INSTDIR\readme.txt" "" "$INSTDIR\readme.txt" 0
    CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Uninstall nQuakesv.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0

    # Write startmenu folder to registry
    WriteRegStr HKCU "Software\nQuakesv" "StartMenu_Folder" $STARTMENU_FOLDER
  ${EndUnless}

SectionEnd

Section "" # Clean up installation

  # Write portx.cfgs
  ${ForEach} $i 1 $CONFIG_PORTS + 1
  FileOpen $PORTCONFIG "$INSTDIR\ktx\port$i.cfg" w
    FileWrite $PORTCONFIG "// server info$\r$\n"
    FileWrite $PORTCONFIG "hostname                        $\"$CONFIG_HOSTNAME KTX #2850$i$\" // server name shown in server browsers$\r$\n"
    FileWrite $PORTCONFIG "sv_admininfo                    $\"$CONFIG_ADMIN <$CONFIG_EMAIL>$\" // admin name shown in server browsers$\r$\n"
    FileWrite $PORTCONFIG "sv_serverip                     $\"$CONFIG_DNS$\" // listen to this ip$\r$\n"
    FileWrite $PORTCONFIG "qtv_streamport                  $\"2850$i$\" // stream qtv to this tcp port$\r$\n"
    FileWrite $PORTCONFIG "$\r$\n"
    FileWrite $PORTCONFIG "// motd (max 15 rows) - this is the welcome message displayed when you connect to a server$\r$\n"
    FileWrite $PORTCONFIG "set k_motd1                     $\"$CONFIG_HOSTNAME KTX #2850$i$\"$\r$\n"
    FileWrite $PORTCONFIG "set k_motd2                     $\" $\"$\r$\n"
    FileWrite $PORTCONFIG "set k_motd3                     $\"Available game modes:$\"$\r$\n"
    FileWrite $PORTCONFIG "set k_motd4                     $\"1on1, 2on2, 4on4, 10on10, ffa, ctf$\"$\r$\n"
    FileWrite $PORTCONFIG "//set k_motd5                     $\"line 5$\" // etc..$\r$\n"
    FileWrite $PORTCONFIG "$\r$\n"
    FileWrite $PORTCONFIG "set k_motd_time                 $\"5$\" // time motd is displayed in seconds$\r$\n"
    FileClose $PORTCONFIG
    FileWrite $INSTLOG "ktx\port$i.cfg$\r$\n"
  ${Next}

  # Write port1.cfg (clan arena)
  ${If} $ADDONS_CA == 1
    FileOpen $PORTCONFIG "$INSTDIR\cace\port1.cfg" w
      FileWrite $PORTCONFIG "// server info$\r$\n"
      FileWrite $PORTCONFIG "hostname                        $\"$ADDONS_CA_HOSTNAME$\" // server name shown in server browsers$\r$\n"
      FileWrite $PORTCONFIG "sv_admininfo                    $\"$CONFIG_ADMIN <$CONFIG_EMAIL>$\" // admin name shown in server browsers$\r$\n"
      FileWrite $PORTCONFIG "sv_serverip                     $\"$CONFIG_DNS$\" // listen to this ip$\r$\n"
      FileWrite $PORTCONFIG "qtv_streamport                  $\"27800$\" // stream qtv to this tcp port$\r$\n"
      FileWrite $PORTCONFIG "$\r$\n"
      FileWrite $PORTCONFIG "// motd (max 15 rows) - this is the welcome message displayed when you connect to a server$\r$\n"
      FileWrite $PORTCONFIG "set k_motd1                     $\"$ADDONS_CA_HOSTNAME$\"$\r$\n"
      FileWrite $PORTCONFIG "set k_motd2                     $\" $\"$\r$\n"
      FileWrite $PORTCONFIG "set k_motd3                     $\"This server runs nQuakesv+CACE$\"$\r$\n"
      FileWrite $PORTCONFIG "set k_motd4                     $\"$\"$\r$\n"
      FileWrite $PORTCONFIG "set k_motd5                     $\"Enjoy your stay!$\" // etc..$\r$\n"
      FileWrite $PORTCONFIG "$\r$\n"
      FileWrite $PORTCONFIG "set k_motd_time                 $\"5$\" // time motd is displayed in seconds$\r$\n"
    FileClose $PORTCONFIG
  ${EndIf}

  # Write port1.cfg (free for all)
  ${If} $ADDONS_FFA == 1
    FileOpen $PORTCONFIG "$INSTDIR\ffa\port1.cfg" w
      FileWrite $PORTCONFIG "// server info$\r$\n"
      FileWrite $PORTCONFIG "hostname                        $\"$ADDONS_FFA_HOSTNAME$\" // server name shown in server browsers$\r$\n"
      FileWrite $PORTCONFIG "sv_admininfo                    $\"$CONFIG_ADMIN <$CONFIG_EMAIL>$\" // admin name shown in server browsers$\r$\n"
      FileWrite $PORTCONFIG "sv_serverip                     $\"$CONFIG_DNS$\" // listen to this ip$\r$\n"
      FileWrite $PORTCONFIG "qtv_streamport                  $\"27500$\" // stream qtv to this tcp port$\r$\n"
      FileWrite $PORTCONFIG "$\r$\n"
      FileWrite $PORTCONFIG "// motd (max 15 rows) - this is the welcome message displayed when you connect to a server$\r$\n"
      FileWrite $PORTCONFIG "set k_motd1                     $\"$ADDONS_FFA_HOSTNAME$\"$\r$\n"
      FileWrite $PORTCONFIG "set k_motd2                     $\" $\"$\r$\n"
      FileWrite $PORTCONFIG "set k_motd3                     $\"This server runs nQuakesv+FFA$\"$\r$\n"
      FileWrite $PORTCONFIG "set k_motd4                     $\"$\"$\r$\n"
      FileWrite $PORTCONFIG "set k_motd5                     $\"Enjoy your stay!$\" // etc..$\r$\n"
      FileWrite $PORTCONFIG "$\r$\n"
      FileWrite $PORTCONFIG "set k_motd_time                 $\"5$\" // time motd is displayed in seconds$\r$\n"
    FileClose $PORTCONFIG
  ${EndIf}

  # Write port1.cfg (team fortress)
  ${If} $ADDONS_FORTRESS == 1
    FileOpen $PORTCONFIG "$INSTDIR\fortress\port1.cfg" w
      FileWrite $PORTCONFIG "// server info$\r$\n"
      FileWrite $PORTCONFIG "hostname                        $\"$ADDONS_FORTRESS_HOSTNAME$\" // server name shown in server browsers$\r$\n"
      FileWrite $PORTCONFIG "sv_admininfo                    $\"$CONFIG_ADMIN <$CONFIG_EMAIL>$\" // admin name shown in server browsers$\r$\n"
      FileWrite $PORTCONFIG "sv_serverip                     $\"$CONFIG_DNS$\" // listen to this ip$\r$\n"
      FileWrite $PORTCONFIG "qtv_streamport                  $\"27700$\" // stream qtv to this tcp port$\r$\n"
      FileWrite $PORTCONFIG "$\r$\n"
      FileWrite $PORTCONFIG "// motd (max 15 rows) - this is the welcome message displayed when you connect to a server$\r$\n"
      FileWrite $PORTCONFIG "set k_motd1                     $\"$ADDONS_FORTRESS_HOSTNAME$\"$\r$\n"
      FileWrite $PORTCONFIG "set k_motd2                     $\" $\"$\r$\n"
      FileWrite $PORTCONFIG "set k_motd3                     $\"This server runs nQuakesv+TF$\"$\r$\n"
      FileWrite $PORTCONFIG "set k_motd4                     $\"$\"$\r$\n"
      FileWrite $PORTCONFIG "set k_motd5                     $\"Enjoy your stay!$\" // etc..$\r$\n"
      FileWrite $PORTCONFIG "$\r$\n"
      FileWrite $PORTCONFIG "set k_motd_time                 $\"5$\" // time motd is displayed in seconds$\r$\n"
    FileClose $PORTCONFIG
    CopyFiles /SILENT "$INSTDIR\fortress\port1.cfg" "$INSTDIR\thundervote\port1.cfg"
    FileWrite $INSTLOG "thundervote\port1.cfg$\r$\n"
  ${EndIf}

  # Write pwd.cfgs
  FileOpen $PASSWORDCONFIG "$INSTDIR\ktx\pwd.cfg" w
    FileWrite $PASSWORDCONFIG "// nQuakesv password file$\r$\n"
    FileWrite $PASSWORDCONFIG "$\r$\n"
    FileWrite $PASSWORDCONFIG "rcon_password $\"$CONFIG_RCON$\" // this password can issue any command to MVDSV$\r$\n"
    FileWrite $PASSWORDCONFIG "qtv_password $\"$\" // this password is needed to connect to qtv servers$\r$\n"
  FileClose $PASSWORDCONFIG

  # Write qtv.cfg
  FileOpen $QTVCONFIG "$INSTDIR\qtv\qtv.cfg" w
    FileWrite $QTVCONFIG "mvdport 28000$\r$\n"
    FileWrite $QTVCONFIG "hostname $ADDONS_QTV_HOSTNAME$\r$\n"
    FileWrite $QTVCONFIG "admin_password $ADDONS_QTV_PASSWORD$\r$\n"
    FileWrite $QTVCONFIG "maxclients 100$\r$\n"
    FileWrite $QTVCONFIG "maxservers 100$\r$\n"
    FileWrite $QTVCONFIG "floodprot 4 2 2$\r$\n"
    FileWrite $QTVCONFIG "demo_dir ../demos/$\r$\n"
    FileWrite $QTVCONFIG "allow_http 1$\r$\n"
    FileWrite $QTVCONFIG "allow_download_other 1$\r$\n"
    FileWrite $QTVCONFIG "allow_download_demos 1$\r$\n"
    FileWrite $QTVCONFIG "allow_download_maps 1$\r$\n"
    FileWrite $QTVCONFIG "allow_download_sounds 1$\r$\n"
    FileWrite $QTVCONFIG "allow_download_models 1$\r$\n"
    FileWrite $QTVCONFIG "allow_download_skins 1$\r$\n"
    FileWrite $QTVCONFIG "allow_download 1$\r$\n"
    FileWrite $QTVCONFIG "$\r$\n"
    FileWrite $QTVCONFIG "// servers to monitor$\r$\n"
    ${ForEach} $i 1 $CONFIG_PORTS + 1
      FileWrite $QTVCONFIG "qtv $CONFIG_DNS:2850$i$\r$\n"
    ${Next}
    ${If} $ADDONS_CA == 1
      FileWrite $QTVCONFIG "qtv $CONFIG_DNS:27800$\r$\n"
    ${EndIf}
    ${If} $ADDONS_FFA == 1
      FileWrite $QTVCONFIG "qtv $CONFIG_DNS:27500$\r$\n"
    ${EndIf}
    ${If} $ADDONS_FORTRESS == 1
      FileWrite $QTVCONFIG "qtv $CONFIG_DNS:27700$\r$\n"
    ${EndIf}
  FileClose $QTVCONFIG

  # Write qwfwd.cfg
  FileOpen $QWFWDCONFIG "$INSTDIR\qwfwd\qwfwd.cfg" w
  FileWrite $QWFWDCONFIG "set hostname $\"$ADDONS_QWFWD_HOSTNAME$\"  // specify a hostname$\r$\n"
  FileWrite $QWFWDCONFIG "set net_port 30000        // specify UDP listening port (default: 30000)$\r$\n"
  FileWrite $QWFWDCONFIG "// set net_ip         // specify IP-address listen to (default: all IPs)$\r$\n"
  FileWrite $QWFWDCONFIG "set sys_readstdin 0       // allows qwfwd to run in background$\r$\n"
  FileWrite $QWFWDCONFIG "// set developer        // enabled developer (0=off, 1=enabled)$\r$\n"
  FileWrite $QWFWDCONFIG "set masters qwmaster.ocrana.de:27000    // specify a list of master servers$\r$\n"
  FileWrite $QWFWDCONFIG "set masters_heartbeat 0       // allow sending heartbeats to masters (0=off, 1=enabled)$\r$\n"
  FileWrite $QWFWDCONFIG "set masters_query 0       // query the master server list (0=off, 1=enabled)$\r$\n"
  FileCLose $QWFWDCONFIG

  # Close open temporary files
  FileClose $INSTLOG
  FileClose $ERRLOG
  FileClose $DISTLOG

  # Write install.log
  FileOpen $INSTLOG "$INSTDIR\install.log" w
    ${time::GetFileTime} "$INSTDIR\install.log" $0 $1 $2
    FileWrite $INSTLOG "Install date: $1$\r$\n"
    FileOpen $R0 $INSTLOGTMP r
      ClearErrors
      ${DoUntil} ${Errors}
        FileRead $R0 $0
        StrCpy $0 $0 -2
        ${If} ${FileExists} "$INSTDIR\$0"
          FileWrite $INSTLOG "$0$\r$\n"
        ${EndIf}
      ${LoopUntil} ${Errors}
    FileClose $R0
  FileClose $INSTLOG

  # Remove downloaded distfiles
  ${If} $DISTFILES_DELETE == 1
    FileOpen $DISTLOG $DISTLOGTMP r
      ${DoUntil} ${Errors}
        FileRead $DISTLOG $0
        StrCpy $0 $0 -2
        ${If} ${FileExists} "$DISTFILES_PATH\$0"
          Delete /REBOOTOK "$DISTFILES_PATH\$0"
        ${EndIf}
      ${LoopUntil} ${Errors}
    FileClose $DISTLOG
    # Remove directory if empty
    !insertmacro RemoveFolderIfEmpty $DISTFILES_PATH
  # Copy nquake.ini to the distfiles directory if "update distfiles" and "keep distfiles" was set
  ${ElseIf} $DISTFILES_UPDATE == 1
    FlushINI $NQUAKE_INI
    CopyFiles /SILENT $NQUAKE_INI "$DISTFILES_PATH\nquake.ini"
  ${EndIf}

  # Write to registry
  WriteRegStr HKCU "Software\nQuakesv" "Install_Dir" "$INSTDIR"
  WriteRegStr HKCU "Software\nQuakesv" "Setup_Dir" "$DISTFILES_PATH"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\nQuakesv" "DisplayName" "nQuakesv"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\nQuakesv" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\nQuakesv" "DisplayIcon" "$INSTDIR\uninstall.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\nQuakesv" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\nQuakesv" "Publisher" "The nQuakesv Team"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\nQuakesv" "URLUpdateInfo" "http://sourceforge.net/project/showfiles.php?group_id=197706"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\nQuakesv" "URLInfoAbout" "http://nquakesv.com/"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\nQuakesv" "HelpLink" "http://sourceforge.net/forum/forum.php?forum_id=702198"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\nQuakesv" "NoModify" "1"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\nQuakesv" "NoRepair" "1"

  # Create uninstaller
  WriteUninstaller "uninstall.exe"

SectionEnd

;----------------------------------------------------
;Uninstaller Section

Section "Uninstall"

  # Set out path to temporary files
  SetOutPath $TEMP

  # Read uninstall settings
  !insertmacro MUI_INSTALLOPTIONS_READ $REMOVE_MODIFIED_FILES "uninstall.ini" "Field 5" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $REMOVE_ALL_FILES "uninstall.ini" "Field 6" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $REMOVE_SETUP_FILES "uninstall.ini" "Field 7" "State"

  # Set progress bar to 0%
  RealProgress::SetProgress /NOUNLOAD 0

  # If install.log exists and user didn't check "remove all files", remove all files listed in install.log
  ${If} ${FileExists} "$INSTDIR\install.log"
  ${AndIf} $REMOVE_ALL_FILES != 1
    # Get line count for install.log
    Push "$INSTDIR\install.log"
    Call un.LineCount
    Pop $R1 # Line count
    IntOp $R1 $R1 - 1 # Remove the timestamp from the line count
    FileOpen $R0 "$INSTDIR\install.log" r
    # Get installation time from install.log
    FileRead $R0 $0
    StrCpy $1 $0 -2 14
    StrCpy $5 1 # Current line
    StrCpy $6 0 # Current % Progress
    ${DoUntil} ${Errors}
      FileRead $R0 $0
      StrCpy $0 $0 -2
      # Only remove file if it has not been altered since install, if the user chose to do so
      ${If} ${FileExists} "$INSTDIR\$0"
      ${AndUnless} $REMOVE_MODIFIED_FILES == 1
        ${time::GetFileTime} "$INSTDIR\$0" $2 $3 $4
        ${time::MathTime} "second($1) - second($3) =" $2
        ${If} $2 >= 0
          Delete /REBOOTOK "$INSTDIR\$0"
        ${EndIf}
      ${ElseIf} $REMOVE_MODIFIED_FILES == 1
      ${AndIf} ${FileExists} "$INSTDIR\$0"
        Delete /REBOOTOK "$INSTDIR\$0"
      ${EndIf}
      # Set progress bar
      IntOp $7 $5 * 100
      IntOp $7 $7 / $R1
      RealProgress::SetProgress /NOUNLOAD $7
      IntOp $5 $5 + 1
    ${LoopUntil} ${Errors}
    FileClose $R0
    Delete /REBOOTOK "$INSTDIR\install.log"
    Delete /REBOOTOK "$INSTDIR\uninstall.exe"
    ${locate::RMDirEmpty} $INSTDIR /M=*.* $0
    DetailPrint "Removed $0 empty directories"
    # Remove directory if empty
    !insertmacro RemoveFolderIfEmpty $INSTDIR
  ${Else}
    # Ask the user if he is sure about removing all the files contained within the nQuakesv directory
    MessageBox MB_YESNO|MB_ICONEXCLAMATION "This will remove all files contained within the nQuakesv directory.$\r$\n$\r$\nAre you sure?" IDNO AbortUninst
    RMDir /r /REBOOTOK $INSTDIR
    RealProgress::SetProgress /NOUNLOAD 100
  ${EndIf}

  # Remove setup files if user checked "remove setup files"
  ${If} $REMOVE_SETUP_FILES == 1
    ReadRegStr $R0 HKCU "Software\nQuakesv" "Setup_Dir"
    ${If} ${FileExists} "$R0\nquake.ini"
      Delete /REBOOTOK "$R0\nquake.ini"
    ${EndIf}
    ${If} ${FileExists} "$R0\pak0.pak"
      Delete /REBOOTOK "$R0\pak0.pak"
    ${EndIf}
    ${If} ${FileExists} "$R0\pak1.pak"
      Delete /REBOOTOK "$R0\pak1.pak"
    ${EndIf}
    ${If} ${FileExists} "$R0\sv-bin-win32.zip"
      Delete /REBOOTOK "$R0\sv-bin-win32.zip"
    ${EndIf}
    ${If} ${FileExists} "$R0\sv-ca.zip"
      Delete /REBOOTOK "$R0\sv-ca.zip"
    ${EndIf}
    ${If} ${FileExists} "$R0\sv-configs.zip"
      Delete /REBOOTOK "$R0\sv-configs.zip"
    ${EndIf}
    ${If} ${FileExists} "$R0\sv-ffa.zip"
      Delete /REBOOTOK "$R0\sv-ffa.zip"
    ${EndIf}
    ${If} ${FileExists} "$R0\sv-fortress.zip"
      Delete /REBOOTOK "$R0\sv-fortress.zip"
    ${EndIf}
    ${If} ${FileExists} "$R0\sv-gpl.zip"
      Delete /REBOOTOK "$R0\sv-gpl.zip"
    ${EndIf}
    ${If} ${FileExists} "$R0\sv-maps.zip"
      Delete /REBOOTOK "$R0\sv-maps.zip"
    ${EndIf}
    ${If} ${FileExists} "$R0\sv-non-gpl.zip"
      Delete /REBOOTOK "$R0\sv-non-gpl.zip"
    ${EndIf}
    ${If} ${FileExists} "$R0\sv-win32.zip"
      Delete /REBOOTOK "$R0\sv-win32.zip"
    ${EndIf}
    # Remove directory if empty
    ${locate::RMDirEmpty} $R0 /M=*.* $0
    !insertmacro RemoveFolderIfEmpty $R0
  ${EndIf}

  # Remove start menu items and registry entries if they belong to this nQuakesv
  ReadRegStr $R0 HKCU "Software\nQuakesv" "Install_Dir"
  ${If} $R0 == $INSTDIR
    # Remove start menu items
    ReadRegStr $R0 HKCU "Software\nQuakesv" "StartMenu_Folder"
    RMDir /r /REBOOTOK "$SMPROGRAMS\$R0"
    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\nQuakesv"
    DeleteRegKey HKCU "Software\nQuakesv"
  ${EndIf}

  Goto FinishUninst
  AbortUninst:
  Abort "Uninstallation aborted."
  FinishUninst:

SectionEnd

;----------------------------------------------------
;Custom Pages

Function DOWNLOAD

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "download.ini"
  # Change the text on the distfile folder page if the installer is in offline mode
  ${If} $OFFLINE == 1
    !insertmacro MUI_HEADER_TEXT "Setup Files" "Select where the setup files are located."
    !insertmacro MUI_INSTALLOPTIONS_WRITE "download.ini" "Field 1" "Text" "Setup will use the setup files located in the following folder. To use a different folder, click Browse and select another folder. Click Next to continue."
    !insertmacro MUI_INSTALLOPTIONS_WRITE "download.ini" "Field 4" "Type" ""
    !insertmacro MUI_INSTALLOPTIONS_WRITE "download.ini" "Field 4" "State" "0"
    !insertmacro MUI_INSTALLOPTIONS_WRITE "download.ini" "Field 5" "Type" ""
    !insertmacro MUI_INSTALLOPTIONS_WRITE "download.ini" "Field 5" "State" "0"
  ${Else}
    !insertmacro MUI_HEADER_TEXT "Setup Files" "Select the download location for the setup files."
  ${EndIf}
  !insertmacro MUI_INSTALLOPTIONS_WRITE "download.ini" "Field 3" "State" ${DISTFILES_PATH}

  # Only display mirror selection if the installer is in online mode
  ${Unless} $OFFLINE == 1
    # Fix the mirrors for the Preferences page
    StrCpy $0 1
    StrCpy $2 "Randomly selected mirror (Recommended)"
    ReadINIStr $1 $NQUAKE_INI "mirror_descriptions" $0
    ${DoUntil} $1 == ""
      ReadINIStr $1 $NQUAKE_INI "mirror_descriptions" $0
      ${Unless} $1 == ""
        StrCpy $2 "$2|$1"
      ${EndUnless}
      IntOp $0 $0 + 1
    ${LoopUntil} $1 == ""

    StrCpy $0 $2 3
    ${If} $0 == "|"
      StrCpy $2 $2 "" 1
    ${EndIf}

    !insertmacro MUI_INSTALLOPTIONS_WRITE "download.ini" "Field 8" "ListItems" $2
  ${EndUnless}

  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "download.ini"

FunctionEnd

Function FULLVERSION

  # Copy pak1.pak if it can be found alongside the installer executable
  ${If} ${FileExists} "$LOCALAPPDATA\nQuakesv\pak1.pak"
    StrCpy $R0 "$LOCALAPPDATA\nQuakesv"
  ${ElseIf} ${FileExists} "$EXEDIR\pak1.pak"
    StrCpy $R0 "$EXEDIR"
  ${ElseIf} ${FileExists} "C:\nQuake\id1\pak1.pak"
    StrCpy $R0 "C:\nQuake\id1"
  ${EndIf}
  ${GetSize} $R0 "/M=pak1.pak /S=0B /G=0" $7 $8 $9
  ${If} $7 == "34257856"
    !insertmacro MUI_INSTALLOPTIONS_WRITE "fullversion.ini" "Field 3" "State" "$R0\pak1.pak"
    StrCpy $PAK_LOCATION "$R0\pak1.pak"
    Goto SkipFullVersion
  ${EndIf}

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "fullversion.ini"
  !insertmacro MUI_HEADER_TEXT "Full Version Data" "Locate Quake registered data."

  # Look for pak1.pak in 28 likely locations
  ${If} ${FileExists} "C:\Quake\id1\pak1.pak"
    StrCpy $0 "C:\Quake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "D:\Quake\id1\pak1.pak"
    StrCpy $0 "D:\Quake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "E:\Quake\id1\pak1.pak"
    StrCpy $0 "E:\Quake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "C:\Games\Quake\id1\pak1.pak"
    StrCpy $0 "C:\Games\Quake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "D:\Games\Quake\id1\pak1.pak"
    StrCpy $0 "D:\Games\Quake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "E:\Games\Quake\id1\pak1.pak"
    StrCpy $0 "E:\Games\Quake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "C:\Program Files\Quake\id1\pak1.pak"
    StrCpy $0 "C:\Program Files\Quake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "C:\nQuake\id1\pak1.pak"
    StrCpy $0 "C:\nQuake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "D:\nQuake\id1\pak1.pak"
    StrCpy $0 "D:\nQuake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "E:\nQuake\id1\pak1.pak"
    StrCpy $0 "E:\nQuake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "C:\Games\nQuake\id1\pak1.pak"
    StrCpy $0 "C:\Games\nQuake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "D:\Games\nQuake\id1\pak1.pak"
    StrCpy $0 "D:\Games\nQuake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "E:\Games\nQuake\id1\pak1.pak"
    StrCpy $0 "E:\Games\nQuake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "C:\Program Files\nQuake\id1\pak1.pak"
    StrCpy $0 "C:\Program Files\nQuake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "C:\Valve\Steam\SteamApps\common\Quake\id1\pak1.pak"
    StrCpy $0 "C:\Valve\Steam\SteamApps\common\Quake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "D:\Valve\Steam\SteamApps\common\Quake\id1\pak1.pak"
    StrCpy $0 "D:\Valve\Steam\SteamApps\common\Quake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "E:\Valve\Steam\SteamApps\common\Quake\id1\pak1.pak"
    StrCpy $0 "E:\Valve\Steam\SteamApps\common\Quake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "C:\Steam\SteamApps\common\Quake\id1\pak1.pak"
    StrCpy $0 "C:\Steam\SteamApps\common\Quake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "D:\Steam\SteamApps\common\Quake\id1\pak1.pak"
    StrCpy $0 "D:\Steam\SteamApps\common\Quake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "E:\Steam\SteamApps\common\Quake\id1\pak1.pak"
    StrCpy $0 "E:\Steam\SteamApps\common\Quake\id1"
    !insertmacro ValidatePak $0
  ${EndIf}
  ${If} ${FileExists} "C:\Program Files\Valve\Steam\SteamApps\common\Quake\id1\pak1.pak"
    StrCpy $0 "C:\Program Files\Valve\Steam\SteamApps\common\Quake\id1"
    !insertmacro ValidatePak $0
  ${Else}
    Goto FullVersionEnd
  ${EndIf}

  FullVersion:
  !insertmacro MUI_INSTALLOPTIONS_WRITE "fullversion.ini" "Field 1" "Text" "The full version of Quake is not included in this package. However, setup has found what resembles the full version pak1.pak on your harddrive. If this is not the correct file, click Browse to locate the correct pak1.pak. Click Next to continue."
  !insertmacro MUI_INSTALLOPTIONS_WRITE "fullversion.ini" "Field 3" "State" "$0\pak1.pak"
  FullVersionEnd:
  # Remove the purchase link if the installer is in offline mode
  ${If} $OFFLINE == 1
    !insertmacro MUI_INSTALLOPTIONS_WRITE "fullversion.ini" "Field 4" "Type" ""
  ${EndIf}
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "fullversion.ini"

  SkipFullVersion:

FunctionEnd

Function CONFIG

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "config.ini"
  !insertmacro MUI_HEADER_TEXT "Configuration" "Setup server configuration."
  System::Call "advapi32::GetUserName(t .r0, *i ${NSIS_MAX_STRLEN} r1) i.r2"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "config.ini" "Field 4" "State" "$0"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "config.ini" "Field 6" "State" "$0@example.com"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "config.ini" "Field 15" "State" "$0 nQuake"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "config.ini"

FunctionEnd

Function ADDONS

  !insertmacro MUI_INSTALLOPTIONS_READ $0 "config.ini" "Field 15" "State"
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "addons.ini"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "addons.ini" "Field 5" "State" "$0 QTV"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "addons.ini" "Field 11" "State" "$0 QWFWD"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "addons.ini" "Field 15" "State" "$0 Team Fortress"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "addons.ini" "Field 18" "State" "$0 Free For All"
  !insertmacro MUI_INSTALLOPTIONS_WRITE "addons.ini" "Field 21" "State" "$0 Clan Arena"
  !insertmacro DetermineSectionSize sv-fortress.zip
  IntOp $1 $SIZE / 1000
  !insertmacro MUI_INSTALLOPTIONS_WRITE "addons.ini" "Field 13" "Text" "Install Team Fortress ($1 MB)"
  !insertmacro DetermineSectionSize sv-ffa.zip
  IntOp $1 $SIZE / 1000
  !insertmacro MUI_INSTALLOPTIONS_WRITE "addons.ini" "Field 16" "Text" "Install Free For All ($1 MB)"
  !insertmacro DetermineSectionSize sv-ca.zip
  IntOp $1 $SIZE / 1000
  !insertmacro MUI_INSTALLOPTIONS_WRITE "addons.ini" "Field 19" "Text" "Install Clan Arena ($1 MB)"
  !insertmacro MUI_HEADER_TEXT "Configuration" "Setup modifications and proxies."
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "addons.ini"

FunctionEnd

Function ERRORS

  # Only display error page if errors occured during installation
  ${If} $ERRORS > 0
    # Read errors from error log
    StrCpy $1 ""
    FileOpen $R0 $ERRLOGTMP r
      ClearErrors
      FileRead $R0 $0
      StrCpy $1 $0
      ${DoUntil} ${Errors}
        FileRead $R0 $0
        ${Unless} $0 == ""
          StrCpy $1 "$1|$0"
        ${EndUnless}
      ${LoopUntil} ${Errors}
    FileClose $R0

    !insertmacro MUI_INSTALLOPTIONS_EXTRACT "errors.ini"
    ${If} $ERRORS == 1
      !insertmacro MUI_HEADER_TEXT "Error" "An error occurred during the installation of nQuakesv."
      !insertmacro MUI_INSTALLOPTIONS_WRITE "errors.ini" "Field 1" "Text" "There was an error during the installation of nQuakesv. See below for more information."
    ${Else}
      !insertmacro MUI_HEADER_TEXT "Errors" "Some errors occurred during the installation of nQuakesv."
      !insertmacro MUI_INSTALLOPTIONS_WRITE "errors.ini" "Field 1" "Text" "There were some errors during the installation of nQuakesv. See below for more information."
    ${EndIf}
    !insertmacro MUI_INSTALLOPTIONS_WRITE "errors.ini" "Field 2" "ListItems" $1
    !insertmacro MUI_INSTALLOPTIONS_DISPLAY "errors.ini"
  ${EndIf}

FunctionEnd

Function un.UNINSTALL

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "uninstall.ini"

  # Remove all options on uninstall page except for "remove all files" if install.log is missing
  ${Unless} ${FileExists} "$INSTDIR\install.log"
    !insertmacro MUI_INSTALLOPTIONS_WRITE "uninstall.ini" "Field 4" "State" "0"
    !insertmacro MUI_INSTALLOPTIONS_WRITE "uninstall.ini" "Field 4" "Flags" "DISABLED"
    !insertmacro MUI_INSTALLOPTIONS_WRITE "uninstall.ini" "Field 5" "Flags" "DISABLED"
    !insertmacro MUI_INSTALLOPTIONS_WRITE "uninstall.ini" "Field 6" "Text" "Remove all files contained within the nQuakesv directory (install.log missing)."
    !insertmacro MUI_INSTALLOPTIONS_WRITE "uninstall.ini" "Field 6" "State" "1"
    !insertmacro MUI_INSTALLOPTIONS_WRITE "uninstall.ini" "Field 6" "Flags" "FOCUS"
  ${EndUnless}
  !insertmacro MUI_HEADER_TEXT "Uninstall nQuakesv" "Remove nQuakesv from your computer."
  !insertmacro MUI_INSTALLOPTIONS_WRITE "uninstall.ini" "Field 3" "State" "$INSTDIR\"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "uninstall.ini"

FunctionEnd

;----------------------------------------------------
;Welcome/Finish page manipulation

Function WelcomeShow
  # Remove the part about nQuakesv being an online installer on welcome page if the installer is in offline mode
  ${Unless} $OFFLINE == 1
    !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 3" "Text" "This is the installation wizard of nQuakesv, a QuakeWorld server package.\r\n\r\nThis is an online installer and therefore requires a stable internet connection."
  ${Else}
    !insertmacro MUI_INSTALLOPTIONS_WRITE "ioSpecial.ini" "Field 3" "Text" "This is the installation wizard of nQuakesv, a QuakeWorld server package."
  ${EndUnless}
FunctionEnd

Function FinishShow
  # Hide the Back button on the finish page if there were no errors
  ${Unless} $ERRORS > 0
    GetDlgItem $R0 $HWNDPARENT 3
    EnableWindow $R0 0
  ${EndUnless}
  # Hide the community link if the installer is in offline mode
  ${If} $OFFLINE == 1
    !insertmacro MUI_INSTALLOPTIONS_READ $R0 "ioSpecial.ini" "Field 5" "HWND"
    ShowWindow $R0 ${SW_HIDE}
  ${EndIf}
FunctionEnd


;----------------------------------------------------
;Download size manipulation

!define SetSize "Call SetSize"

Function SetSize
  !insertmacro MUI_INSTALLOPTIONS_READ $ADDONS_FFA "addons.ini" "Field 16" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $ADDONS_CA "addons.ini" "Field 19" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $ADDONS_FORTRESS "addons.ini" "Field 13" "State"
  !insertmacro MUI_INSTALLOPTIONS_READ $DISTFILES_PATH "download.ini" "Field 3" "State"
  IntOp $1 0 + 0
  # Only add shareware if pak0.pak doesn't exist
  IntOp $1 0 + 0
  ${Unless} ${FileExists} "$INSTDIR\ID1\pak0.pak"
    ${If} ${FileExists} "$EXEDIR\pak0.pak"
      StrCpy $R0 "$EXEDIR"
    ${ElseIf} ${FileExists} "$DISTFILES_PATH\pak0.pak"
      StrCpy $R0 "$DISTFILES_PATH"
    ${EndIf}
    ${GetSize} $R0 "/M=pak0.pak /S=0B /G=0" $7 $8 $9
    ${If} $7 == "18689235"
      Goto SkipShareware
    ${EndIf}
  ${EndUnless}
  !insertmacro DetermineSectionSize qsw106.zip
  IntOp $1 $1 + $SIZE
  SkipShareware:
  !insertmacro DetermineSectionSize sv-bin-win32.zip
  IntOp $1 $1 + $SIZE
  !insertmacro DetermineSectionSize sv-win32.zip
  IntOp $1 $1 + $SIZE
  ${If} $ADDONS_CA == 1
    !insertmacro DetermineSectionSize sv-ca.zip
    IntOp $1 $1 + $SIZE
  ${EndIf}
  !insertmacro DetermineSectionSize sv-configs.zip
  IntOp $1 $1 + $SIZE
  ${If} $ADDONS_FFA == 1
    !insertmacro DetermineSectionSize sv-ffa.zip
    IntOp $1 $1 + $SIZE
  ${EndIf}
  ${If} $ADDONS_FORTRESS == 1
    !insertmacro DetermineSectionSize sv-fortress.zip
    IntOp $1 $1 + $SIZE
  ${EndIf}
  !insertmacro DetermineSectionSize sv-gpl.zip
  IntOp $1 $1 + $SIZE
  !insertmacro DetermineSectionSize sv-maps.zip
  IntOp $1 $1 + $SIZE
  # Don't add the size of the GPL maps if pak1.pak exists
  ${If} ${FileExists} "$EXEDIR\pak1.pak"
    ${GetSize} $EXEDIR "/M=pak1.pak /S=0B /G=0" $7 $8 $9
    ${If} $7 == "34257856"
      Goto SkipGPLMaps
    ${EndIf}
  ${EndIf}
  !insertmacro DetermineSectionSize sv-maps-gpl.zip
  IntOp $1 $1 + $SIZE
  SkipGPLMaps:
  !insertmacro DetermineSectionSize sv-non-gpl.zip
  IntOp $1 $1 + $SIZE
FunctionEnd

Function DirectoryPageShow
  ${SetSize}
  SectionSetSize ${NQUAKESV} $1
FunctionEnd 

;----------------------------------------------------
;Functions

Function .onInit

  !insertmacro MULTIUSER_INIT
  GetTempFileName $NQUAKE_INI

  # Download nquake.ini
  Start:
  inetc::get /NOUNLOAD /CAPTION "Initializing..." /BANNER "nQuakesv is initializing, please wait..." /TIMEOUT 5000 "${INSTALLER_URL}/nquake.ini" $NQUAKE_INI /END
  Pop $0
  ${Unless} $0 == "OK"
    ${If} $0 == "Cancelled"
      MessageBox MB_OK|MB_ICONEXCLAMATION "Installation aborted."
      Abort
    ${Else}
      ${Unless} $RETRIES > 0
        MessageBox MB_YESNO|MB_ICONEXCLAMATION "Are you trying to install nQuakesv offline?" IDNO Online
        StrCpy $OFFLINE 1
        Goto InitEnd
      ${EndUnless}
      Online:
      ${Unless} $RETRIES == 2
        MessageBox MB_RETRYCANCEL|MB_ICONEXCLAMATION "Could not download nquake.ini." IDCANCEL Cancel
        IntOp $RETRIES $RETRIES + 1
        Goto Start
      ${EndUnless}
      MessageBox MB_OK|MB_ICONEXCLAMATION "Could not download nquake.ini. Please try again later."
      Cancel:
      Abort
    ${EndIf}
  ${EndUnless}

  # Prompt the user if there are newer installer versions available
  ReadINIStr $0 $NQUAKE_INI "versions" "serverwindows"
  ${VersionConvert} ${VERSION} "" $R0
  ${VersionCompare} $R0 $0 $1
  ${If} $1 == 2
    MessageBox MB_YESNO|MB_ICONEXCLAMATION "A newer version of nQuakesv is available.$\r$\n$\r$\nDo you wish to be taken to the download page?" IDNO ContinueInstall
    ExecShell "open" ${INSTALLER_URL}
    Abort
  ${EndIf}
  ContinueInstall:
  InitEnd:

FunctionEnd

Function un.onInit

  !insertmacro MULTIUSER_UNINIT

FunctionEnd

Function .abortInstallation

  # Close open temporary files
  FileClose $ERRLOG
  FileClose $INSTLOG
  FileClose $DISTLOG

  # Write install.log
  FileOpen $INSTLOG "$INSTDIR\install.log" w
    ${time::GetFileTime} "$INSTDIR\install.log" $0 $1 $2
    FileWrite $INSTLOG "Install date: $1$\r$\n"
    FileOpen $R0 $INSTLOGTMP r
      ClearErrors
      ${DoUntil} ${Errors}
        FileRead $R0 $0
        FileWrite $INSTLOG $0
      ${LoopUntil} ${Errors}
    FileClose $R0
  FileClose $INSTLOG

  # Ask to remove installed files
  Messagebox MB_YESNO|MB_ICONEXCLAMATION "Installation aborted.$\r$\n$\r$\nDo you wish to remove the installed files?" IDNO SkipInstRemoval
  # Show details window
  SetDetailsView show
  # Get line count for install.log
  Push "$INSTDIR\install.log"
  Call .LineCount
  Pop $R1 # Line count
  IntOp $R1 $R1 - 1 # Remove the timestamp from the line count
  FileOpen $R0 "$INSTDIR\install.log" r
    # Get installation time from install.log
    FileRead $R0 $0
    StrCpy $1 $0 -2 14
    StrCpy $5 1 # Current line
    StrCpy $6 0 # Current % Progress
    ${DoUntil} ${Errors}
      FileRead $R0 $0
      StrCpy $0 $0 -2
      ${If} ${FileExists} "$INSTDIR\$0"
        ${time::GetFileTime} "$INSTDIR\$0" $2 $3 $4
        ${time::MathTime} "second($1) - second($3) =" $2
        ${If} $2 >= 0
          Delete /REBOOTOK "$INSTDIR\$0"
        ${EndIf}
      ${EndIf}
      # Set progress bar
      IntOp $7 $5 * 100
      IntOp $7 $7 / $R1
      RealProgress::SetProgress /NOUNLOAD $7
      IntOp $5 $5 + 1
    ${LoopUntil} ${Errors}
  FileClose $R0
  Delete /REBOOTOK "$INSTDIR\install.log"
  ${locate::RMDirEmpty} $INSTDIR /M=*.* $0
  DetailPrint "Removed $0 empty directories"
  # Remove directory if empty
  !insertmacro RemoveFolderIfEmpty $INSTDIR
  Goto InstEnd
  SkipInstRemoval:
  Delete /REBOOTOK "$INSTDIR\install.log"
  InstEnd:

  # Ask to remove downloaded distfiles
  Messagebox MB_YESNO|MB_ICONEXCLAMATION "Do you wish to keep the downloaded distribution files?" IDYES DistEnd
  # Get line count for distfiles.log
  Push $DISTLOGTMP
  Call .LineCount
  Pop $R1 # Line count
  FileOpen $R0 $DISTLOGTMP r
    StrCpy $5 0 # Current line
    StrCpy $6 0 # Current % Progress
    ${DoUntil} ${Errors}
      FileRead $R0 $0
      StrCpy $0 $0 -2
      ${If} ${FileExists} "$DISTFILES_PATH\$0"
        Delete /REBOOTOK "$DISTFILES_PATH\$0"
      ${EndIf}
      # Set progress bar
      IntOp $7 $5 * 100
      IntOp $7 $7 / $R1
      RealProgress::SetProgress /NOUNLOAD $7
      IntOp $5 $5 + 1
    ${LoopUntil} ${Errors}
  FileClose $R0
  # Remove directory if empty
  !insertmacro RemoveFolderIfEmpty $DISTFILES_PATH
  DistEnd:

  # Set progress bar to 100%
  RealProgress::SetProgress /NOUNLOAD 100

  Abort

FunctionEnd

Function .checkDistfileDate
  StrCpy $R2 0
  ReadINIStr $0 $NQUAKE_INI "distfile_dates" $R0
  ${If} ${FileExists} "$DISTFILES_PATH\$R0"
    ${GetTime} "$DISTFILES_PATH\$R0" M $2 $3 $4 $5 $6 $7 $8
    # Fix hour format
    ${If} $6 < 10
      StrCpy $6 "0$6"
    ${EndIf}
    StrCpy $1 "$4$3$2$6$7$8"
    ${If} $1 < $0
    ${OrIf} $DISTFILES_REDOWNLOAD == 1
      StrCpy $R2 1
    ${Else}
      ReadINIStr $1 "$DISTFILES_PATH\nquake.ini" "distfile_dates" $R0
      ${Unless} $1 == ""
        ${If} $1 < $0
          StrCpy $R2 1
        ${EndIf}
      ${EndUnless}
    ${EndIf}
  ${EndIf}
FunctionEnd

Function .installDistfile
  Retry:
  ${Unless} $R2 == 0 # if $R2 is 1 then distfile needs updating, otherwise not
    inetc::get /NOUNLOAD /CAPTION "Downloading..." /BANNER "Downloading $R1 update, please wait..." /TIMEOUT 5000 "$DISTFILES_URL/$R0" "$DISTFILES_PATH\$R0" /END
  ${Else}
    inetc::get /NOUNLOAD /CAPTION "Downloading..." /BANNER "Downloading $R1, please wait..." /TIMEOUT 5000 "$DISTFILES_URL/$R0" "$DISTFILES_PATH\$R0" /END
  ${EndUnless}
  FileWrite $DISTLOG "$R0$\r$\n"
  Pop $0
  ${Unless} $0 == "OK"
    ${If} $0 == "Cancelled"
      Call .abortInstallation
    ${Else}
      MessageBox MB_ABORTRETRYIGNORE|MB_ICONEXCLAMATION "Error downloading $R0: $0" IDIGNORE Ignore IDRETRY Retry
      Call .abortInstallation
      Ignore:
      FileWrite $ERRLOG 'Error downloading "$R0": $0|'
      IntOp $ERRORS $ERRORS + 1
    ${EndIf}
  ${EndUnless}
  StrCpy $DISTFILES 1
  DetailPrint "Extracting $R1, please wait..."
  nsisunz::UnzipToStack "$DISTFILES_PATH\$R0" $INSTDIR
FunctionEnd

Function .installSection
  Pop $R1 # distfile info
  Pop $R0 # distfile filename
  Call .checkDistfileDate
  ${If} ${FileExists} "$EXEDIR\$R0"
    DetailPrint "Extracting $R1, please wait..."
    nsisunz::UnzipToStack "$EXEDIR\$R0" $INSTDIR
  ${ElseIf} ${FileExists} "$DISTFILES_PATH\$R0"
  ${OrIf} $OFFLINE == 1
    ${If} $DISTFILES_UPDATE == 0
    ${OrIf} $R2 == 0
      DetailPrint "Extracting $R1, please wait..."
      nsisunz::UnzipToStack "$DISTFILES_PATH\$R0" $INSTDIR
    ${ElseIf} $R2 == 1
    ${AndIf} $DISTFILES_UPDATE == 1
      Call .installDistfile
    ${EndIf}
  ${ElseUnless} ${FileExists} "$DISTFILES_PATH\$R0"
    Call .installDistfile
  ${EndIf}
  Pop $0
  ${If} $0 == "Error opening ZIP file"
  ${OrIf} $0 == "Error opening output file(s)"
  ${OrIf} $0 == "Error writing output file(s)"
  ${OrIf} $0 == "Error extracting from ZIP file"
  ${OrIf} $0 == "File not found in ZIP file"
    FileWrite $ERRLOG 'Error extracting "$R0": $0|'
    IntOp $ERRORS $ERRORS + 1
  ${Else}
    ${DoUntil} $0 == ""
      ${Unless} $0 == "success"
        FileWrite $INSTLOG "$0$\r$\n"
      ${EndUnless}
      Pop $0
    ${LoopUntil} $0 == ""
  ${EndIf}
FunctionEnd

Function .LineCount
  Exch $R0
  Push $R1
  Push $R2
   FileOpen $R0 $R0 r
  loop:
   ClearErrors
   FileRead $R0 $R1
   IfErrors +3
    IntOp $R2 $R2 + 1
  Goto loop
   FileClose $R0
   StrCpy $R0 $R2
  Pop $R2
  Pop $R1
  Exch $R0
FunctionEnd

Function un.LineCount
  Exch $R0
  Push $R1
  Push $R2
   FileOpen $R0 $R0 r
  loop:
   ClearErrors
   FileRead $R0 $R1
   IfErrors +3
    IntOp $R2 $R2 + 1
  Goto loop
   FileClose $R0
   StrCpy $R0 $R2
  Pop $R2
  Pop $R1
  Exch $R0
FunctionEnd