#######################################################################
# Script_Problemas_Base_Archivo_Unico                                 #
# Script Base para la ejecución de archivos con el simulador MARS     #
# Fundamentos de Estructuras de Computadores                          #
# Alejandro Muñoz Del Álamo                                           #
# Version 2.0 05/05/2017                                              #
#######################################################################


#######################################################################
# Archivos requeridos para el correcto funcionamiento de este script: #
#######################################################################
#                          functions.ps1                              #
#                          config.ini                                 #
#######################################################################


#######################################################################
#                               Prólogo                               #
#   Importamos la información almacenada en los ficheros requeridos   #
#######################################################################


# Prolog 0: Importamos las funciones del archivo user_functions.ps1 

# El operador . es usado como script include
# $PSScriptRoot es la ruta donde se encuentra el script actual.
# 

. "$PSScriptRoot\functions.ps1"

# Prolog 1: Importamos las variables del archivo de configuración config.ini

# Utilizamos la función Get-IniContent declarada en user-functions.ps1 
# para almacenar todas las variables en una matriz llamada $config_vars

$config_vars =  Get-IniContent ("$PSScriptRoot\config.ini")
#$commands =  Get-IniContent ("$PSScriptRoot\command.ini")

#######################################################################
#                       Fin del Prólogo                               #
#   Ahora podemos acceder sin problemas a las variables del archivo   #
#                de configuración config.ini                          #
#######################################################################

# Paso 1: Recibimos por parámetro el nombre del archivo que se desea ejecutar

#Param ([string]$archivo) # Nota: Debe ser el nombre del archivo del alumno con extensión

# LINEA PARA PROBAR CODIGO#
$dir_desc =  $config_vars["Locations"]["dir_desc"]

foreach ($item in ls $dir_desc)
{
   $archivo = $item.ToString()
   $extension = $archivo.split(".")
   if ($extension[1] -eq "asm")
   {

# Paso 2: Obtenemos la ruta absoluta del archivo que se desea ejecutar
        $ruta_archivo = [string]::Concat($config_vars["Locations"]["dir_desc"],$archivo)
        $archivo

# Paso 3: Obtenemos la ruta en la que guardaremos el resultado de la ejecución del archivo
        $nombre = $archivo.split(($config_vars["Variables"]["separator"]))
        $ruta_resultado = [string]::Concat($config_vars["Locations"]["dir_res"], "\",$nombre[0],"_",$nombre[4])
    

# LINEA DE PRUEBA
#$ruta_resultado

# Paso 4: Ejecutamos el simulador MARS con la configuración requerida por el problema 

#######################################################################
#                     EJEMPLO DE CONFIGURACIÓN                        #
#######################################################################
#                   Ejemplo con un archivo único                      #
#    Utilizar este modo cuando el ejercicio sea un archivo único      #
#######################################################################


# EJEMPLO DE CONFIGURACIÓN: MODO DE EJECUCIÓN ARCHIVO ÚNICO
# Ejemplo con un archivo único: Llamada al problema 01
# Utilizar este modo cuando el ejercicio sea un archivo único

        java -jar $config_vars["Locations"]["mars"] $config_vars["Mode"][$nombre[4]] $ruta_archivo  > $ruta_resultado

#######################################################################
#                        FIN DEL SCRIPT BASE                          #
#######################################################################
#              Fundamentos de Estructuras de Computadores             #
#        Alejandro Muñoz Del Álamo    Version 1.0 02/11/2016          #
#######################################################################


#######################################################################
#                        SCRIPT EXTENDIDO                             #
#######################################################################
#        Integración del resultado del ejercicio en un fichero CSV    #
#######################################################################


#-------Edición 16-03-2017-------#
# Modificación para introducir el resultado de un ejercicio a un fichero .csv

# Paso 1: Encontrar ruta del fichero de comparación
        $ruta_solucion = [string]::Concat($config_vars["Locations"]["dir_sol"], "\",  $nombre[4])

# Paso 2: Calcular puntuación ejercicio
        $puntuacion = [string]::Concat("max_",$nombre[4])

# LINEA DE PRUEBA
#$ruta_solucion
#$puntuacion

# Paso 3: Comprobación del resultado

        $hash_alumno = (Get-FileHash $ruta_resultado).hash
        $hash_solucion = (Get-FileHash $ruta_solucion).hash

# Paso 4: En función del resultado introducimos la puntuación máxima del ejercicio o la puntuación minima
        if($hash_alumno -eq $hash_solucion)
        {
            $correccion = $config_vars["Value"][$puntuacion]
        }
        else
        {
            $correccion = 0
        }

# Paso 5: Almacenamos en una variable el contenido de la siguiente tupla del fichero CSV
        $csv = $config_vars["Locations"]["csv"]
        $textoAGuardar = [String]::Concat($nombre[0],", ",$nombre[4],", ", $correccion)
        $textoAGuardar | Out-File -FilePath $csv -Append
    }
}