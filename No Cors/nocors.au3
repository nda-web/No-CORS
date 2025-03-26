#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <INet.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>
#include <Date.au3>
#include <Inet.au3>

; Configuración y constantes globales
Global Const $VERSION = "1.1"
Global $iniFile = @ScriptDir & "\navegadores.ini"
Global $backupDir = @ScriptDir & "\backups"
Global $browserPaths = ObjCreate("Scripting.Dictionary")
Global $customProfiles = ObjCreate("Scripting.Dictionary")

; Estructura para navegadores adicionales
Global $NAVEGADORES_CONFIG = ObjCreate("Scripting.Dictionary")
$NAVEGADORES_CONFIG.Add("Chrome", CreateBrowserConfig("chrome.exe", "ChromeTemp"))
$NAVEGADORES_CONFIG.Add("Edge", CreateBrowserConfig("msedge.exe", "EdgeTemp"))
$NAVEGADORES_CONFIG.Add("Opera", CreateBrowserConfig("opera.exe", "OperaTemp"))
$NAVEGADORES_CONFIG.Add("Brave", CreateBrowserConfig("brave.exe", "BraveTemp"))
$NAVEGADORES_CONFIG.Add("Vivaldi", CreateBrowserConfig("vivaldi.exe", "VivaldiTemp"))
$NAVEGADORES_CONFIG.Add("Firefox Developer", CreateBrowserConfig("firefox.exe", "FirefoxTemp"))
$NAVEGADORES_CONFIG.Add("Waterfox", CreateBrowserConfig("waterfox.exe", "WaterfoxTemp"))
$NAVEGADORES_CONFIG.Add("Pale Moon", CreateBrowserConfig("palemoon.exe", "PaleMoonTemp"))
$NAVEGADORES_CONFIG.Add("Chromium", CreateBrowserConfig("chromium.exe", "ChromiumTemp"))
$NAVEGADORES_CONFIG.Add("Iron", CreateBrowserConfig("iron.exe", "IronTemp"))

; Crear la ventana principal con diseño mejorado
$Form1 = GUICreate("No Cors " & $VERSION, 500, 400)
GUISetFont(10, 400, 0, "Segoe UI")

; Menú mejorado
Local $menuArchivo = GUICtrlCreateMenu("Archivo")
Local $menuBackup = GUICtrlCreateMenuItem("Crear Backup", $menuArchivo)
Local $menuRestore = GUICtrlCreateMenuItem("Restaurar Backup", $menuArchivo)
Local $menuAyuda = GUICtrlCreateMenu("Ayuda")
Local $menuAcercaDe = GUICtrlCreateMenuItem("Acerca de", $menuAyuda)

; Interfaz mejorada
$Label1 = GUICtrlCreateLabel("Selecciona el navegador:", 20, 20, 200, 20)
$Combo1 = GUICtrlCreateCombo("", 20, 50, 250, 25, $CBS_DROPDOWNLIST)
$Button1 = GUICtrlCreateButton("Habilitar/Deshabilitar Seguridad", 20, 90, 250, 30)
$Button2 = GUICtrlCreateButton("Test CORS", 20, 130, 250, 30)
$Button3 = GUICtrlCreateButton("Reescanear Navegadores", 20, 170, 250, 30)
$ProgressBar = GUICtrlCreateProgress(20, 220, 460, 20)
$Edit1 = GUICtrlCreateEdit("", 20, 250, 460, 130, BitOR($ES_READONLY, $ES_MULTILINE, $WS_VSCROLL))

; Inicialización
InitializeBackupSystem()
InicializarNavegadores()
GUISetState(@SW_SHOW)

; Bucle principal mejorado
While 1
    $nMsg = GUIGetMsg()
    Switch $nMsg
        Case $GUI_EVENT_CLOSE
            Exit
        Case $Button1
            HabilitarDeshabilitarSeguridad()
        Case $Button2
            TestCORS()
        Case $Button3
            InicializarNavegadores()
        Case $menuBackup
            CreateConfigBackup()
        Case $menuRestore
            RestoreConfigBackup()
        Case $menuAcercaDe
            MostrarCreditos()
    EndSwitch
WEnd

Func CreateBrowserConfig($exe, $tempFolder)
    Local $config = ObjCreate("Scripting.Dictionary")
    $config.Add("exe", $exe)
    $config.Add("tempFolder", $tempFolder)
    $config.Add("paths", ObjCreate("Scripting.Dictionary"))
    Return $config
EndFunc

Func InitializeBackupSystem()
    If Not FileExists($backupDir) Then
        DirCreate($backupDir)
    EndIf
    ; Limpiar backups antiguos (más de 30 días)
    Local $aBackups = _FileListToArray($backupDir, "*.bak")
    If Not @error Then
        For $i = 1 To $aBackups[0]
            If _DateDiff('D', FileGetTime($backupDir & "\" & $aBackups[$i], 1), _NowCalc()) > 30 Then
                FileDelete($backupDir & "\" & $aBackups[$i])
            EndIf
        Next
    EndIf
EndFunc

Func CreateConfigBackup()
    Local $timestamp = @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC
    Local $backupFile = $backupDir & "\nocors_" & $timestamp & ".bak"
    
    ; Guardar configuración actual
    Local $config = ObjCreate("Scripting.Dictionary")
    For $browser In $NAVEGADORES_CONFIG.Keys
        $config.Add($browser, $browserPaths($browser))
    Next
    
    ; Guardar en archivo
    Local $hFile = FileOpen($backupFile, 2)
    FileWrite($hFile, "NoCors Backup - " & _NowCalc() & @CRLF)
    For $browser In $config.Keys
        FileWrite($hFile, $browser & "=" & $config($browser) & @CRLF)
    Next
    FileClose($hFile)
    
    GUICtrlSetData($Edit1, "Backup creado: " & $backupFile)
EndFunc

Func RestoreConfigBackup()
    Local $aBackups = _FileListToArray($backupDir, "*.bak")
    If @error Then
        GUICtrlSetData($Edit1, "No hay backups disponibles")
        Return
    EndIf
    
    ; Mostrar diálogo de selección
    Local $sBackup = _ArrayToString($aBackups, "|", 1)
    Local $choice = InputBox("Restaurar Backup", "Seleccione el backup a restaurar:" & @CRLF & @CRLF & StringReplace($sBackup, "|", @CRLF))
    
    If @error Then Return
    
    ; Cargar y aplicar backup
    Local $hFile = FileOpen($backupDir & "\" & $choice, 0)
    If $hFile = -1 Then
        GUICtrlSetData($Edit1, "Error al abrir el archivo de backup")
        Return
    EndIf
    
    Local $line
    While 1
        $line = FileReadLine($hFile)
        If @error Then ExitLoop
        
        Local $aParts = StringSplit($line, "=")
        If $aParts[0] = 2 Then
            $browserPaths($aParts[1]) = $aParts[2]
        EndIf
    WEnd
    FileClose($hFile)
    
    GUICtrlSetData($Edit1, "Configuración restaurada desde: " & $choice)
    InicializarNavegadores()
EndFunc

Func InicializarNavegadores()
    GUICtrlSetData($Combo1, "") ; Limpiar combo box
    GUICtrlSetData($ProgressBar, 0)
    
    Local $navegadoresInstalados = ""
    Local $total = $NAVEGADORES_CONFIG.Count
    Local $current = 0
    Local $contadorInstalados = 0
    Local $listaDetallada = ""
    
    For $browser In $NAVEGADORES_CONFIG.Keys
        $current += 1
        GUICtrlSetData($ProgressBar, ($current / $total) * 100)
        
        Local $config = $NAVEGADORES_CONFIG($browser)
        Local $found = False
        
        ; Buscar en múltiples ubicaciones comunes
        Local $commonPaths = GetCommonPaths($browser)
        For $i = 0 To UBound($commonPaths) - 1
            If $commonPaths[$i] <> "" And FileExists($commonPaths[$i]) Then
                $browserPaths($browser) = $commonPaths[$i]
                $navegadoresInstalados &= $browser & "|"
                $contadorInstalados += 1
                $listaDetallada &= "✓ " & $browser & " - " & $commonPaths[$i] & @CRLF
                $found = True
                ExitLoop
            EndIf
        Next
        
        ; Buscar en el registro si no se encontró
        If Not $found Then
            Local $regPath = BuscarEnRegistro($browser)
            If $regPath Then
                $browserPaths($browser) = $regPath
                $navegadoresInstalados &= $browser & "|"
                $contadorInstalados += 1
                $listaDetallada &= "✓ " & $browser & " - " & $regPath & " (Registro)" & @CRLF
            Else
                $listaDetallada &= "✗ " & $browser & " - No encontrado" & @CRLF
            EndIf
        EndIf
    Next
    
    GUICtrlSetData($ProgressBar, 100)
    If $navegadoresInstalados Then
        GUICtrlSetData($Combo1, StringTrimRight($navegadoresInstalados, 1))
        GUICtrlSetData($Edit1, "Se encontraron " & $contadorInstalados & " navegadores instalados:" & @CRLF & @CRLF & $listaDetallada)
    Else
        GUICtrlSetData($Edit1, "No se encontraron navegadores compatibles" & @CRLF & @CRLF & $listaDetallada)
    EndIf
EndFunc

Func GetCommonPaths($browser)
    Local $paths[10]
    Local $config = $NAVEGADORES_CONFIG($browser)
    Local $exe = $config("exe")
    
    $paths[0] = @ProgramFilesDir & "\" & $browser & "\" & $exe
    $paths[1] = @ProgramFilesDir & " (x86)\" & $browser & "\" & $exe
    $paths[2] = @LocalAppDataDir & "\Programs\" & $browser & "\" & $exe
    $paths[3] = @LocalAppDataDir & "\" & $browser & "\Application\" & $exe
    $paths[4] = @AppDataDir & "\" & $browser & "\Application\" & $exe
    
    ; Paths específicos por navegador
    Switch $browser
        Case "Chrome"
            $paths[5] = @ProgramFilesDir & "\Google\Chrome\Application\" & $exe
        Case "Edge"
            $paths[5] = @ProgramFilesDir & "\Microsoft\Edge\Application\" & $exe
        Case "Brave"
            $paths[5] = @LocalAppDataDir & "\BraveSoftware\Brave-Browser\Application\" & $exe
    EndSwitch
    
    Return $paths
EndFunc

Func BuscarEnRegistro($browser)
    Local $regPaths = ["HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\", _
                      "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\"]
    
    Local $config = $NAVEGADORES_CONFIG($browser)
    Local $exe = $config("exe")
    
    For $regPath In $regPaths
        Local $path = RegRead($regPath & $exe, "")
        If Not @error And FileExists($path) Then
            Return $path
        EndIf
    Next
    
    Return ""
EndFunc

Func HabilitarDeshabilitarSeguridad()
    ; Obtener el navegador seleccionado
    Local $navegador = GUICtrlRead($Combo1)
    If $navegador = "" Then
        GUICtrlSetData($Edit1, "Error: No hay navegador seleccionado")
        Return
    EndIf
    
    ; Verificar que el navegador está configurado
    If Not $NAVEGADORES_CONFIG.Exists($navegador) Then
        GUICtrlSetData($Edit1, "Error: Navegador no soportado")
        Return
    EndIf
    
    Local $config = $NAVEGADORES_CONFIG($navegador)
    Local $rutaNavegador = $browserPaths($navegador)
    Local $carpetaTemporal = @TempDir & "\" & $config("tempFolder")
    
    ; Verificar que el navegador existe
    If Not FileExists($rutaNavegador) Then
        GUICtrlSetData($Edit1, "Error: No se encontró el ejecutable del navegador")
        Return
    EndIf
    
    ; Crear carpeta temporal si no existe
    If Not FileExists($carpetaTemporal) Then
        DirCreate($carpetaTemporal)
    EndIf
    
    ; Construir comando según el tipo de navegador
    Local $comando = ""
    Switch $navegador
        Case "Firefox Developer"
            ; Configuración especial para Firefox Developer
            $comando = '"' & $rutaNavegador & '" -no-remote -profile "' & $carpetaTemporal & '"'
            ConfigurarFirefox($carpetaTemporal)
        Case Else
            ; Configuración para navegadores basados en Chromium
            $comando = '"' & $rutaNavegador & '" --disable-web-security --user-data-dir="' & $carpetaTemporal & '"'
    EndSwitch
    
    ; Ejecutar el navegador
    Local $pid = Run($comando, "", @SW_SHOW)
    If @error Then
        GUICtrlSetData($Edit1, "Error al ejecutar el navegador")
        Return
    EndIf
    
    ; Guardar configuración
    GuardarConfiguracion($navegador, $rutaNavegador)
    
    GUICtrlSetData($Edit1, "Navegador iniciado con seguridad CORS deshabilitada" & @CRLF & _
                          "Ruta: " & $rutaNavegador & @CRLF & _
                          "Perfil temporal: " & $carpetaTemporal)
EndFunc

Func ConfigurarFirefox($carpetaTemporal)
    ; Crear archivo de preferencias para Firefox
    Local $prefsFile = $carpetaTemporal & "\prefs.js"
    Local $prefsContent = ""
    
    ; Configuraciones de seguridad
    $prefsContent &= 'user_pref("security.fileuri.strict_origin_policy", false);' & @CRLF
    $prefsContent &= 'user_pref("security.mixed_content.block_active_content", false);' & @CRLF
    $prefsContent &= 'user_pref("network.http.referer.XOriginPolicy", 0);' & @CRLF
    $prefsContent &= 'user_pref("dom.disable_open_during_load", false);' & @CRLF
    
    ; Configuraciones adicionales para mejor compatibilidad
    $prefsContent &= 'user_pref("privacy.file_unique_origin", false);' & @CRLF
    $prefsContent &= 'user_pref("security.mixed_content.block_display_content", false);' & @CRLF
    $prefsContent &= 'user_pref("security.csp.enable", false);' & @CRLF
    
    ; Escribir archivo de preferencias
    FileWrite($prefsFile, $prefsContent)
EndFunc

Func GuardarConfiguracion($navegador, $ruta)
    ; Guardar en el archivo INI
    IniWrite($iniFile, "Navegadores", $navegador, $ruta)
    
    ; Guardar última configuración usada
    IniWrite($iniFile, "UltimaConfig", "Navegador", $navegador)
    IniWrite($iniFile, "UltimaConfig", "Fecha", _NowCalc())
EndFunc

Func TestCORS()
    GUICtrlSetData($ProgressBar, 0)
    GUICtrlSetData($Edit1, "Iniciando prueba CORS...")
    
    ; URLs de prueba
    Local $testUrls = [ _
        "https://cors-test.appspot.com/test", _
        "https://api.github.com", _
        "https://api.example.com/test" _
    ]
    
    Local $resultados = ""
    Local $total = UBound($testUrls)
    
    For $i = 0 To $total - 1
        Local $url = $testUrls[$i]
        GUICtrlSetData($ProgressBar, ($i + 1) * 100 / $total)
        
        ; Crear archivo temporal para la respuesta
        Local $tempFile = @TempDir & "\cors_test_" & Random(1000, 9999, 1) & ".tmp"
        
        ; Intentar descargar usando InetGet
        Local $hDownload = InetGet($url, $tempFile, $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
        
        ; Esperar a que termine la descarga (máximo 10 segundos)
        Local $timeout = TimerInit()
        While InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE) = False
            If TimerDiff($timeout) > 10000 Then ; 10 segundos timeout
                InetClose($hDownload)
                FileDelete($tempFile)
                $resultados &= "❌ Timeout al acceder a " & $url & @CRLF
                ContinueLoop 2
            EndIf
            Sleep(100)
        WEnd
        
        ; Verificar el resultado
        Local $iError = InetGetInfo($hDownload, $INET_DOWNLOADERROR)
        InetClose($hDownload)
        
        If $iError Then
            $resultados &= "❌ Error al acceder a " & $url & " (Error: " & $iError & ")" & @CRLF
        Else
            $resultados &= "✅ Acceso exitoso a " & $url & @CRLF
        EndIf
        
        ; Limpiar archivo temporal
        FileDelete($tempFile)
        
        Sleep(500) ; Pequeña pausa entre pruebas
    Next
    
    GUICtrlSetData($ProgressBar, 100)
    GUICtrlSetData($Edit1, "Resultados de la prueba CORS:" & @CRLF & $resultados)
EndFunc

Func MostrarCreditos()
    Local $creditos = "No Cors " & $VERSION & @CRLF & _
                     "-------------------" & @CRLF & _
                     "Desarrollado por Martin" & @CRLF & _
                     "Mejorado por Deepseek AI" & @CRLF & _
                     "Asistente: Claude 3.5 Sonnet" & @CRLF & _
                     "Última actualización: " & @YEAR & "-" & @MON & "-" & @MDAY & @CRLF & _
                     "-------------------" & @CRLF & _
                     "Navegadores soportados:" & @CRLF
    
    For $browser In $NAVEGADORES_CONFIG.Keys
        $creditos &= "• " & $browser & @CRLF
    Next
    
    MsgBox($MB_ICONINFORMATION, "Acerca de", $creditos)
EndFunc