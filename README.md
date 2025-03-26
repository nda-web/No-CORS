# No CORS Script

![AutoIt](https://img.shields.io/badge/AutoIt-Script-blue) ![License](https://img.shields.io/badge/License-MIT-green) ![Version](https://img.shields.io/badge/Version-1.1-orange)

## Descripción

El script **No CORS** es una herramienta diseñada para facilitar pruebas de desarrollo al **deshabilitar la seguridad de los navegadores**. Esto es especialmente útil para trabajar con **CORS (Cross-Origin Resource Sharing)**. El script incluye funciones para **probar CORS**, crear/restaurar backups de configuración, y un sistema mejorado de detección de navegadores.

## Características

- **Deshabilitar seguridad**: Ejecuta el navegador seleccionado con la seguridad deshabilitada
- **Test CORS**: Realiza pruebas automáticas para verificar el estado de CORS
- **Sistema de Backup**: Permite crear y restaurar backups de la configuración
- **Reescanear navegadores**: Detecta automáticamente los navegadores instalados
- **Interfaz gráfica mejorada**: Diseño intuitivo con barra de progreso y logs detallados
- **Soporte multi-navegador**: Compatible con una amplia variedad de navegadores

## Navegadores compatibles

- Google Chrome
- Microsoft Edge
- Opera
- Brave
- Vivaldi
- Firefox Developer Edition
- Waterfox
- Pale Moon
- Chromium
- Iron

## Requisitos

- **Sistema operativo**: Windows
- **AutoIt**: Versión 3 o superior
- **Espacio en disco**: Mínimo 50MB para perfiles temporales

## Instalación

1. Clona este repositorio o descarga el archivo `.au3`
2. Instala [AutoIt](https://www.autoitscript.com/site/autoit/downloads/)
3. Ejecuta el script `nocors.au3`

## Uso

1. Abre el script
2. Selecciona el navegador deseado
3. Opciones disponibles:
   - **Habilitar/Deshabilitar Seguridad**: Inicia el navegador sin restricciones CORS
   - **Test CORS**: Verifica el estado de CORS con múltiples endpoints
   - **Reescanear Navegadores**: Actualiza la lista de navegadores detectados
   - **Backup/Restaurar**: Gestiona la configuración de los navegadores

## Características nuevas en v1.1

- Soporte para Firefox Developer Edition
- Sistema de backup y restauración
- Detección mejorada de navegadores
- Interfaz actualizada con más información
- Test CORS con timeout y manejo de errores
- Limpieza automática de archivos temporales

## Créditos

- **Desarrollador**: Martin
- **Mejoras IA**: Deepseek AI
- **Asistente**: Claude 3.5 Sonnet
- **Versión**: 1.1
- **Año**: 2024
- **Desarrollado para**: NDAWEB Argentina

## Licencia

Este proyecto está bajo la licencia **MIT**. Para más detalles, consulta el archivo [LICENSE](LICENSE).
