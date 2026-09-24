@echo off
REM Publica o perfil do GitHub. O trabalho de verdade esta no .ps1;
REM este arquivo so o chama sem esbarrar na politica de execucao.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0publicar-perfil.ps1" %*
