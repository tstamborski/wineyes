nasm -f win32 wineyes.asm
gorc res.rc
golink wineyes.obj res.res kernel32.dll user32.dll gdi32.dll
pause

