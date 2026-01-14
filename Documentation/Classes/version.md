<!-- Type your summary here -->
# version Class Documentation

## Overview
The `version` class is a specialized API client for retrieving version information from the Odyssey API system. This class provides a simple interface to check the API version without requiring authentication or API keys, making it useful for system health checks and compatibility verification.

## Class Information
- **Namespace**: `cs.OdysseyAPI.version`
- **API Endpoint**: `/System/Version`
- **Base URL**: `https://api.blinfo.com/metaltech/System/Version`
- **Authentication**: Not required
- **API Key**: Not required

## Properties

### Core Properties
- `request` (cs.request) - The underlying request object that handles HTTP communication
- `settings` (Object) - Configuration settings object passed to the constructor

## Constructor

```4d
Class constructor($settings : Object)
    $settings.apiURL:="https://api.blinfo.com/metaltech/System/Version"
    $settings.apiMethod:="GET"
    This.request:=cs.request.new($settings)
    This.request.version()
    This.settings:=$settings
```

The constructor automatically configures the API endpoint and HTTP method, creates a request object, and calls the version endpoint.

### Parameters
- `$settings` (Object) - A settings object, typically `cs.responseSettings.new()` or similar configuration object

### Example Usage
```4d
var $settings : Object
var $versionAPI : cs.OdysseyAPI.version

// Create settings object
$settings:=cs.responseSettings.new()

// Initialize version API client
$versionAPI:=cs.OdysseyAPI.version.new($settings)
```

## Usage Examples

### Basic Version Check
```4d
var $settings : Object
var $versionAPI : cs.OdysseyAPI.version
var $result : Object

// Initialize settings
$settings:=cs.responseSettings.new()

// Create version API instance
$versionAPI:=cs.OdysseyAPI.version.new($settings)

// Execute the request and get results
$result:=$versionAPI.request.run()

If (Bool($result.Success))
    ALERT("API Version: "+String($result.Version))
    ALERT("Build Date: "+String($result.BuildDate))
Else 
    ALERT("Failed to retrieve version information")
End if
```

### System Health Check
```4d
// Function to check if the API is accessible and get version info
Function checkAPIHealth() : Object
    var $settings : Object
    var $versionAPI : cs.OdysseyAPI.version
    var $healthStatus : Object
    
    $settings:=cs.responseSettings.new()
    $versionAPI:=cs.OdysseyAPI.version.new($settings)
    
    $healthStatus:=$versionAPI.request.run()
    
    // Add additional health check information
    $healthStatus.timestamp:=String(Current date; ISO date GMT; Current time)
    $healthStatus.endpoint:="System/Version"
    $healthStatus.requiresAuth:=False
    
    return $healthStatus
```

### Version Compatibility Check
```4d
// Function to verify API compatibility
Function verifyAPICompatibility($minimumVersion : Text) : Boolean
    var $settings : Object
    var $versionAPI : cs.OdysseyAPI.version
    var $result : Object
    var $currentVersion : Text
    
    $settings:=cs.responseSettings.new()
    $versionAPI:=cs.OdysseyAPI.version.new($settings)
    $result:=$versionAPI.request.run()
    
    If (Bool($result.Success))
        $currentVersion:=String($result.Version)
        
        // Compare versions (simple string comparison)
        // In production, you might want more sophisticated version comparison
        If ($currentVersion>=$minimumVersion)
            return True
        Else 
            ALERT("API version "+$currentVersion+" is below minimum required version "+$minimumVersion)
            return False
        End if
    Else 
        ALERT("Unable to retrieve API version information")
        return False
    End if
```

### Application Startup Version Check
```4d
// Function to run during application startup
Function performStartupVersionCheck()
    var $settings : Object
    var $versionAPI : cs.OdysseyAPI.version
    var $result : Object
    var $startupLog : Text
    
    $settings:=cs.responseSettings.new()
    $versionAPI:=cs.OdysseyAPI.version.new($settings)
    $result:=$versionAPI.request.run()
    
    $startupLog:="=== API Version Check ==="+Char(Line feed)
    $startupLog:=$startupLog+"Timestamp: "+String(Current date; ISO date GMT)+" "+String(Current time; HH MM SS)+Char(Line feed)
    $startupLog:=$startupLog+"Endpoint: https://api.blinfo.com/metaltech/System/Version"+Char(Line feed)
    
    If (Bool($result.Success))
        $startupLog:=$startupLog+"Status: SUCCESS"+Char(Line feed)
        $startupLog:=$startupLog+"API Version: "+String($result.Version)+Char(Line feed)
        $startupLog:=$startupLog+"Build Date: "+String($result.BuildDate)+Char(Line feed)
        
        // Log successful version check
        LOG EVENT(Into system standard outputs; $startupLog)
        
    Else 
        $startupLog:=$startupLog+"Status: FAILED"+Char(Line feed)
        $startupLog:=$startupLog+"Error: "+String($result.ErrorMessage)+Char(Line feed)
        
        // Log failed version check
        LOG EVENT(Into system standard outputs; $startupLog; Error message)
        
        // Optionally show user notification
        ALERT("Warning: Unable to connect to API service. Some features may not be available.")
    End if
    
    $startupLog:=$startupLog+"========================="
```

### Batch System Information Gathering
```4d
// Function to gather comprehensive system information
Function gatherSystemInfo() : Object
    var $settings : Object
    var $versionAPI : cs.OdysseyAPI.version
    var $systemInfo : Object
    var $versionResult : Object
    
    $systemInfo:=New object()
    
    // Get API version information
    $settings:=cs.responseSettings.new()
    $versionAPI:=cs.OdysseyAPI.version.new($settings)
    $versionResult:=$versionAPI.request.run()
    
    // Compile system information
    $systemInfo.client:=New object()
    $systemInfo.client.platform:=Get platform interface(System platform)
    $systemInfo.client.4DVersion:=Application version
    $systemInfo.client.timestamp:=String(Current date; ISO date GMT; Current time)
    $systemInfo.client.user:=Current user
    
    $systemInfo.api:=New object()
    If (Bool($versionResult.Success))
        $systemInfo.api.available:=True
        $systemInfo.api.version:=$versionResult.Version
        $systemInfo.api.buildDate:=$versionResult.BuildDate
        $systemInfo.api.endpoint:="https://api.blinfo.com/metaltech"
    Else 
        $systemInfo.api.available:=False
        $systemInfo.api.error:=$versionResult.ErrorMessage
        $systemInfo.api.endpoint:="https://api.blinfo.com/metaltech"
    End if
    
    return $systemInfo
```

### Error Handling Example
```4d
// Robust version check with comprehensive error handling
Function robustVersionCheck() : Object
    var $settings : Object
    var $versionAPI : cs.OdysseyAPI.version
    var $result : Object
    var $status : Object
    
    $status:=New object()
    $status.success:=False
    $status.timestamp:=String(Current date; ISO date GMT; Current time)
    
    Try
        $settings:=cs.responseSettings.new()
        $versionAPI:=cs.OdysseyAPI.version.new($settings)
        $result:=$versionAPI.request.run()
        
        If (Bool($result.Success))
            $status.success:=True
            $status.version:=$result.Version
            $status.buildDate:=$result.BuildDate
            $status.message:="Version information retrieved successfully"
        Else 
            $status.message:="API returned error: "+String($result.ErrorMessage)
            $status.errorCode:=$result.statusCode
        End if
        
    Catch
        $status.message:="Exception occurred while checking version: "+Last errors[0].message
        $status.exception:=True
    End try
    
    return $status
```

## Integration Patterns

### Using with Application Configuration
```4d
// During application initialization
var $appConfig : Object
var $versionCheck : Object

$appConfig:=New object()
$appConfig.api:=New object()

// Check API availability and version
$versionCheck:=robustVersionCheck()

If ($versionCheck.success)
    $appConfig.api.available:=True
    $appConfig.api.version:=$versionCheck.version
    $appConfig.api.buildDate:=$versionCheck.buildDate
    
    // Enable API-dependent features
    enableAPIFeatures()
Else 
    $appConfig.api.available:=False
    $appConfig.api.error:=$versionCheck.message
    
    // Disable API-dependent features
    disableAPIFeatures()
    showOfflineMode()
End if

// Store configuration globally
SET_APPLICATION_CONFIG($appConfig)
```

### Scheduled Version Monitoring
```4d
// Method to be called periodically (e.g., every hour)
Function monitorAPIVersion()
    var $currentCheck : Object
    var $lastKnownVersion : Text
    var $configChanged : Boolean
    
    $lastKnownVersion:=Get_Last_Known_API_Version()
    $currentCheck:=robustVersionCheck()
    
    If ($currentCheck.success)
        If ($currentCheck.version#$lastKnownVersion)
            $configChanged:=True
            
            // Log version change
            LOG EVENT(Into system standard outputs; "API version changed from "+$lastKnownVersion+" to "+$currentCheck.version)
            
            // Update stored version
            Set_Last_Known_API_Version($currentCheck.version)
            
            // Notify administrators if needed
            If ($configChanged)
                notifyAdministrators("API version updated"; $currentCheck)
            End if
        End if
    Else 
        // Log connection issues
        LOG EVENT(Into system standard outputs; "API version check failed: "+$currentCheck.message; Warning message)
    End if
```

## Key Features

1. **No Authentication Required**: This endpoint doesn't require API keys or user authentication, making it perfect for system health checks.

2. **Automatic Configuration**: The constructor automatically sets up the correct endpoint and HTTP method.

3. **Simple Integration**: Easy to integrate into startup routines, health checks, and monitoring systems.

4. **Error Handling**: Built on the robust `cs.request` class which provides comprehensive error handling.

5. **Lightweight**: Minimal overhead makes it suitable for frequent health checks.

## Notes

- This class is specifically designed for the Odyssey API system
- The endpoint returns basic version information without requiring authentication
- Ideal for use in application startup sequences and system monitoring
- Can be used to verify API availability before attempting authenticated operations
- The class automatically calls the version endpoint during construction
- Results are available through the `request.run()` method