echo off
REM ---- retrieve password from vault and set as variable 'pw01'
for /f "tokens=*" %%a in ('C:\"Program Files (x86)"\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe GetPassword /p "AppDescs.AppID=App01" /p "Query=Safe=Oracle;Folder=Root;Object=<object-name>" /p "RequiredProps=Address,UserName" /o Password') do set pw01=%%a

REM ---- retrieve username from vault and set as variable 'username01'
for /f "tokens=*" %%b in ('C:\"Program Files (x86)"\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe GetPassword /p "AppDescs.AppID=App01" /p "Query=Safe=Oracle;Folder=Root;Object=<object-name>" /p "RequiredProps=Address,UserName" /o passprops.username') do set username01=%%b

REM ---- retrieve address01 from vault and set as variable 'address01'
for /f "tokens=*" %%c in ('C:\"Program Files (x86)"\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe GetPassword /p "AppDescs.AppID=App01" /p "Query=Safe=Oracle;Folder=Root;Object=<object-name>" /p "RequiredProps=Address,UserName" /o passprops.address') do set address01=%%c

REM ---- retrieve database from vault and set as variable 'db01'
for /f "tokens=*" %%d in ('C:\"Program Files (x86)"\CyberArk\ApplicationPasswordSdk\CLIPasswordSDK.exe GetPassword /p "AppDescs.AppID=App01" /p "Query=Safe=Oracle;Folder=Root;Object=<object-name>" /p "RequiredProps=Address,UserName,database" /o passprops.database') do set db01=%%d
echo %database01%


sqlplus "%username01%/%pw01%@%address01%/%db01%"

pause
