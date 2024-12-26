#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <INet.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>

; Configuración del archivo INI
Global $iniFile = @ScriptDir & "\navegadores.ini"

; Crear la ventana principal
$Form1 = GUICreate("No Cors 1.0", 400, 350)
GUISetFont(10, 400, 0, "Arial")

; Crear un menú "Acerca de"
Local $menuAyuda = GUICtrlCreateMenu("Ayuda")
Local $menuAcercaDe = GUICtrlCreateMenuItem("Acerca de", $menuAyuda)

; Crear un combo box para seleccionar el navegador
$Label1 = GUICtrlCreateLabel("Selecciona el navegador:", 20, 20, 200, 20)
$Combo1 = GUICtrlCreateCombo("", 20, 50, 200, 25, $CBS_DROPDOWNLIST)

; Crear un botón para habilitar/deshabilitar la seguridad
$Button1 = GUICtrlCreateButton("Habilitar/Deshabilitar Seguridad", 20, 100, 200, 30)

; Crear un botón para ejecutar el test de CORS
$Button2 = GUICtrlCreateButton("Test CORS", 20, 140, 200, 30)

; Crear un botón para reescanear navegadores instalados
$Button3 = GUICtrlCreateButton("Reescanear Navegadores", 20, 180, 200, 30)

; Crear un campo de texto para mostrar el estado
$Edit1 = GUICtrlCreateEdit("", 20, 230, 360, 100, $ES_READONLY)

; Mostrar la ventana
GUISetState(@SW_SHOW)

; Inicializar la lista de navegadores
InicializarNavegadores()

; Bucle principal de la GUI
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
        Case $menuAcercaDe
            MostrarCreditos()
    EndSwitch
WEnd

; Función para inicializar la lista de navegadores
Func InicializarNavegadores()
    ; Limpiar el combo box antes de agregar los navegadores
    GUICtrlSetData($Combo1, "") ; Limpiar el combo box

    Local $navegadoresInstalados = ""

    ; Verificar qué navegadores están instalados
    If FileExists(@ProgramFilesDir & "\Google\Chrome\Application\chrome.exe") Then
        $navegadoresInstalados &= "Chrome|"
    EndIf

    ; Verificar Edge en varias rutas comunes
    Local $edgePaths[2] = [ _
        @ProgramFilesDir & "\Microsoft\Edge\Application\msedge.exe", _ ; Ruta de 64 bits
        @ProgramFilesDir & " (x86)\Microsoft\Edge\Application\msedge.exe" _ ; Ruta de 32 bits
    ]

    Local $edgeInstalado = False
    For $path In $edgePaths
        If FileExists($path) Then
            $navegadoresInstalados &= "Edge|"
            $edgeInstalado = True
            ExitLoop
        EndIf
    Next

    ; Verificar Opera en varias rutas comunes
    Local $operaPaths[2] = [ _
        @ProgramFilesDir & "\Opera\launcher.exe", _ ; Ruta estándar
        @LocalAppDataDir & "\Programs\Opera\opera.exe" _ ; Ruta personalizada
    ]

    Local $operaInstalado = False
    For $path In $operaPaths
        If FileExists($path) Then
            $navegadoresInstalados &= "Opera|"
            $operaInstalado = True
            ExitLoop
        EndIf
    Next

    ; Verificar Brave en la ruta personalizada
    Local $bravePath = @LocalAppDataDir & "\BraveSoftware\Brave-Browser\Application\brave.exe"
    If FileExists($bravePath) Then
        $navegadoresInstalados &= "Brave|"
    EndIf

    ; Verificar Vivaldi en la ruta personalizada
    Local $vivaldiPath = @LocalAppDataDir & "\Vivaldi\Application\vivaldi.exe"
    If FileExists($vivaldiPath) Then
        $navegadoresInstalados &= "Vivaldi|"
    EndIf

    ; Verificar Firefox en varias rutas comunes
    Local $firefoxPaths[3] = [ _
        @ProgramFilesDir & "\Mozilla Firefox\firefox.exe", _ ; Ruta de 64 bits
        @ProgramFilesDir & " (x86)\Mozilla Firefox\firefox.exe", _ ; Ruta de 32 bits
        "C:\Program Files\Mozilla Firefox\firefox.exe" _ ; Ruta alternativa
    ]

    Local $firefoxInstalado = False
    For $path In $firefoxPaths
        If FileExists($path) Then
            $navegadoresInstalados &= "Firefox|"
            $firefoxInstalado = True
            ExitLoop
        EndIf
    Next

    ; Configurar el combo box con los navegadores instalados
    GUICtrlSetData($Combo1, StringTrimRight($navegadoresInstalados, 1), "Chrome")
EndFunc

Func HabilitarDeshabilitarSeguridad()
    ; Obtener el navegador seleccionado
    Local $navegador = GUICtrlRead($Combo1)
    Local $comando = ""
    Local $rutaNavegador = ""
    Local $carpetaTemporal = ""

    ; Definir el comando y la ruta del navegador
    Switch $navegador
        Case "Chrome"
            $rutaNavegador = @ProgramFilesDir & "\Google\Chrome\Application\chrome.exe"
            $carpetaTemporal = @TempDir & "\ChromeTemp"
            $comando = '"' & $rutaNavegador & '" --disable-web-security --user-data-dir="' & $carpetaTemporal & '"'
        Case "Edge"
            ; Verificar Edge en varias rutas comunes
            Local $edgePaths[2] = [ _
                @ProgramFilesDir & "\Microsoft\Edge\Application\msedge.exe", _ ; Ruta de 64 bits
                @ProgramFilesDir & " (x86)\Microsoft\Edge\Application\msedge.exe" _ ; Ruta de 32 bits
            ]

            Local $edgeEncontrado = False
            For $path In $edgePaths
                If FileExists($path) Then
                    $rutaNavegador = $path
                    $edgeEncontrado = True
                    ExitLoop
                EndIf
            Next

            If Not $edgeEncontrado Then
                GUICtrlSetData($Edit1, "Error: No se encontró el ejecutable de Edge en ninguna de las rutas comunes.")
                Return
            EndIf

            $carpetaTemporal = @TempDir & "\EdgeTemp"
            $comando = '"' & $rutaNavegador & '" --disable-web-security --user-data-dir="' & $carpetaTemporal & '"'
        Case "Opera"
            ; Verificar Opera en varias rutas comunes
            Local $operaPaths[2] = [ _
                @ProgramFilesDir & "\Opera\launcher.exe", _ ; Ruta estándar
                @LocalAppDataDir & "\Programs\Opera\opera.exe" _ ; Ruta personalizada
            ]

            Local $operaEncontrado = False
            For $path In $operaPaths
                If FileExists($path) Then
                    $rutaNavegador = $path
                    $operaEncontrado = True
                    ExitLoop
                EndIf
            Next

            If Not $operaEncontrado Then
                GUICtrlSetData($Edit1, "Error: No se encontró el ejecutable de Opera en ninguna de las rutas comunes.")
                Return
            EndIf

            $carpetaTemporal = @TempDir & "\OperaTemp"
            $comando = '"' & $rutaNavegador & '" --disable-web-security --user-data-dir="' & $carpetaTemporal & '"'
        Case "Brave"
            $rutaNavegador = @LocalAppDataDir & "\BraveSoftware\Brave-Browser\Application\brave.exe"
            If Not FileExists($rutaNavegador) Then
                GUICtrlSetData($Edit1, "Error: No se encontró el ejecutable de Brave en la ruta: " & $rutaNavegador)
                Return
            EndIf
            $carpetaTemporal = @TempDir & "\BraveTemp"
            $comando = '"' & $rutaNavegador & '" --disable-web-security --user-data-dir="' & $carpetaTemporal & '"'
        Case "Vivaldi"
            $rutaNavegador = @LocalAppDataDir & "\Vivaldi\Application\vivaldi.exe"
            If Not FileExists($rutaNavegador) Then
                GUICtrlSetData($Edit1, "Error: No se encontró el ejecutable de Vivaldi en la ruta: " & $rutaNavegador)
                Return
            EndIf
            $carpetaTemporal = @TempDir & "\VivaldiTemp"
            $comando = '"' & $rutaNavegador & '" --disable-web-security --user-data-dir="' & $carpetaTemporal & '"'
        Case "Firefox"
            ; Verificar Firefox en varias rutas comunes
            Local $firefoxPaths[3] = [ _
                @ProgramFilesDir & "\Mozilla Firefox\firefox.exe", _ ; Ruta de 64 bits
                @ProgramFilesDir & " (x86)\Mozilla Firefox\firefox.exe", _ ; Ruta de 32 bits
                "C:\Program Files\Mozilla Firefox\firefox.exe" _ ; Ruta alternativa
            ]

            Local $firefoxEncontrado = False
            For $path In $firefoxPaths
                If FileExists($path) Then
                    $rutaNavegador = $path
                    $firefoxEncontrado = True
                    ExitLoop
                EndIf
            Next

            If Not $firefoxEncontrado Then
                GUICtrlSetData($Edit1, "Error: No se encontró el ejecutable de Firefox en ninguna de las rutas comunes.")
                Return
            EndIf

            $carpetaTemporal = @TempDir & "\FirefoxTemp"

            ; Crear un perfil temporal si no existe
            If Not FileExists($carpetaTemporal) Then
                DirCreate($carpetaTemporal)
            EndIf

            ; Ejecutar Firefox con el perfil temporal
            $comando = '"' & $rutaNavegador & '" -no-remote -profile "' & $carpetaTemporal & '"'

            ; Modificar las preferencias de seguridad en el perfil temporal
            Local $prefsFile = $carpetaTemporal & "\prefs.js"
            Local $prefsContent = FileRead($prefsFile)
            $prefsContent &= @CRLF & 'user_pref("security.fileuri.strict_origin_policy", false);'
            $prefsContent &= @CRLF & 'user_pref("security.mixed_content.block_active_content", false);'
            $prefsContent &= @CRLF & 'user_pref("network.http.referer.XOriginPolicy", 0);'
            $prefsContent &= @CRLF & 'user_pref("dom.disable_open_during_load", false);'
            FileWrite($prefsFile, $prefsContent)
    EndSwitch

    ; Verificar si el navegador existe en la ruta especificada
    If Not FileExists($rutaNavegador) Then
        GUICtrlSetData($Edit1, "Error: No se encontró el ejecutable de " & $navegador & " en la ruta: " & $rutaNavegador)
        Return
    EndIf

    ; Ejecutar el comando
    Local $pid = Run($comando)
    If @error Then
        GUICtrlSetData($Edit1, "Error: No se pudo ejecutar el comando para " & $navegador & @CRLF & _
            "Comando: " & $comando & @CRLF & _
            "Código de error: " & @error)
    Else
        GUICtrlSetData($Edit1, "Seguridad deshabilitada para " & $navegador & @CRLF & "Comando ejecutado: " & $comando)
        ; Guardar el estado en el archivo INI
        IniWrite($iniFile, "Estado", $navegador, "Deshabilitado")
    EndIf
EndFunc

; Función para ejecutar el test de CORS
Func TestCORS()
    ; URL de prueba
    Local $url = "https://httpbin.org/get"

    ; Realizar la solicitud HTTP
    Local $response = INetGet($url, @TempDir & "\cors_test.txt", 1, 1)

    ; Verificar si la solicitud fue exitosa
    If $response Then
        ; Leer la respuesta del archivo temporal
        Local $file = FileOpen(@TempDir & "\cors_test.txt", 0)
        If $file = -1 Then
            GUICtrlSetData($Edit1, "Error: No se pudo abrir el archivo de respuesta.")
            Return
        EndIf
        Local $content = FileRead($file)
        FileClose($file)

        ; Parsear y formatear el JSON manualmente
        Local $formattedContent = ParsearYFormatearJSON($content)

        ; Mostrar el resultado
        GUICtrlSetData($Edit1, "Resultado del Test" & @CRLF & "CORS: Deshabilitado" & @CRLF & $formattedContent)
    Else
        GUICtrlSetData($Edit1, "CORS está habilitado. No se pudo acceder al recurso.")
    EndIf
EndFunc

; Función para parsear y formatear el JSON manualmente
Func ParsearYFormatearJSON($json)
    ; Extraer los campos relevantes usando expresiones regulares
    Local $cacheControl = StringRegExp($json, '"Cache-Control":\s*"([^"]+)"', 1)
    Local $host = StringRegExp($json, '"Host":\s*"([^"]+)"', 1)
    Local $userAgent = StringRegExp($json, '"User-Agent":\s*"([^"]+)"', 1)
    Local $traceId = StringRegExp($json, '"X-Amzn-Trace-Id":\s*"([^"]+)"', 1)
    Local $origin = StringRegExp($json, '"origin":\s*"([^"]+)"', 1)
    Local $url = StringRegExp($json, '"url":\s*"([^"]+)"', 1)

    ; Verificar si se encontraron los valores
    $cacheControl = (UBound($cacheControl) > 0) ? $cacheControl[0] : "N/A"
    $host = (UBound($host) > 0) ? $host[0] : "N/A"
    $userAgent = (UBound($userAgent) > 0) ? $userAgent[0] : "N/A"
    $traceId = (UBound($traceId) > 0) ? $traceId[0] : "N/A"
    $origin = (UBound($origin) > 0) ? $origin[0] : "N/A"
    $url = (UBound($url) > 0) ? $url[0] : "N/A"

    ; Formatear la salida
    Local $formattedContent = _
        "Cache-Control: " & $cacheControl & @CRLF & _
        "Host: " & $host & @CRLF & _
        "User-Agent: " & $userAgent & @CRLF & _
        "X-Amzn-Trace-Id: " & $traceId & @CRLF & _
        "Origin: " & $origin & @CRLF & _
        "URL: " & $url

    Return $formattedContent
EndFunc

; Función para mostrar los créditos
Func MostrarCreditos()
    Local $nombreApp = "No CORS"
    Local $autor = "Martin Alejandro Oviedo"
    Local $colaborador = "DeepSeek-V3"
    Local $version = "1.0"
    Local $anio = "2023"
    Local $desarrolladoPara = "NDAWEB Argentina"

    Local $mensaje = _
        "Nombre de la aplicación: " & $nombreApp & @CRLF & _
        "Desarrollado por: " & $autor & @CRLF & _
        "Colaboración: " & $colaborador & @CRLF & _
        "Versión: " & $version & @CRLF & _
        "Año: " & $anio & @CRLF & _
        "Desarrollado para: " & $desarrolladoPara

    MsgBox($MB_OK + $MB_ICONINFORMATION, "Acerca de", $mensaje)
EndFunc