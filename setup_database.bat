@echo off
echo Setting up BookWeb database...

REM Check if SQL Server LocalDB is available
sqllocaldb info >nul 2>&1
if %errorlevel% neq 0 (
    echo SQL Server LocalDB is not installed or not in PATH.
    echo Please install SQL Server LocalDB first.
    pause
    exit /b 1
)

echo Starting LocalDB default instance...
sqllocaldb start "MSSQLLocalDB"

REM Wait a moment
timeout /t 3 /nobreak >nul

echo Creating BookWeb database...

REM Create a simple SQL script
echo IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'BookWeb') > create_db.sql
echo BEGIN >> create_db.sql
echo     CREATE DATABASE [BookWeb] >> create_db.sql
echo END >> create_db.sql
echo GO >> create_db.sql

REM Execute the script
sqlcmd -S "(localdb)\MSSQLLocalDB" -i create_db.sql

if %errorlevel% equ 0 (
    echo Database setup completed successfully!
    echo Database 'BookWeb' has been created.
) else (
    echo Database setup failed. Please check the error messages above.
)

REM Clean up
del create_db.sql

echo Setup complete. You can now run your application.
pause
