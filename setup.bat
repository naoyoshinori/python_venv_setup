@echo off

:PARAM
set param=%~1
shift

if "%param%" == "" goto PARAM_END

if %param% == --main (
    rem Get main name
    set main_name=%~1
    shift
    goto PARAM
) else if %param% == --py (
    rem Get Python Version
    set python_version=%~1
    shift
    goto PARAM
) else if %param% == --env (
    rem Get Environment
    if "%~1" == "development" (
        set environment=%~1
        shift
        goto PARAM
    ) else if "%~1" == "production" (
        set environment=%~1
        shift
        goto PARAM
    ) else (
        echo The parameter env should be set to development or production.
        goto END
    )
) else (
    call :help
    goto END
)
:PARAM_END

rem Check setup_info.txt 
if exist setup_info.txt (
    echo ## Setup is already complete. ##
    type setup_info.txt
    goto END
)

echo ## Setup start. ##

rem Set the default main name.
if "%main_name%"=="" (
    set main_name=main
)

rem Set Python version.
if not "%python_version%"=="" (
    set python_version=-%python_version%
)

rem Set the default environment.
if "%environment%"=="" (
    set environment=production
)

rem Get dirname
for %%F in (%CD%) do set dirname=%%~nxF

rem Get date
set _date_=%DATE:/=%

rem Get time
set _time_=%TIME: =0%
set _time_=%_time_:~0,2%%_time_:~3,2%%_time_:~6,2%

rem Create venv path
if %environment%==production (
    set venv_path=%HOMEDRIVE%%HOMEPATH%\venv\%dirname%_%_date_%_%_time_%
) else (
    set venv_path=.\venv
)
echo venv_path=%venv_path%

rem Create Python venv
mkdir %venv_path%
py %python_version% -m venv %venv_path%

rem Craete activate.bat
echo start %venv_path%\Scripts\activate> activate.bat

rem Create %main_name%.bat
echo call %venv_path%\Scripts\activate> %main_name%.bat
echo py %main_name%.py>> %main_name%.bat

rem Create %main_name%.py
if not exist %main_name%.py (
    type nul > %main_name%.py
)

rem Install Python packages
if exist requirements.txt (
    call %venv_path%\Scripts\activate
    pip install -r requirements.txt
)

rem Record venv_path
echo venv_path=%venv_path%> setup_info.txt
echo main_name=%main_name%>> setup_info.txt
echo env=%environment%>> setup_info.txt

echo ## Setup is complete. ##

:END
pause
exit /b

:help
echo Usage:
echo   setup [options]
echo.
echo Example:
echo   setup --main main --py 3.10 --env development
echo.
echo Options:
echo   --main       Set the main name of the application.
echo                The default is to create main.py and main.bat.
echo   --py         Set Python version.
echo                The default is the installed version.
echo   --env        Set the environment to development or production.
echo                The default is production.
exit /b
