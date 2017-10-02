$host.ui.RawUI.WindowTitle = "DenyTOR - Server Protection"
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    cls
    Write-Host "╔═══════════════════════════════════════════════════════════════════════════╗";
    Write-Host "║ " -nonewline; Write-Host  "DenyTOR - Server Protection                              [Versión]: 1.3.0" -f "red" -nonewline; " ║" -f "white";
    Write-Host "╠═══════════════════════════════════════════════════════════════════════════╣";
    Write-Host "║ " -nonewline; Write-Host "[Web]: https://blogs.itpro.es/DaniAlonso   |   [Twitter]: @_DaniAlonso" -f "yellow" -nonewline; "    ║" -f "white";
    Write-Host "╠═══════════════════════════════════════════════════════════════════════════╣";
    Write-Host "║                                                                           ║";
    Write-Host "║                                                                           ║";
    Write-Host "║       _____     _____   ___   _  __   __  _______    ____    _____        ║";
    Write-Host "║      |  __ \   |  ___| |   \ | | \ \ / / |__   __|  / __ \   __   __      ║";
    Write-Host "║      | |  \ \  | |__   | |\ \| |  \   /     | |    / /  \ \  ______       ║";
    Write-Host "║      | |   | | |  __|  | | \   |   | |      | |    | |  | |  __  __       ║";
    Write-Host "║      | |__/ /  | |___  | |  \  |   | |      | |    \ \__/ /  __   __      ║";
    Write-Host "║      |_____/   |_____| |_|   \_|   |_|      |_|     \____/   __    __     ║";
    Write-Host "║                                                                           ║";
    Write-Host "║                                                                           ║";
    Write-Host "╠═══════════════════════════════════════════════════════════════════════════╣";
    Write-Host "║ " -nonewline; Write-Host "                                                         By DaniAlonso" -f "yellow" -nonewline; "    ║" -f "white";
    Write-Host "╚═══════════════════════════════════════════════════════════════════════════╝" 
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup("Se necesitan derechos de Administrador para ejecutar DenyTOR!`nPor favor, ejecuta DenyTOR como Administrador!",0,"Oops! No tienes permisos...",0x0)
    Break
}

function firewall ($InputFile = "DenyTOR.tmp", $RuleName, $ProfileType = "any", $InterfaceType = "any", [Switch] $DeleteOnly){

$file = get-item $InputFile -ErrorAction SilentlyContinue 
if (-not $? -and -not $DeleteOnly) { "`nNo se puede encontrar $InputFile, por favor, ejecuta la opción [1] de DenyTor.ps1.`n" ; exit } 
if (-not $rulename) { $rulename = $file.basename } 

$description = "Regla creada por DenyTOR el $(get-date). No edites la regla manualmente, se sobreescribirá cuando ejecutes DenyTOR nuevamente."

Write-Host "`nEliminando las reglas de protección DenyTOR: '$rulename-#*' ................................."  -nonewline;
Write-Host " [ OK ]`n" -foregroundcolor "green"
$currentrules = netsh.exe advfirewall firewall show rule name=all | select-string '^[Rule Name|Regelname|Nome|Nombre de regla]+:\s+(.+$)' | foreach { $_.matches[0].groups[1].value } 
if ($currentrules.count -lt 3) {"`nProblema al obtener una lista de reglas de firewall actuales, saliendo...`n" ; exit } 
# Note: Si esto falla, habrá que añadir un nuevo idioma 2 líneas más arriba. Contactar con dani@itpro.es para más información.
$currentrules | foreach { if ($_ -like "$rulename-#*"){ netsh.exe advfirewall firewall delete rule name="$_" | out-null } } 

if ($deleteonly -and $rulename) {Write-Host "Protección DenyTOR deshabilitada .........................................................."  -nonewline;
} 
if ($deleteonly) {Write-Host " [ OK ]`n" -f "green"; return } 

$ranges = get-content $file | where {($_.trim().length -ne 0) -and ($_ -match '^[0-9a-f]{1,4}[\.\:]')} 
if (-not $?) { "`nCNo se pudo analizar $file, saliendo...`n" ; exit } 
$linecount = $ranges.count
if ($linecount -eq 0) { "`nNinguna dirección IP para bloquear, saliendo...`n" ; exit } 

$MaxRangesPerRule = 100

$i = 1
$start = 1
$end = $maxrangesperrule
do {
    $icount = $i.tostring().padleft(3,"0")  
    
    if ($end -gt $linecount) { $end = $linecount } 
    $textranges = [System.String]::Join(",",$($ranges[$($start - 1)..$($end - 1)])) 

    "`nCreando regla de firewall de entreda con el nombre '$rulename-#$icount' para el rango IP $start - $end" 
    netsh.exe advfirewall firewall add rule name="$rulename-#$icount" dir=in action=block localip=any remoteip="$textranges" description="$description" profile="$profiletype" interfacetype="$interfacetype"
    if (-not $?) {Write-Host "`nError al crear la regla de entrada '$rulename-#$icount', continuando de todos modos............." -nonewline;Write-Host " [ FALLO ]`n" -f "red" -nonewline}else{Write-Host "..........................................................................................." -nonewline;Write-Host " [ OK ]`n" -f "green" -nonewline}
    
    "`nCreando regla de firewall de salida con el nombre '$rulename-#$icount' para el rango IP $start - $end" 
    netsh.exe advfirewall firewall add rule name="$rulename-#$icount" dir=out action=block localip=any remoteip="$textranges" description="$description" profile="$profiletype" interfacetype="$interfacetype"
    if (-not $?) {Write-Host "`nError al crear la regla de salida '$rulename-#$icount', continuando de todos modos.............." -nonewline;Write-Host " [ FALLO ]`n" -f "red" -nonewline}else{Write-Host "..........................................................................................." -nonewline;Write-Host " [ OK ]`n" -f "green" -nonewline}
    
    $i++
    $start += $maxrangesperrule
    $end += $maxrangesperrule
} while ($start -le $linecount)
    Remove-Item "DenyTOR.tmp" -Force
}
function getNodeList
{
    cls

    Write-Host "`nObteniendo la lista de nodos de salida TOR ................................................" -nonewline;
    $source = "http://atresmedia.azurewebsites.net/file.php"
    $destination = "DenyTOR.tmp"
                

    Invoke-WebRequest $source -OutFile $destination
    $filehidden = get-item $destination
    $filehidden.attributes = 'Temporary'
    Write-Host " [ OK ]`n" -f "green"
}
function Show-Menu
{
     param (
           [string]$Title = 'DENYTOR - SERVER PROTECTION'
     )
     cls

     Write-Host "╔═════════════════════════════════════════════════════════════════════════════════╗";
     Write-Host "║" -nonewline; Write-Host  "                           $Title" -f "red" -nonewline; "                           ║" -f "white";
     Write-Host "╠═════════════════════════════════════════════════════════════════════════════════╣";
     Write-Host "║ " -nonewline; Write-Host "[1] Establecer las reglas y activar protección global. (Recomendado)" -f "yellow" -nonewline; "            ║" -f "white";
     Write-Host "║ " -nonewline; Write-Host "[2] Establecer las reglas y activar protección sólo en redes públicas." -f "yellow" -nonewline; "          ║" -f "white";
     Write-Host "║ " -nonewline; Write-Host "[3] Establecer las reglas y activar protección sólo en redes inalámbricas." -f "yellow" -nonewline; "      ║" -f "white";
     Write-Host "║ " -nonewline; Write-Host "[4] Eliminar las reglas de protección." -f "yellow" -nonewline; "                                          ║" -f "white";
     Write-Host "╠═════════════════════════════════════════════════════════════════════════════════╣";
     Write-Host "║ " -nonewline; Write-Host "[W] Pulsa 'W' para abrir el 'Firewall de Windows con seguridad avanzada'." -f "yellow" -nonewline; "       ║" -f "white";
     Write-Host "║ " -nonewline; Write-Host "[?] Pulsa '?' para obtener información y ayuda." -f "yellow" -nonewline; "                                 ║" -f "white";
     Write-Host "║ " -nonewline; Write-Host "[Q] Pulsa 'Q' para salir." -f "yellow" -nonewline; "                                                       ║" -f "white";
     Write-Host "╚═════════════════════════════════════════════════════════════════════════════════╝" 
}
do
{
     Show-Menu
     $input = Read-Host "Por favor, elige una opción."
     switch ($input)
     {
           '1' {
                
                getNodeList
                Write-Host "Estableciendo las reglas de protección global ............................................." -nonewline; Write-Host " [ OK ]" -f "green"
                firewall
           } '2' {
                getNodeList
                Write-Host "Estableciendo las reglas de protección sólo para redes públicas ..........................." -nonewline; Write-Host " [ OK ]" -f "green"
                firewall -profiletype public
           } '3' {
                getNodeList
                Write-Host "Estableciendo las reglas de protección sólo para redes inalámbricas ......................." -nonewline; Write-Host " [ OK ]" -f "green"
                firewall -interfacetype wireless
           } '4' {
                cls
                firewall  -rulename DenyTOR -deleteonly
           } 'w' {
                cls
                wf.msc 
                
           } '?' {
                  cls
                     Write-Host "╔═════════════════════════════════════════════════════════════════════════════════╗";
                     Write-Host "║ " -nonewline; Write-Host "                         DENYTOR - INFORMACIÓN Y AYUDA" -f "red" -nonewline; "                          ║" -f "white"
                     Write-Host "╠═════════════════════════════════════════════════════════════════════════════════╣";
                     Write-Host "║ " -nonewline; Write-Host "DenyTOR es una herramienta ideada y desarrollada por Dani Alonso" -nonewline; "                ║" -f "white"
                     Write-Host "║ " -nonewline; Write-Host "Microsoft MVP, Experto en soluciones cloud, seguridad telemática empresarial y" -nonewline; "  ║" -f "white"
                     Write-Host "║ " -nonewline; Write-Host "perito judicial informático forense." -nonewline; "                                            ║" -f "white"
                     Write-Host "║                                                                                 ║";
                     Write-Host "║ " -nonewline; Write-Host "Website: https://blogs.itpro.es/DaniAlonso     Twitter: @_DaniAlonso" -nonewline; "            ║" -f "white"
                     Write-Host "╠═════════════════════════════════════════════════════════════════════════════════╣";
                     Write-Host "║ " -nonewline; Write-Host "Esta herramienta establece conexión con un servicio alojado en Microsoft" -f "yellow" -nonewline; "        ║" -f "white"
                     Write-Host "║ " -nonewline; Write-Host "Azure, que monitorizan en tiempo real la arquitectura de la red TOR. En el" -f "yellow" -nonewline; "      ║" -f "white"
                     Write-Host "║ " -nonewline; Write-Host "análisis identifica todos los nodos de salida generándo una lista completa," -f "yellow" -nonewline; "     ║" -f "white"
                     Write-Host "║ " -nonewline; Write-Host "la cual este script se encargará de importarla y procesarla desatendidamente." -f "yellow" -nonewline; "   ║" -f "white"
                     Write-Host "║                                                                                 ║";
                     Write-Host "║ " -nonewline; Write-Host "Una vez obtenida la lista de los nodos de la red TOR, el script creará reglas " -f "yellow" -nonewline; "  ║" -f "white"
                     Write-Host "║ " -nonewline; Write-Host "de entrada y salida en el firewall de Windows según nuestras necesidades. " -f "yellow" -nonewline; "      ║" -f "white"
                     Write-Host "║ " -nonewline; Write-Host "Podremos establecer la protección de nuestro servidor cuando se conecte a una" -f "yellow" -nonewline; "   ║" -f "white"
                     Write-Host "║ " -nonewline; Write-Host "red inalámbrica [3], pública [2], o en todas las redes [1]. Para una mayor" -f "yellow" -nonewline; "      ║" -f "white"
                     Write-Host "║ " -nonewline; Write-Host "protección, se recomienda la opción [1]. Puedes cambiar de opción en cualquier" -f "yellow" -nonewline; "  ║" -f "white"
                     Write-Host "║ " -nonewline; Write-Host "momento." -f "yellow" -nonewline; "                                                                        ║" -f "white"
                     Write-Host "║                                                                                 ║";
                     Write-Host "║ " -nonewline; Write-Host "Para observar los resultados, puedes abrir la herramienta 'Firewall de Windows" -f "yellow" -nonewline; "  ║" -f "white"
                     Write-Host "║ " -nonewline; Write-Host "con seguridad avanzada', y ver las reglas de entrada y salida." -f "yellow" -nonewline; "                  ║" -f "white"
                     Write-Host "║ " -nonewline; Write-Host "Ahí encontrarás las reglas DenyTOR-#00x, que albergan una serie de direcciones" -f "yellow" -nonewline; "  ║" -f "white"
                     Write-Host "║ " -nonewline; Write-Host "IP remotas correspondientes a los nodos de salida TOR." -f "yellow" -nonewline; "                          ║" -f "white"
                     Write-Host "║                                                                                 ║";
                     Write-Host "║ " -nonewline; Write-Host "No edites manualmente las reglas DenyTOR desde el Firewall de Windows. Se" -f "yellow" -nonewline; "       ║" -f "white"
                     Write-Host "║ " -nonewline; Write-Host "sobreescribirán cuando ejecutes nuevamente otra opción en DenyTOR." -f "yellow" -nonewline; "              ║" -f "white"
                     Write-Host "║                                                                                 ║";
                     Write-Host "║ " -nonewline; Write-Host "La opción [4] deshabilitará la protección TOR eliminando todas estas reglas." -f "yellow" -nonewline; "    ║" -f "white"
                     Write-Host "╠═════════════════════════════════════════════════════════════════════════════════╣";
                     Write-Host "║ " -nonewline; Write-Host "Pulsa 'ENTER' para salir de la ayuda." -f "yellow" -nonewline; "                                           ║" -f "white"
                     Write-Host "╚═════════════════════════════════════════════════════════════════════════════════╝"
           } 'q' {
                return
           }
     }
     pause
}
until ($input -eq 'q')