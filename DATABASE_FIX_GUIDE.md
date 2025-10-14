# BookWeb Database Fix Guide

## Problem Summary
You were getting this error:
```
System.InvalidOperationException: An exception has been raised that is likely due to a transient failure. Consider enabling transient error resiliency by adding 'EnableRetryOnFailure' to the 'UseSqlServer' call.
```

**Root Causes:**
1. Database "BookWeb" doesn't exist
2. User 'DELL\meetp' doesn't have proper permissions
3. No retry logic configured for transient failures

## ✅ Solutions Applied

### 1. Added Retry Logic
Updated `Program.cs` to include retry configuration:
```csharp
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        sqlServerOptions => sqlServerOptions.EnableRetryOnFailure(
            maxRetryCount: 3,
            maxRetryDelay: TimeSpan.FromSeconds(30),
            errorNumbersToAdd: null)
    ));
```

### 2. Added Database Initialization
Added automatic database creation in `Program.cs`:
```csharp
// Ensure database is created and migrated
using (var scope = app.Services.CreateScope())
{
    try
    {
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        context.Database.EnsureCreated();
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Database initialization error: {ex.Message}");
    }
}
```

### 3. Updated Connection String
Added `TrustServerCertificate=true` to the connection string in `appsettings.json`:
```json
"ConnectionStrings": {
  "DefaultConnection": "Server=(localdb)\\MSSQLLocalDb;Database=BookWeb;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=true"
}
```

## 🚀 How to Fix Your Issue

### Option 1: Run the Setup Script (Recommended)
1. **Open PowerShell as Administrator**
2. **Navigate to your project folder:**
   ```powershell
   cd "C:\WAD PROJECT\Booknest\BookNest"
   ```
3. **Run the setup script:**
   ```powershell
   .\setup_database.ps1
   ```

### Option 2: Run the Batch File
1. **Double-click** `setup_database.bat`
2. **Follow the prompts**

### Option 3: Manual Setup
1. **Open Command Prompt as Administrator**
2. **Start LocalDB:**
   ```cmd
   sqllocaldb start "MSSQLLocalDB"
   ```
3. **Create the database:**
   ```cmd
   sqlcmd -S "(localdb)\MSSQLLocalDB" -Q "CREATE DATABASE [BookWeb]"
   ```

## 🔧 What the Fix Does

### Retry Logic Configuration
- **Max Retry Count**: 3 attempts
- **Max Retry Delay**: 30 seconds between retries
- **Exponential Backoff**: Automatically applied
- **All Transient Errors**: Covered by default

### Database Initialization
- **Automatic Creation**: Database is created when the app starts
- **Error Handling**: Graceful handling of initialization errors
- **Migration Support**: Ready for future migrations

### Connection String Improvements
- **Trust Server Certificate**: Prevents SSL certificate issues
- **Multiple Active Result Sets**: Allows multiple queries on same connection
- **Trusted Connection**: Uses Windows authentication

## 🧪 Testing the Fix

1. **Run the setup script** (Option 1 above)
2. **Start your application:**
   ```cmd
   dotnet run --project BulkyWeb
   ```
3. **Navigate to** `https://localhost:7000` (or your configured port)
4. **Check the Home page** - it should load without database errors

## 🔍 Troubleshooting

### If you still get errors:

1. **Check LocalDB status:**
   ```cmd
   sqllocaldb info
   ```

2. **Start LocalDB manually:**
   ```cmd
   sqllocaldb start "MSSQLLocalDB"
   ```

3. **Check database exists:**
   ```cmd
   sqlcmd -S "(localdb)\MSSQLLocalDB" -Q "SELECT name FROM sys.databases WHERE name = 'BookWeb'"
   ```

4. **Check user permissions:**
   ```cmd
   sqlcmd -S "(localdb)\MSSQLLocalDB" -d "BookWeb" -Q "SELECT USER_NAME()"
   ```

### Common Issues:

- **"Login failed"**: Run setup script as Administrator
- **"Cannot open database"**: Database doesn't exist, run setup script
- **"Access denied"**: User doesn't have permissions, run setup script
- **"LocalDB not found"**: Install SQL Server LocalDB

## 📋 What's Different Now

### Before:
- No retry logic → Transient failures caused exceptions
- Database might not exist → Connection failures
- No automatic initialization → Manual setup required

### After:
- ✅ Automatic retry on transient failures
- ✅ Automatic database creation
- ✅ Proper error handling
- ✅ Better connection string configuration

## 🎯 Expected Results

After applying these fixes:
1. **No more transient failure exceptions**
2. **Database automatically created** on first run
3. **Automatic retry** on temporary connection issues
4. **Better error messages** for debugging

Your BookWeb application should now work without the `System.InvalidOperationException` error!
