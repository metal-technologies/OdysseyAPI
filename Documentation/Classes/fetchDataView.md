<!-- Type your summary here -->
# fetchDataView Class Documentation

## Overview
The `fetchDataView` class is a specialized API client for executing predefined data views through the Odyssey API system. This class provides a powerful interface to run data views and retrieve all resulting records regardless of batch size limitations, making it essential for reporting, data analysis, and comprehensive data retrieval operations.

## Class Information
- **Namespace**: `cs.OdysseyAPI.fetchDataView`
- **API Endpoint**: `/FetchData/DataView`
- **Base URL**: `https://api.blinfo.com/metaltech/FetchData/DataView`
- **HTTP Method**: POST
- **Authentication**: Requires API key and proper authentication
- **Data Retrieval**: Returns all records regardless of batch size limitations

## Properties

### Core Properties
- `request` (cs.request) - The underlying request object that handles HTTP communication
- `settings` (Object) - Configuration settings object passed to the constructor

## Constructor

```4d
Class constructor($settings : Object)
    $settings.apiURL:="https://api.blinfo.com/metaltech/FetchData/DataView"
    $settings.apiMethod:="Post"
    This.request:=cs.request.new($settings)
    This.request.dataview()
    This.settings:=$settings
```

The constructor automatically configures the API endpoint and HTTP method, creates a request object, and calls the dataview endpoint.

### Parameters
- `$settings` (Object) - A settings object, typically `cs.responseSettings.new()` containing:
  - `CompanyID` (Text) - Company identifier
  - `DataView` (Text) - Data view name/identifier to execute
  - `ParameterList` (Collection) - Collection of parameters for the data view (optional)

### Example Usage
```4d
var $settings : Object
var $dataViewAPI : cs.OdysseyAPI.fetchDataView

// Create settings object with data view parameters
$settings:=cs.responseSettings.new()
$settings.CompanyID:="ACME_CORP"
$settings.DataView:="CustomerSalesReport"
$settings.ParameterList:=New collection()

// Initialize fetch data view API client
$dataViewAPI:=cs.OdysseyAPI.fetchDataView.new($settings)
```

## Usage Examples

### Basic Data View Execution
```4d
var $settings : Object
var $dataViewAPI : cs.OdysseyAPI.fetchDataView
var $result : Object

// Initialize settings
$settings:=cs.responseSettings.new()
$settings.CompanyID:="COMP001"
$settings.DataView:="ActiveCustomersReport"
$settings.ParameterList:=New collection()

// Create data view API instance and execute
$dataViewAPI:=cs.OdysseyAPI.fetchDataView.new($settings)
$result:=$dataViewAPI.request.run()

If (Bool($result.Success))
    If ($result.data.length>0)
        ALERT("Data view executed successfully! Retrieved "+String($result.data.length)+" records.")
        
        // Process the results
        processDataViewResults($result.data)
    Else 
        ALERT("Data view executed but returned no results")
    End if
Else 
    ALERT("Data view execution failed: "+String($result.ErrorMessage))
End if
```

### Parameterized Data View Function
```4d
// Function to execute data view with parameters
Function executeDataView($dataViewName : Text; $companyID : Text; $parameters : Collection) : Object
    var $settings : Object
    var $dataViewAPI : cs.OdysseyAPI.fetchDataView
    var $result : Object
    var $executionResult : Object
    
    // Initialize execution result
    $executionResult:=New object()
    $executionResult.success:=False
    $executionResult.timestamp:=String(Current date; ISO date GMT; Current time)
    $executionResult.dataViewName:=$dataViewName
    $executionResult.companyID:=$companyID
    $executionResult.parameters:=$parameters
    
    Try
        // Validate input parameters
        If ($dataViewName="") || ($companyID="")
            $executionResult.message:="Data view name and company ID are required"
            return $executionResult
        End if
        
        // Set up data view request
        $settings:=cs.responseSettings.new()
        $settings.CompanyID:=$companyID
        $settings.DataView:=$dataViewName
        $settings.ParameterList:=$parameters
        
        // Execute data view
        $dataViewAPI:=cs.OdysseyAPI.fetchDataView.new($settings)
        $result:=$dataViewAPI.request.run()
        
        If (Bool($result.Success))
            $executionResult.success:=True
            $executionResult.data:=$result.data
            $executionResult.recordCount:=$result.data.length
            $executionResult.message:="Data view executed successfully"
            
            // Calculate execution statistics
            $executionResult.statistics:=calculateDataViewStats($result.data)
            
            // Log successful execution
            logDataViewExecution("SUCCESS"; $dataViewName; $companyID; $result.data.length)
            
        Else 
            $executionResult.message:="Data view execution failed: "+String($result.ErrorMessage)
            $executionResult.errorCode:=$result.statusCode
            
            // Log failed execution
            logDataViewExecution("FAILED"; $dataViewName; $companyID; $result.ErrorMessage)
        End if
        
    Catch
        $executionResult.message:="Data view execution error: "+Last errors[0].message
        $executionResult.exception:=True
        
        // Log execution exception
        logDataViewExecution("ERROR"; $dataViewName; $companyID; Last errors[0].message)
    End try
    
    return $executionResult
```

### Sales Report Generation
```4d
// Function to generate comprehensive sales reports
Function generateSalesReport($companyID : Text; $startDate : Date; $endDate : Date; $salesRep : Text) : Object
    var $parameters : Collection
    var $reportResult : Object
    var $reportData : Object
    
    // Build parameters for sales report data view
    $parameters:=New collection()
    $parameters.push(New object("FieldName"; "StartDate"; "Operator"; ">="; "ParameterValue"; String($startDate; ISO date GMT)))
    $parameters.push(New object("FieldName"; "EndDate"; "Operator"; "<="; "ParameterValue"; String($endDate; ISO date GMT)))
    
    If ($salesRep#"")
        $parameters.push(New object("FieldName"; "SalesRep"; "Operator"; "="; "ParameterValue"; $salesRep))
    End if
    
    // Execute sales report data view
    $reportResult:=executeDataView("SalesReport"; $companyID; $parameters)
    
    If ($reportResult.success)
        // Process and enhance report data
        $reportData:=New object()
        $reportData.reportTitle:="Sales Report"
        $reportData.dateRange:=String($startDate; System date short)+" to "+String($endDate; System date short)
        $reportData.salesRep:=($salesRep#"") ? $salesRep : "All Representatives"
        $reportData.generatedAt:=String(Current date; ISO date GMT; Current time)
        $reportData.recordCount:=$reportResult.recordCount
        $reportData.data:=$reportResult.data
        
        // Calculate report totals and summaries
        $reportData.totals:=calculateSalesTotals($reportResult.data)
        $reportData.summaries:=generateSalesSummaries($reportResult.data)
        
        $reportResult.reportData:=$reportData
        
        // Store report for future reference
        storeGeneratedReport($reportData)
    End if
    
    return $reportResult
```

### Scheduled Report Processing
```4d
// Function to process scheduled data view reports
Function processScheduledReports()
    var $schedules : Collection
    var $schedule : Object
    var $reportResult : Object
    var $summary : Object
    
    // Get all active report schedules
    $schedules:=getActiveReportSchedules()
    
    $summary:=New object()
    $summary.timestamp:=String(Current date; ISO date GMT; Current time)
    $summary.schedulesProcessed:=0
    $summary.successfulReports:=0
    $summary.failedReports:=0
    $summary.totalRecords:=0
    $summary.results:=New collection()
    
    For each ($schedule; $schedules)
        Try
            // Check if schedule is due for execution
            If (isScheduleDue($schedule))
                // Execute the scheduled data view
                $reportResult:=executeDataView(\
                    $schedule.dataViewName; \
                    $schedule.companyID; \
                    $schedule.parameters)
                
                $summary.schedulesProcessed:=$summary.schedulesProcessed+1
                
                If ($reportResult.success)
                    $summary.successfulReports:=$summary.successfulReports+1
                    $summary.totalRecords:=$summary.totalRecords+$reportResult.recordCount
                    
                    // Process report output based on schedule configuration
                    processReportOutput($schedule; $reportResult)
                    
                    // Send report if configured
                    If ($schedule.emailReport)
                        emailReport($schedule; $reportResult)
                    End if
                    
                    // Export to file if configured
                    If ($schedule.exportToFile)
                        exportReportToFile($schedule; $reportResult)
                    End if
                    
                Else 
                    $summary.failedReports:=$summary.failedReports+1
                End if
                
                $summary.results.push(New object(\
                    "scheduleID"; $schedule.id; \
                    "scheduleName"; $schedule.name; \
                    "success"; $reportResult.success; \
                    "recordCount"; $reportResult.recordCount; \
                    "message"; $reportResult.message))
                
                // Update schedule last run time
                updateScheduleLastRun($schedule.id)
                
            End if
            
        Catch
            $summary.failedReports:=$summary.failedReports+1
            
            // Log schedule processing error
            logScheduleError($schedule.id; Last errors[0].message)
        End try
        
        // Small delay between schedules
        DELAY PROCESS(Current process; 200)  // 2 second delay
    End for each
    
    // Log summary
    logScheduledReportSummary($summary)
    
    // Send admin summary if there were issues
    If ($summary.failedReports>0)
        sendAdminReportSummary($summary)
    End if
```

### Data Export Function
```4d
// Function to export data view results to various formats
Function exportDataView($dataViewName : Text; $companyID : Text; $parameters : Collection; $exportFormat : Text; $filePath : Text) : Object
    var $exportResult : Object
    var $dataViewResult : Object
    var $exportedFile : 4D.File
    
    $exportResult:=New object()
    $exportResult.success:=False
    $exportResult.dataViewName:=$dataViewName
    $exportResult.exportFormat:=$exportFormat
    $exportResult.filePath:=$filePath
    
    Try
        // Execute data view
        $dataViewResult:=executeDataView($dataViewName; $companyID; $parameters)
        
        If ($dataViewResult.success)
            // Export data based on requested format
            Case of 
                : ($exportFormat="CSV")
                    $exportResult:=exportToCSV($dataViewResult.data; $filePath)
                    
                : ($exportFormat="Excel")
                    $exportResult:=exportToExcel($dataViewResult.data; $filePath)
                    
                : ($exportFormat="JSON")
                    $exportResult:=exportToJSON($dataViewResult.data; $filePath)
                    
                : ($exportFormat="PDF")
                    $exportResult:=exportToPDF($dataViewResult.data; $filePath)
                    
                Else 
                    $exportResult.message:="Unsupported export format: "+$exportFormat
                    return $exportResult
            End case
            
            If ($exportResult.success)
                $exportResult.recordCount:=$dataViewResult.recordCount
                $exportResult.message:="Data view exported successfully to "+$exportFormat
                
                // Verify exported file
                $exportedFile:=File($filePath)
                $exportResult.fileSize:=$exportedFile.size
                $exportResult.fileExists:=$exportedFile.exists
            End if
            
        Else 
            $exportResult.message:="Data view execution failed: "+$dataViewResult.message
        End if
        
    Catch
        $exportResult.message:="Export error: "+Last errors[0].message
        $exportResult.exception:=True
    End try
    
    return $exportResult
```

### Real-time Dashboard Data
```4d
// Function to fetch real-time dashboard data
Function fetchDashboardData($companyID : Text; $dashboardConfig : Object) : Object
    var $dashboardData : Object
    var $widget : Object
    var $widgetData : Object
    var $widgetName : Text
    
    $dashboardData:=New object()
    $dashboardData.companyID:=$companyID
    $dashboardData.timestamp:=String(Current date; ISO date GMT; Current time)
    $dashboardData.widgets:=New object()
    $dashboardData.success:=True
    $dashboardData.errors:=New collection()
    
    // Process each dashboard widget
    For each ($widgetName; $dashboardConfig.widgets)
        $widget:=$dashboardConfig.widgets[$widgetName]
        
        Try
            // Execute data view for this widget
            $widgetData:=executeDataView(\
                $widget.dataViewName; \
                $companyID; \
                $widget.parameters)
            
            If ($widgetData.success)
                // Process widget-specific data transformation
                $dashboardData.widgets[$widgetName]:=processWidgetData($widget; $widgetData.data)
            Else 
                $dashboardData.widgets[$widgetName]:=New object(\
                    "error"; True; \
                    "message"; $widgetData.message)
                
                $dashboardData.errors.push(New object(\
                    "widget"; $widgetName; \
                    "error"; $widgetData.message))
            End if
            
        Catch
            $dashboardData.widgets[$widgetName]:=New object(\
                "error"; True; \
                "message"; "Widget processing exception: "+Last errors[0].message)
            
            $dashboardData.errors.push(New object(\
                "widget"; $widgetName; \
                "error"; Last errors[0].message))
        End try
    End for each
    
    // Set overall success status
    $dashboardData.success:=($dashboardData.errors.length=0)
    $dashboardData.partialSuccess:=($dashboardData.errors.length>0) && ($dashboardData.errors.length<OB Keys($dashboardConfig.widgets).length)
    
    return $dashboardData
```

### Data View Performance Analysis
```4d
// Function to analyze data view performance
Function analyzeDataViewPerformance($dataViewName : Text; $companyID : Text; $parameters : Collection) : Object
    var $performanceAnalysis : Object
    var $startTime; $endTime : Real
    var $dataViewResult : Object
    var $memoryBefore; $memoryAfter : Real
    
    $performanceAnalysis:=New object()
    $performanceAnalysis.dataViewName:=$dataViewName
    $performanceAnalysis.companyID:=$companyID
    $performanceAnalysis.timestamp:=String(Current date; ISO date GMT; Current time)
    
    // Capture initial metrics
    $startTime:=Milliseconds
    $memoryBefore:=Get_Memory_Usage()
    
    // Execute data view
    $dataViewResult:=executeDataView($dataViewName; $companyID; $parameters)
    
    // Capture final metrics
    $endTime:=Milliseconds
    $memoryAfter:=Get_Memory_Usage()
    
    // Calculate performance metrics
    $performanceAnalysis.executionTime:=($endTime-$startTime)/1000  // Convert to seconds
    $performanceAnalysis.memoryUsage:=$memoryAfter-$memoryBefore
    $performanceAnalysis.success:=$dataViewResult.success
    
    If ($dataViewResult.success)
        $performanceAnalysis.recordCount:=$dataViewResult.recordCount
        $performanceAnalysis.recordsPerSecond:=$dataViewResult.recordCount/$performanceAnalysis.executionTime
        $performanceAnalysis.memoryPerRecord:=$performanceAnalysis.memoryUsage/$dataViewResult.recordCount
        
        // Categorize performance
        Case of 
            : ($performanceAnalysis.executionTime<2)
                $performanceAnalysis.performanceRating:="Excellent"
            : ($performanceAnalysis.executionTime<5)
                $performanceAnalysis.performanceRating:="Good"
            : ($performanceAnalysis.executionTime<10)
                $performanceAnalysis.performanceRating:="Fair"
            Else 
                $performanceAnalysis.performanceRating:="Poor"
        End case
        
        // Store performance metrics for historical analysis
        storePerformanceMetrics($performanceAnalysis)
    Else 
        $performanceAnalysis.error:=$dataViewResult.message
    End if
    
    return $performanceAnalysis
```

### Cached Data View Results
```4d
// Function to execute data view with caching support
Function executeDataViewCached($dataViewName : Text; $companyID : Text; $parameters : Collection; $cacheTimeout : Integer) : Object
    var $cacheKey : Text
    var $cachedResult : Object
    var $dataViewResult : Object
    
    // Generate cache key from data view name, company, and parameters
    $cacheKey:=generateDataViewCacheKey($dataViewName; $companyID; $parameters)
    
    // Check cache first
    $cachedResult:=getFromDataViewCache($cacheKey)
    
    If ($cachedResult#Null) && (isCacheValid($cachedResult; $cacheTimeout))
        // Return cached result
        $cachedResult.fromCache:=True
        $cachedResult.cacheHit:=True
        $cachedResult.cacheAge:=calculateCacheAge($cachedResult.cachedAt)
        return $cachedResult
    Else 
        // Execute fresh data view
        $dataViewResult:=executeDataView($dataViewName; $companyID; $parameters)
        
        If ($dataViewResult.success)
            // Cache successful results
            $dataViewResult.cachedAt:=String(Current date; ISO date GMT; Current time)
            $dataViewResult.fromCache:=False
            $dataViewResult.cacheHit:=False
            
            storeInDataViewCache($cacheKey; $dataViewResult; $cacheTimeout)
        End if
        
        return $dataViewResult
    End if
```

## Integration Patterns

### REST API Wrapper
```4d
// RESTful data view endpoint wrapper
Function handleRESTDataView($request : Object) : Object
    var $dataViewName; $companyID : Text
    var $parameters : Collection
    var $dataViewResult : Object
    var $response : Object
    
    // Extract parameters from REST request
    $dataViewName:=$request.body.dataViewName
    $companyID:=$request.body.companyID
    $parameters:=$request.body.parameters
    
    // Validate request
    If ($dataViewName="") || ($companyID="")
        $response:=New object("success"; False; "error"; "Data view name and company ID are required")
        return $response
    End if
    
    // Execute data view
    $dataViewResult:=executeDataViewCached($dataViewName; $companyID; $parameters; 300)  // 5 minute cache
    
    // Format response
    $response:=New object()
    $response.success:=$dataViewResult.success
    $response.timestamp:=String(Current date; ISO date GMT; Current time)
    $response.dataView:=$dataViewName
    $response.company:=$companyID
    $response.fromCache:=$dataViewResult.fromCache
    
    If ($dataViewResult.success)
        $response.data:=$dataViewResult.data
        $response.recordCount:=$dataViewResult.recordCount
        $response.message:="Data view executed successfully"
        
        If ($dataViewResult.statistics#Null)
            $response.statistics:=$dataViewResult.statistics
        End if
    Else 
        $response.error:=$dataViewResult.message
        
        If ($dataViewResult.exception)
            $response.exceptionOccurred:=True
        End if
    End if
    
    return $response
```

### Business Intelligence Integration
```4d
// Function to integrate with BI systems
Function prepareDataForBI($dataViewName : Text; $companyID : Text; $parameters : Collection; $biConfig : Object) : Object
    var $dataViewResult : Object
    var $biData : Object
    var $transformedData : Collection
    
    // Execute data view
    $dataViewResult:=executeDataView($dataViewName; $companyID; $parameters)
    
    $biData:=New object()
    $biData.success:=False
    
    If ($dataViewResult.success)
        // Transform data according to BI requirements
        $transformedData:=transformDataForBI($dataViewResult.data; $biConfig.transformations)
        
        $biData.success:=True
        $biData.data:=$transformedData
        $biData.metadata:=New object(\
            "dataViewName"; $dataViewName; \
            "companyID"; $companyID; \
            "recordCount"; $transformedData.length; \
            "extractedAt"; String(Current date; ISO date GMT; Current time); \
            "columns"; extractColumnMetadata($transformedData))
        
        // Apply BI-specific formatting
        If ($biConfig.format="star_schema")
            $biData:=convertToStarSchema($biData)
        End if
        
        If ($biConfig.format="dimensional")
            $biData:=convertToDimensionalModel($biData)
        End if
        
    Else 
        $biData.error:=$dataViewResult.message
    End if
    
    return $biData
```

## Performance Considerations

1. **Large Datasets**: The API returns all records regardless of batch size - consider memory usage for large data views
2. **Caching Strategy**: Implement intelligent caching for frequently accessed data views
3. **Parameter Optimization**: Use specific parameters to limit result sets when possible
4. **Execution Monitoring**: Monitor data view execution times and optimize slow-performing views
5. **Memory Management**: Implement proper memory management for large result sets

## Security Considerations

1. **Access Control**: Verify user permissions before allowing data view execution
2. **Parameter Validation**: Validate and sanitize all input parameters
3. **Data Privacy**: Ensure data view results comply with data privacy regulations
4. **Audit Logging**: Log all data view executions for compliance and security monitoring
5. **Rate Limiting**: Implement rate limiting for resource-intensive data views

## Key Features

1. **Complete Data Retrieval**: Returns all records regardless of batch size limitations
2. **Parameterized Execution**: Support for dynamic parameters in data views
3. **Comprehensive Reporting**: Ideal for generating complete reports and analytics
4. **Caching Support**: Optional caching to improve performance for repeated executions
5. **Export Integration**: Easy integration with various export formats
6. **Performance Monitoring**: Built-in support for performance analysis and optimization
7. **Scheduled Execution**: Support for automated scheduled report generation
8. **Dashboard Integration**: Perfect for real-time dashboard data feeds

## Notes

- This class is specifically designed for the Odyssey API system
- The endpoint requires CompanyID, DataView, and optional ParameterList in the request body
- All records are returned regardless of batch size defined in the data view
- Ideal for comprehensive reporting and data analysis scenarios
- The class automatically calls the dataview endpoint during construction
- Results are available through the `request.run()` method
- Consider implementing caching for frequently executed data views
- Monitor memory usage when working with large datasets
- Always implement proper error handling and user feedback for long-running operations