@echo off
cls
echo Protecting srcds from crashes...
echo If you want to close srcds and this script, close the srcds window and type Y depending on your language followed by Enter.
title srcds.com Watchdog
:srcds
echo (%time%) srcds started.

start /wait srcds.exe -console -game garrysmod -port 27015 -tickrate 100 +gamemode halorp +host_workshop_collection 2110188971 +map rp_mws_station_v0_8 +maxplayers 4


echo (%time%) WARNING: srcds closed or crashed, restarting.
goto srcds 
pause