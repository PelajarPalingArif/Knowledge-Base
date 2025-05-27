@echo off

echo MYSQL DATABASE INITIATOR 


echo MYSQL VERSION : 



powershell -Command "Invoke-WebRequest 'https://registry.hub.docker.com/v2/repositories/library/mysql/tags?page_size=100' | Select-Object -ExpandProperty Content | ConvertFrom-Json | ForEach-Object { $_.results } | ForEach-Object { $_.name }"


SET /P version=">> Version : "
SET /P port=">> Port : "
SET /P database=">> Database : "
SET /P root_password=">> root Password : "
SET /P data_dir_path=">> Data Directory Path : "
SET /P config_file_path=">> Config File Path : "
SET /P container_name=">> Container Name : "


echo.
echo You entered:
echo Version          : %version%
echo Port             : %port%
echo Database         : %database%
echo Root Password    : %root_password%
echo Data Directory   : %data_dir_path%
echo Config File Path : %config_file_path%
echo Container Name   : %container_name%
echo.


REM Extract the directory from config_file_path to check/create folder
for %%F in ("%config_file_path%") do set config_dir=%%~dpF




REM Check Data Directory Path Exist, If Not Create
IF NOT EXIST "%data_dir_path%" (
	echo Creating Data Directory : %data_dir_path%
	mkdir %data_dir_path%
) ELSE (
	echo Data Directory Exists : %data_dir_path%
)

REM Check Config Files Exist, If Not Create
IF NOT EXIST "%config_dir%" (
	echo Creating Config File Directory : %config_file_path%
	mkdir "%config_dir%"
) ELSE (
	echo Config Directory Exists: %config_file_path%
)


REM Check if config file exists, create a basic one if missing
IF NOT EXIST "%config_file_path%" (
	echo Creating default MySQL config file : %config_file_path%
	(
		echo [mysqld]
		echo skip-name-resolve
		echo sql_mode=STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION
	) > "%config_file_path%"
) ELSE (
	echo Config File Exists : %config_file_path%
)


REM Changing %config_file_path% permission
icacls "%config_file_path%" /inheritance:r
icacls "%config_file_path%" /grant:r "Administrators:(R,W)"
icacls "%config_file_path%" /grant:r "SYSTEM:(R,W)"
icacls "%config_file_path%" /grant:r "Users:(R)"
icacls "%config_file_path%" /grant:r "Administrators:(F)"
icacls "%config_file_path%" /grant:r "SYSTEM:(F)"


REM Docker Run Command
docker run -d --name %container_name% -p %port%:3306 -e MYSQL_ROOT_PASSWORD=%root_password% -e MYSQL_DATABASE=%database% -v %data_dir_path%:/var/lib/mysql -v %config_file_path%:/etc/mysql/my.cnf:ro mysql:%version%



