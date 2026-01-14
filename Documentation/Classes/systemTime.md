<!-- Type your summary here -->
# systemTime Class Documentation

## Overview
The `systemTime` class is a specialized API client for retrieving the server's current UTC date and time from the Odyssey API system. This class provides a simple interface to synchronize with server time, making it useful for time-sensitive operations, logging, and system synchronization without requiring authentication.

## Class Information
- **Namespace**: `cs.OdysseyAPI.SystemTime`
- **API Endpoint**: `/System/ServerTime`
- **Base URL**: `https://api.blinfo.com/metaltech/System/ServerTime`
- **HTTP Method**: POST
- **Query Parameter**: `CompanyID` (required)
- **Authentication**: Not required
- **API Key**: Not required

## Properties

### Core Properties
- `request` (cs.request) - The underlying request object that handles HTTP communication
- `settings` (Object) - Configuration settings object passed to the constructor

## Constructor

```4d
Class constructor($settings : Object)
    $settings.apiURL:="https://api.blinfo.com/metaltech/System/ServerTime"
    $settings.apiMethod:="POST"
    This.request:=cs.request.new($settings)
    This.request.systemTime()
    This.settings:=$settings
```

The constructor automatically configures the API endpoint and HTTP method, creates a request object, and calls the systemTime endpoint. The CompanyID is passed as a query parameter in the URL.

### Parameters
- `$settings` (Object) - A settings object, typically `cs.responseSettings.new()` containing:
  - `CompanyID` (Text) - Company identifier (required, appended as query parameter)

### Example Usage
```4d
var $settings : Object
var $timeAPI : cs.OdysseyAPI.SystemTime

// Create settings object with CompanyID
$settings:=cs.responseSettings.new()
$settings.CompanyID:="ACME_CORP"

// Initialize system time API client
$timeAPI:=cs.OdysseyAPI.SystemTime.new($settings)
```

## Usage Examples

### Basic Server Time Retrieval
```4d
var $settings : Object
var $timeAPI : cs.OdysseyAPI.SystemTime
var $result : Object
var $serverTime : Text

// Initialize settings
$settings:=cs.responseSettings.new()
$settings.CompanyID:="COMP001"

// Create system time API instance
$timeAPI:=cs.OdysseyAPI.SystemTime.new($settings)

// Execute the request
$result:=$timeAPI.request.run()

If (Bool($result.Success))
    $serverTime:=String($result.ServerTime)
    ALERT("Server UTC Time: "+$serverTime)
Else 
    ALERT("Failed to retrieve server time: "+String($result.ErrorMessage))
End if
```

### Time Synchronization Function
```4d
// Function to synchronize local time with server time
Function synchronizeWithServerTime($companyID : Text) : Object
    var $settings : Object
    var $timeAPI : cs.OdysseyAPI.SystemTime
    var $result : Object
    var $syncStatus : Object
    var $serverTime; $localTime : Text
    var $timeDifference : Real
    
    $syncStatus:=New object()
    $syncStatus.synchronized:=False
    $syncStatus.timestamp:=String(Current date; ISO date GMT; Current time)
    
    Try
        // Get server time
        $settings:=cs.responseSettings.new()
        $settings.CompanyID:=$companyID
        
        $timeAPI:=cs.OdysseyAPI.SystemTime.new($settings)
        $result:=$timeAPI.request.run()
        
        If (Bool($result.Success))
            $serverTime:=String($result.ServerTime)
            $localTime:=String(Current date; ISO date GMT; Current time)
            
            // Calculate time difference (simplified comparison)
            $timeDifference:=calculateTimeDifference($localTime; $serverTime)
            
            $syncStatus.synchronized:=True
            $syncStatus.serverTime:=$serverTime
            $syncStatus.localTime:=$localTime
            $syncStatus.timeDifference:=$timeDifference
            $syncStatus.message:="Time synchronization successful"
            
            // Log synchronization
            logTimeSyncEvent($companyID; $serverTime; $localTime; $timeDifference)
            
            // Store server time offset for future use
            storeServerTimeOffset($timeDifference)
            
        Else 
            $syncStatus.message:="Failed to retrieve server time: "+String($result.ErrorMessage)
            $syncStatus.errorCode:=$result.statusCode
        End if
        
    Catch
        $syncStatus.message:="Time synchronization error: "+Last errors[0].message
        $syncStatus.exception:=True
    End try
    
    return $syncStatus
```

### Timestamping Service
```4d
// Function to get server timestamp for critical operations
Function getServerTimestamp($companyID : Text) : Text
    var $settings : Object
    var $timeAPI : cs.OdysseyAPI.SystemTime
    var $result : Object
    var $timestamp : Text
    
    Try
        $settings:=cs.responseSettings.new()
        $settings.CompanyID:=$companyID
        
        $timeAPI:=cs.OdysseyAPI.SystemTime.new($settings)
        $result:=$timeAPI.request.run()
        
        If (Bool($result.Success))
            $timestamp:=String($result.ServerTime)
        Else 
            // Fallback to local time if server time unavailable
            $timestamp:=String(Current date; ISO date GMT; Current time)
            logTimestampFallback($companyID; "Server time unavailable, using local time")
        End if
        
    Catch
        // Fallback to local time on exception
        $timestamp:=String(Current date; ISO date GMT; Current time)
        logTimestampFallback($companyID; "Exception occurred: "+Last errors[0].message)
    End try
    
    return $timestamp
```

### Time-Based Authentication Token
```4d
// Function to create time-based authentication tokens
Function createTimeBasedToken($companyID : Text; $userID : Text) : Object
    var $serverTime : Text
    var $tokenData : Object
    var $token : Text
    
    $tokenData:=New object()
    $tokenData.valid:=False
    
    // Get server time for token timestamp
    $serverTime:=getServerTimestamp($companyID)
    
    If ($serverTime#"")
        // Create token with server timestamp
        $tokenData.userID:=$userID
        $tokenData.companyID:=$companyID
        $tokenData.timestamp:=$serverTime
        $tokenData.expiresAt:=addTimeToTimestamp($serverTime; 3600)  // 1 hour expiry
        $tokenData.nonce:=generateNonce()
        
        // Generate secure token
        $token:=generateSecureToken($tokenData)
        
        $tokenData.token:=$token
        $tokenData.valid:=True
        $tokenData.message:="Token created successfully"
        
        // Store token for validation
        storeAuthToken($token; $tokenData)
        
    Else 
        $tokenData.message:="Unable to retrieve server time for token generation"
    End if
    
    return $tokenData
```

### System Health Monitoring
```4d
// Function to monitor system health using server time
Function monitorSystemHealth($companyID : Text) : Object
    var $healthStatus : Object
    var $timeSync : Object
    var $responseTime : Real
    var $startTime : Real
    
    $healthStatus:=New object()
    $healthStatus.healthy:=False
    $healthStatus.timestamp:=String(Current date; ISO date GMT; Current time)
    $healthStatus.companyID:=$companyID
    
    // Measure response time
    $startTime:=Milliseconds
    $timeSync:=synchronizeWithServerTime($companyID)
    $responseTime:=(Milliseconds-$startTime)/1000  // Convert to seconds
    
    $healthStatus.responseTime:=$responseTime
    $healthStatus.timeSync:=$timeSync
    
    If ($timeSync.synchronized)
        $healthStatus.healthy:=True
        $healthStatus.serverReachable:=True
        $healthStatus.timeDifference:=$timeSync.timeDifference
        
        // Check if time difference is acceptable (within 30 seconds)
        If (Abs($timeSync.timeDifference)<=30)
            $healthStatus.timeAccurate:=True
            $healthStatus.message:="System is healthy and time is synchronized"
        Else 
            $healthStatus.timeAccurate:=False
            $healthStatus.message:="System reachable but time difference is significant: "+String($timeSync.timeDifference)+" seconds"
        End if
        
    Else 
        $healthStatus.serverReachable:=False
        $healthStatus.message:="Unable to reach server for time synchronization: "+$timeSync.message
    End if
    
    // Log health status
    logSystemHealthStatus($healthStatus)
    
    return $healthStatus
```

### Scheduled Time Synchronization
```4d
// Function for periodic time synchronization
Function performScheduledTimeSync()
    var $companies : Collection
    var $company : Object
    var $syncResults : Collection
    var $overallStatus : Object
    var $i : Integer
    
    // Get list of companies to sync
    $companies:=getActiveCompanies()
    $syncResults:=New collection()
    
    For ($i; 0; $companies.length-1)
        $company:=$companies[$i]
        
        // Synchronize time for each company
        var $syncResult : Object
        $syncResult:=synchronizeWithServerTime($company.CompanyID)
        $syncResult.companyName:=$company.Name
        
        $syncResults.push($syncResult)
        
        // Add small delay between requests
        DELAY PROCESS(Current process; 100)  // 1 second delay
    End for
    
    // Compile overall synchronization status
    $overallStatus:=New object()
    $overallStatus.timestamp:=String(Current date; ISO date GMT; Current time)
    $overallStatus.totalCompanies:=$companies.length
    $overallStatus.successfulSyncs:=0
    $overallStatus.failedSyncs:=0
    $overallStatus.results:=$syncResults
    
    // Count successful synchronizations
    For ($i; 0; $syncResults.length-1)
        If ($syncResults[$i].synchronized)
            $overallStatus.successfulSyncs:=$overallStatus.successfulSyncs+1
        Else 
            $overallStatus.failedSyncs:=$overallStatus.failedSyncs+1
        End if
    End for
    
    // Log overall synchronization results
    logScheduledSyncResults($overallStatus)
    
    // Send alert if too many failures
    If ($overallStatus.failedSyncs>($overallStatus.totalCompanies*0.25))  // More than 25% failed
        sendTimeSyncAlert($overallStatus)
    End if
```

### Transaction Timestamping
```4d
// Function to timestamp critical transactions
Function timestampTransaction($companyID : Text; $transactionID : Text; $transactionData : Object) : Object
    var $timestampedTransaction : Object
    var $serverTime : Text
    
    // Get authoritative server timestamp
    $serverTime:=getServerTimestamp($companyID)
    
    // Create timestamped transaction record
    $timestampedTransaction:=OB Copy($transactionData)
    $timestampedTransaction.transactionID:=$transactionID
    $timestampedTransaction.companyID:=$companyID
    $timestampedTransaction.serverTimestamp:=$serverTime
    $timestampedTransaction.localTimestamp:=String(Current date; ISO date GMT; Current time)
    $timestampedTransaction.timestampSource:=($serverTime#"") ? "Server" : "Local"
    
    // Calculate transaction hash for integrity
    $timestampedTransaction.integrityHash:=calculateTransactionHash($timestampedTransaction)
    
    // Store timestamped transaction
    storeTimestampedTransaction($timestampedTransaction)
    
    return $timestampedTransaction
```

### Time Zone Conversion Utility
```4d
// Function to convert server time to different time zones
Function convertServerTimeToTimeZone($companyID : Text; $targetTimeZone : Text) : Object
    var $timeConversion : Object
    var $serverTime : Text
    var $localTime : Text
    
    $timeConversion:=New object()
    $timeConversion.success:=False
    
    // Get server UTC time
    $serverTime:=getServerTimestamp($companyID)
    
    If ($serverTime#"")
        // Convert to target time zone
        $localTime:=convertUTCToTimeZone($serverTime; $targetTimeZone)
        
        $timeConversion.success:=True
        $timeConversion.serverUTC:=$serverTime
        $timeConversion.localTime:=$localTime
        $timeConversion.timeZone:=$targetTimeZone
        $timeConversion.message:="Time conversion successful"
    Else 
        $timeConversion.message:="Unable to retrieve server time for conversion"
    End if
    
    return $timeConversion
```

## Integration Patterns

### Audit Trail Integration
```4d
// Function to create audit entries with server timestamps
Function createAuditEntry($companyID : Text; $action : Text; $details : Object) : Object
    var $auditEntry : Object
    var $serverTime : Text
    
    // Get server timestamp for audit trail
    $serverTime:=getServerTimestamp($companyID)
    
    $auditEntry:=New object()
    $auditEntry.companyID:=$companyID
    $auditEntry.action:=$action
    $auditEntry.details:=$details
    $auditEntry.timestamp:=$serverTime
    $auditEntry.user:=Current user
    $auditEntry.sessionID:=getCurrentSessionID()
    
    // Store audit entry
    storeAuditEntry($auditEntry)
    
    return $auditEntry
```

### API Rate Limiting with Time Windows
```4d
// Function to implement time-based rate limiting
Function checkRateLimit($companyID : Text; $apiEndpoint : Text; $userID : Text) : Boolean
    var $serverTime : Text
    var $windowStart : Text
    var $requestCount : Integer
    var $maxRequests : Integer
    var $windowSize : Integer
    
    $maxRequests:=100  // Max requests per window
    $windowSize:=3600  // 1 hour window in seconds
    
    // Get current server time
    $serverTime:=getServerTimestamp($companyID)
    
    If ($serverTime#"")
        // Calculate window start time
        $windowStart:=subtractTimeFromTimestamp($serverTime; $windowSize)
        
        // Count requests in current window
        $requestCount:=countAPIRequests($companyID; $apiEndpoint; $userID; $windowStart; $serverTime)
        
        If ($requestCount<$maxRequests)
            // Record this request
            recordAPIRequest($companyID; $apiEndpoint; $userID; $serverTime)
            return True
        Else 
            // Rate limit exceeded
            logRateLimitExceeded($companyID; $apiEndpoint; $userID; $requestCount; $maxRequests)
            return False
        End if
    Else 
        // If we can't get server time, allow the request but log the issue
        logTimestampIssue("Rate limiting failed due to server time unavailability")
        return True
    End if
```

## System Configuration

### Time Sync Configuration
```4d
// Function to configure automatic time synchronization
Function configureAutoTimeSync($enabled : Boolean; $intervalMinutes : Integer; $companies : Collection)
    var $config : Object
    
    $config:=New object()
    $config.enabled:=$enabled
    $config.intervalMinutes:=$intervalMinutes
    $config.companies:=$companies
    $config.lastSync:=""
    $config.nextSync:=""
    
    If ($enabled)
        // Calculate next sync time
        $config.nextSync:=addMinutesToCurrentTime($intervalMinutes)
        
        // Schedule periodic sync
        schedulePeriodicTask("TIME_SYNC"; $intervalMinutes*60; "performScheduledTimeSync")
    Else 
        // Cancel scheduled sync
        cancelPeriodicTask("TIME_SYNC")
    End if
    
    // Store configuration
    storeTimeSyncConfig($config)
```

## Key Features

1. **No Authentication Required**: This endpoint doesn't require API keys or user authentication
2. **UTC Time Standard**: Returns server time in UTC ISO format for consistency
3. **Time Synchronization**: Perfect for synchronizing local applications with server time
4. **System Health**: Can be used to verify server connectivity and response times
5. **Audit Trail Support**: Provides authoritative timestamps for critical operations
6. **Lightweight**: Minimal overhead makes it suitable for frequent time checks

## Notes

- This class is specifically designed for the Odyssey API system
- The endpoint returns UTC date and time in ISO format
- CompanyID is required as a query parameter in the URL
- Ideal for time synchronization, audit trails, and system health monitoring
- Can be used without authentication, making it perfect for system health checks
- The class automatically calls the systemTime endpoint during construction
- Results are available through the `request.run()` method
- Consider caching server time locally to reduce API calls for frequent operations
- Implement proper error handling for cases where server time is unavailable
