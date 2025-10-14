# PowerShell script to set up the BookWeb database
# Run this script as Administrator

Write-Host "Setting up BookWeb database..." -ForegroundColor Green

# Check if SQL Server LocalDB is installed
$localDbInstances = sqllocaldb info
if ($localDbInstances -eq $null) {
    Write-Host "SQL Server LocalDB is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

Write-Host "SQL Server LocalDB instances found:" -ForegroundColor Yellow
$localDbInstances

# Start the default instance if it's not running
Write-Host "Starting LocalDB default instance..." -ForegroundColor Yellow
sqllocaldb start "MSSQLLocalDB"

# Wait a moment for the instance to start
Start-Sleep -Seconds 3

# Create the database using sqlcmd
Write-Host "Creating BookWeb database..." -ForegroundColor Yellow

$createDbScript = @"
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'BookWeb')
BEGIN
    CREATE DATABASE [BookWeb]
END
GO

-- Grant permissions to the current user
USE [BookWeb]
GO

-- Create a login for the current user if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = '$(whoami)')
BEGIN
    CREATE LOGIN [$(whoami)] FROM WINDOWS
END
GO

-- Create user in the database
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = '$(whoami)')
BEGIN
    CREATE USER [$(whoami)] FOR LOGIN [$(whoami)]
END
GO

-- Grant permissions
ALTER ROLE db_owner ADD MEMBER [$(whoami)]
GO
"@

# Write the script to a temporary file
$tempScript = [System.IO.Path]::GetTempFileName() + ".sql"
$createDbScript | Out-File -FilePath $tempScript -Encoding UTF8

try {
    # Execute the script
    sqlcmd -S "(localdb)\MSSQLLocalDB" -i $tempScript -o "database_setup.log"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Database setup completed successfully!" -ForegroundColor Green
        Write-Host "Database 'BookWeb' has been created and permissions granted." -ForegroundColor Green
    } else {
        Write-Host "Database setup failed. Check database_setup.log for details." -ForegroundColor Red
    }
} catch {
    Write-Host "Error executing database setup: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Clean up temporary file
    if (Test-Path $tempScript) {
        Remove-Item $tempScript -Force
    }
}

Write-Host "Setup complete. You can now run your application." -ForegroundColor Green
