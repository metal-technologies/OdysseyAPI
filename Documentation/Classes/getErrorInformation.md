<!-- Type your summary here -->
# getErrorInformation Class Documentation

## Overview
The `getErrorInformation` class is a specialized API client for retrieving detailed error information from the Odyssey API system. This class provides a mechanism to obtain comprehensive error messages and diagnostic information using error IDs, making it essential for debugging, error handling, and providing meaningful feedback to users when API operations fail.

## Class Information
- **Namespace**: `cs.OdysseyAPI.GetErrorInformation`
- **API Endpoint**: `/System/ErrorMessage`
- **Base URL**: `https://api.blinfo.com/metaltech/System/ErrorMessage`
- **HTTP Method**: GET
- **Authentication**: Requires API key and proper authentication
- **Query Parameters**: ErrorID and CompanyID (typically appended to URL)

## Properties

### Core Properties
- `request` (cs.request) - The underlying request object that handles HTTP communication
- `settings` (Object) - Configuration settings object passed to the constructor

## Constructor

```4d
Class constructor($settings : Object)
    $settings.apiURL:="https://api.blinfo.com/metaltech/System/ErrorMessage"
    $settings.apiMethod:="GET"
    This.request:=cs.request.new($settings)
    This.request.errorMessage()
    This.settings:=$settings
```

The constructor automatically configures the API endpoint and HTTP method, creates a request object, and calls the errorMessage endpoint.

### Parameters
- `$settings` (Object) - A settings object, typically `cs.responseSettings.new()` containing:
  - `CompanyID` (Text) - Company identifier
  - `errorID` (Real/Integer) - Error identifier to retrieve information for

### Example Usage
```4d
var $settings : Object
var $errorAPI : cs.OdysseyAPI.GetErrorInformation

// Create settings object with error parameters
$settings:=cs.responseSettings.new()
$settings.CompanyID:="ACME_CORP"
$settings.errorID:=404

// Initialize error information API client
$errorAPI:=cs.OdysseyAPI.GetErrorInformation.new($settings)
```

## Usage Examples

### Basic Error Information Retrieval
```4d
var $settings : Object
var $errorAPI : cs.OdysseyAPI.GetErrorInformation
var $result : Object

// Initialize settings with error ID
$settings:=cs.responseSettings.new()
$settings.CompanyID:="COMP001"
$settings.errorID:=1001

// Create error information API instance
$errorAPI:=cs.OdysseyAPI.GetErrorInformation.new($settings)

// Execute the request
$result:=$errorAPI.request.run()

If (Bool($result.Success))
    ALERT("Error Details:\n"+\
          "Level 1: "+String($result.LevelOneText)+"\n"+\
          "Level 2: "+String($result.LevelTwoText)+"\n"+\
          "Description: "+String($result.ErrorDescription))
Else 
    ALERT("Failed to retrieve error information: "+String($result.ErrorMessage))
End if
```

### Comprehensive Error Handler Function
```4d
// Function to handle and display detailed error information
Function handleDetailedError($errorID : Integer; $companyID : Text; $context : Text) : Object
    var $settings : Object
    var $errorAPI : cs.OdysseyAPI.GetErrorInformation
    var $result : Object
    var $errorDetails : Object
    
    // Initialize error details object
    $errorDetails:=New object()
    $errorDetails.resolved:=False
    $errorDetails.timestamp:=String(Current date; ISO date GMT; Current time)
    $errorDetails.errorID:=$errorID
    $errorDetails.companyID:=$companyID
    $errorDetails.context:=$context
    
    Try
        // Set up error information request
        $settings:=cs.responseSettings.new()
        $settings.CompanyID:=$companyID
        $settings.errorID:=$errorID
        
        // Retrieve error information
        $errorAPI:=cs.OdysseyAPI.GetErrorInformation.new($settings)
        $result:=$errorAPI.request.run()
        
        If (Bool($result.Success))
            $errorDetails.resolved:=True
            $errorDetails.levelOneText:=$result.LevelOneText
            $errorDetails.levelTwoText:=$result.LevelTwoText
            $errorDetails.errorDescription:=$result.ErrorDescription
            $errorDetails.errorCategory:=$result.ErrorCategory
            $errorDetails.severity:=$result.Severity
            $errorDetails.suggestedAction:=$result.SuggestedAction
            
            // Build comprehensive error message
            var $fullMessage : Text
            $fullMessage:="Error Details (ID: "+String($errorID)+")\n"
            $fullMessage:=$fullMessage+"Context: "+$context+"\n"
            $fullMessage:=$fullMessage+"──────────────────────\n"
            $fullMessage:=$fullMessage+"Level 1: "+String($result.LevelOneText)+"\n"
            $fullMessage:=$fullMessage+"Level 2: "+String($result.LevelTwoText)+"\n"
            $fullMessage:=$fullMessage+"Description: "+String($result.ErrorDescription)+"\n"
            
            If ($result.SuggestedAction#"")
                $fullMessage:=$fullMessage+"Suggested Action: "+String($result.SuggestedAction)+"\n"
            End if
            
            $errorDetails.fullMessage:=$fullMessage
            $errorDetails.message:="Error information retrieved successfully"
            
            // Log detailed error
            logDetailedError($errorDetails)
            
        Else 
            $errorDetails.message:="Failed to retrieve error information: "+String($result.ErrorMessage)
            $errorDetails.retrievalError:=$result.ErrorMessage
            
            // Log retrieval failure
            logErrorRetrievalFailure($errorID; $companyID; $result.ErrorMessage)
        End if
        
    Catch
        $errorDetails.message:="Error information retrieval exception: "+Last errors[0].message
        $errorDetails.exception:=True
        
        // Log exception
        logErrorRetrievalException($errorID; $companyID; Last errors[0].message)
    End try
    
    return $errorDetails
```

### Error Information Cache System
```4d
// Function to retrieve error information with caching
Function getErrorInformationCached($errorID : Integer; $companyID : Text) : Object
    var $cacheKey : Text
    var $cachedError : Object
    var $errorInfo : Object
    
    // Create cache key
    $cacheKey:="error_"+String($errorID)+"_"+$companyID
    
    // Check cache first
    $cachedError:=getFromErrorCache($cacheKey)
    
    If ($cachedError#Null)
        // Return cached information
        $cachedError.fromCache:=True
        $cachedError.cacheHit:=True
        return $cachedError
    Else 
        // Retrieve from API
        $errorInfo:=handleDetailedError($errorID; $companyID; "Cache miss")
        
        If ($errorInfo.resolved)
            // Cache the result for future use
            $errorInfo.cachedAt:=String(Current date; ISO date GMT; Current time)
            $errorInfo.fromCache:=False
            $errorInfo.cacheHit:=False
            
            storeInErrorCache($cacheKey; $errorInfo; 3600)  // Cache for 1 hour
        End if
        
        return $errorInfo
    End if
```

### Batch Error Information Retrieval
```4d
// Function to retrieve information for multiple errors
Function getMultipleErrorInformation($errorIDs : Collection; $companyID : Text) : Collection
    var $errorResults : Collection
    var $errorID : Integer
    var $errorInfo : Object
    var $i : Integer
    
    $errorResults:=New collection()
    
    For ($i; 0; $errorIDs.length-1)
        $errorID:=$errorIDs[$i]
        
        Try
            // Get error information (with caching)
            $errorInfo:=getErrorInformationCached($errorID; $companyID)
            $errorInfo.batchIndex:=$i
            
            $errorResults.push($errorInfo)
            
        Catch
            // Add error entry for failed retrieval
            $errorResults.push(New object(\
                "errorID"; $errorID; \
                "resolved"; False; \
                "message"; "Exception during retrieval: "+Last errors[0].message; \
                "exception"; True; \
                "batchIndex"; $i))
        End try
        
        // Add small delay to avoid overwhelming the API
        DELAY PROCESS(Current process; 50)  // 0.5 second delay
    End for
    
    return $errorResults
```

### Error Analysis and Categorization
```4d
// Function to analyze and categorize errors
Function analyzeErrorPatterns($errorLog : Collection) : Object
    var $analysis : Object
    var $errorEntry : Object
    var $categories : Object
    var $severityCount : Object
    var $i : Integer
    
    $analysis:=New object()
    $analysis.totalErrors:=$errorLog.length
    $analysis.timestamp:=String(Current date; ISO date GMT; Current time)
    
    $categories:=New object()
    $categories.authentication:=0
    $categories.validation:=0
    $categories.system:=0
    $categories.data:=0
    $categories.network:=0
    $categories.unknown:=0
    
    $severityCount:=New object()
    $severityCount.low:=0
    $severityCount.medium:=0
    $severityCount.high:=0
    $severityCount.critical:=0
    
    For ($i; 0; $errorLog.length-1)
        $errorEntry:=$errorLog[$i]
        
        // Get detailed error information if not already available
        If ($errorEntry.levelOneText=Null)
            var $errorDetails : Object
            $errorDetails:=getErrorInformationCached($errorEntry.errorID; $errorEntry.companyID)
            
            If ($errorDetails.resolved)
                $errorEntry.levelOneText:=$errorDetails.levelOneText
                $errorEntry.levelTwoText:=$errorDetails.levelTwoText
                $errorEntry.errorCategory:=$errorDetails.errorCategory
                $errorEntry.severity:=$errorDetails.severity
            End if
        End if
        
        // Categorize error
        Case of 
            : (String($errorEntry.levelOneText)="@authentication@") || (String($errorEntry.levelOneText)="@login@")
                $categories.authentication:=$categories.authentication+1
                
            : (String($errorEntry.levelOneText)="@validation@") || (String($errorEntry.levelOneText)="@invalid@")
                $categories.validation:=$categories.validation+1
                
            : (String($errorEntry.levelOneText)="@system@") || (String($errorEntry.levelOneText)="@server@")
                $categories.system:=$categories.system+1
                
            : (String($errorEntry.levelOneText)="@data@") || (String($errorEntry.levelOneText)="@record@")
                $categories.data:=$categories.data+1
                
            : (String($errorEntry.levelOneText)="@network@") || (String($errorEntry.levelOneText)="@connection@")
                $categories.network:=$categories.network+1
                
            Else 
                $categories.unknown:=$categories.unknown+1
        End case
        
        // Count severity levels
        Case of 
            : ($errorEntry.severity="Low")
                $severityCount.low:=$severityCount.low+1
            : ($errorEntry.severity="Medium")
                $severityCount.medium:=$severityCount.medium+1
            : ($errorEntry.severity="High")
                $severityCount.high:=$severityCount.high+1
            : ($errorEntry.severity="Critical")
                $severityCount.critical:=$severityCount.critical+1
        End case
    End for
    
    $analysis.categories:=$categories
    $analysis.severityDistribution:=$severityCount
    $analysis.mostCommonCategory:=findMostCommonCategory($categories)
    $analysis.criticalErrorCount:=$severityCount.critical
    $analysis.requiresAttention:=($severityCount.high+$severityCount.critical)>0
    
    return $analysis
```

### Error Resolution Workflow
```4d
// Function to manage error resolution workflow
Function processErrorResolution($errorID : Integer; $companyID : Text; $reportedBy : Text) : Object
    var $resolution : Object
    var $errorInfo : Object
    var $resolutionSteps : Collection
    
    $resolution:=New object()
    $resolution.errorID:=$errorID
    $resolution.companyID:=$companyID
    $resolution.reportedBy:=$reportedBy
    $resolution.startTime:=String(Current date; ISO date GMT; Current time)
    $resolution.resolved:=False
    
    // Get detailed error information
    $errorInfo:=handleDetailedError($errorID; $companyID; "Error resolution workflow")
    
    If ($errorInfo.resolved)
        $resolution.errorDetails:=$errorInfo
        
        // Generate resolution steps based on error category
        $resolutionSteps:=generateResolutionSteps($errorInfo)
        $resolution.resolutionSteps:=$resolutionSteps
        
        // Create resolution ticket
        var $ticketID : Text
        $ticketID:=createResolutionTicket($resolution)
        $resolution.ticketID:=$ticketID
        
        // Notify appropriate personnel
        notifyErrorResolutionTeam($resolution)
        
        // Track resolution progress
        $resolution.status:="In Progress"
        $resolution.assignedTo:=assignErrorToTeamMember($errorInfo.errorCategory)
        
        $resolution.message:="Error resolution workflow initiated successfully"
    Else 
        $resolution.message:="Unable to retrieve error information for resolution workflow"
    End if
    
    return $resolution
```

### Error Monitoring Dashboard
```4d
// Function to generate error monitoring dashboard data
Function generateErrorDashboard($companyID : Text; $timeFrame : Text) : Object
    var $dashboard : Object
    var $errorLog : Collection
    var $recentErrors : Collection
    var $analysis : Object
    var $trends : Object
    
    $dashboard:=New object()
    $dashboard.companyID:=$companyID
    $dashboard.timeFrame:=$timeFrame
    $dashboard.generatedAt:=String(Current date; ISO date GMT; Current time)
    
    // Get error log for the specified time frame
    $errorLog:=getErrorLogForTimeFrame($companyID; $timeFrame)
    
    // Analyze error patterns
    $analysis:=analyzeErrorPatterns($errorLog)
    $dashboard.analysis:=$analysis
    
    // Get recent critical errors with detailed information
    $recentErrors:=getRecentCriticalErrors($companyID; 10)  // Last 10 critical errors
    
    var $error : Object
    var $detailedErrors : Collection
    $detailedErrors:=New collection()
    
    For each ($error; $recentErrors)
        var $errorDetails : Object
        $errorDetails:=getErrorInformationCached($error.errorID; $companyID)
        $errorDetails.occurredAt:=$error.timestamp
        $errorDetails.frequency:=$error.frequency
        $detailedErrors.push($errorDetails)
    End for each
    
    $dashboard.recentCriticalErrors:=$detailedErrors
    
    // Calculate error trends
    $trends:=calculateErrorTrends($errorLog; $timeFrame)
    $dashboard.trends:=$trends
    
    // Generate recommendations
    $dashboard.recommendations:=generateErrorRecommendations($analysis; $trends)
    
    return $dashboard
```

### Automated Error Reporting
```4d
// Function for automated error reporting and escalation
Function processAutomatedErrorReporting()
    var $companies : Collection
    var $company : Object
    var $errorSummary : Object
    var $escalationNeeded : Boolean
    
    // Get all companies for monitoring
    $companies:=getActiveCompaniesForMonitoring()
    
    For each ($company; $companies)
        // Generate error dashboard for each company
        $errorSummary:=generateErrorDashboard($company.CompanyID; "last24hours")
        
        $escalationNeeded:=False
        
        // Check for escalation conditions
        If ($errorSummary.analysis.criticalErrorCount>5)
            $escalationNeeded:=True
        End if
        
        If ($errorSummary.trends.errorRateIncreasing) && ($errorSummary.trends.increasePercentage>50)
            $escalationNeeded:=True
        End if
        
        // Send reports and escalations as needed
        If ($escalationNeeded)
            sendErrorEscalationReport($company; $errorSummary)
            logErrorEscalation($company.CompanyID; "Automated escalation triggered")
        Else 
            sendDailyErrorSummary($company; $errorSummary)
        End if
        
        // Store dashboard data for historical analysis
        storeDashboardSnapshot($errorSummary)
    End for each
```

## Integration Patterns

### Error Middleware Integration
```4d
// Function to integrate error information into API error responses
Function enhanceAPIErrorResponse($originalError : Object; $companyID : Text) : Object
    var $enhancedError : Object
    var $errorInfo : Object
    
    $enhancedError:=OB Copy($originalError)
    
    // Extract error ID from original error message if available
    var $errorID : Integer
    $errorID:=extractErrorIDFromMessage($originalError.ErrorMessage)
    
    If ($errorID>0)
        // Get detailed error information
        $errorInfo:=getErrorInformationCached($errorID; $companyID)
        
        If ($errorInfo.resolved)
            $enhancedError.detailedError:=New object()
            $enhancedError.detailedError.id:=$errorID
            $enhancedError.detailedError.levelOneText:=$errorInfo.levelOneText
            $enhancedError.detailedError.levelTwoText:=$errorInfo.levelTwoText
            $enhancedError.detailedError.description:=$errorInfo.errorDescription
            $enhancedError.detailedError.suggestedAction:=$errorInfo.suggestedAction
            $enhancedError.detailedError.severity:=$errorInfo.severity
            
            // Create user-friendly message
            $enhancedError.userMessage:=createUserFriendlyErrorMessage($errorInfo)
        End if
    End if
    
    return $enhancedError
```

### Logging Integration
```4d
// Function to log errors with detailed information
Function logEnhancedError($errorID : Integer; $companyID : Text; $context : Object)
    var $errorInfo : Object
    var $logEntry : Object
    
    // Get detailed error information
    $errorInfo:=getErrorInformationCached($errorID; $companyID)
    
    // Create comprehensive log entry
    $logEntry:=New object()
    $logEntry.timestamp:=String(Current date; ISO date GMT; Current time)
    $logEntry.errorID:=$errorID
    $logEntry.companyID:=$companyID
    $logEntry.context:=$context
    $logEntry.user:=Current user
    $logEntry.session:=getCurrentSessionID()
    
    If ($errorInfo.resolved)
        $logEntry.levelOneText:=$errorInfo.levelOneText
        $logEntry.levelTwoText:=$errorInfo.levelTwoText
        $logEntry.errorDescription:=$errorInfo.errorDescription
        $logEntry.severity:=$errorInfo.severity
        $logEntry.category:=$errorInfo.errorCategory
    End if
    
    // Store in error log
    storeErrorLogEntry($logEntry)
    
    // Send real-time notifications for critical errors
    If ($errorInfo.severity="Critical")
        sendCriticalErrorNotification($logEntry)
    End if
```

## Key Features

1. **Detailed Error Information**: Retrieve comprehensive error details including multi-level descriptions
2. **Error Categorization**: Automatically categorize errors for better analysis and resolution
3. **Caching Support**: Cache error information to reduce API calls and improve performance
4. **Batch Processing**: Retrieve information for multiple errors efficiently
5. **Error Analysis**: Analyze error patterns and trends for proactive management
6. **Resolution Workflow**: Integrate with error resolution and ticketing systems
7. **Automated Monitoring**: Support for automated error monitoring and reporting
8. **Dashboard Integration**: Generate comprehensive error dashboards and reports

## Security Considerations

1. **Access Control**: Verify user permissions before allowing error information access
2. **Sensitive Data**: Ensure error messages don't expose sensitive system information
3. **Audit Logging**: Log all error information retrievals for security monitoring
4. **Rate Limiting**: Implement rate limiting to prevent abuse of error information endpoints
5. **Data Privacy**: Ensure error information complies with data privacy regulations

## Notes

- This class is specifically designed for the Odyssey API system
- The endpoint uses GET method with ErrorID and CompanyID as query parameters
- Error information is typically cached to improve performance and reduce API calls
- Ideal for error handling, debugging, and user experience improvement
- The class automatically calls the errorMessage endpoint during construction
- Results are available through the `request.run()` method
- Consider implementing error information caching for frequently accessed errors
- Error information can be used to provide better user feedback and support
- Integration with monitoring and alerting systems is recommended for production use
