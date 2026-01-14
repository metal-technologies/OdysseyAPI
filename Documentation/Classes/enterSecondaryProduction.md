<!-- Type your summary here -->
# enterSecondaryProduction Class Documentation

## Overview
The `enterSecondaryProduction` class is a specialized API client for recording secondary production entries through the Odyssey API system. This class provides an interface to write new production records to specified tables, making it essential for manufacturing operations, production tracking, and secondary process documentation in industrial applications.

## Class Information
- **Namespace**: `cs.OdysseyAPI.Secondary`
- **API Endpoint**: `/Production/Entry/Secondary`
- **Base URL**: `https://api.blinfo.com/metaltech/Production/Entry/Secondary`
- **HTTP Method**: POST
- **Authentication**: Requires API key and proper authentication

## Properties

### Core Properties
- `request` (cs.request) - The underlying request object that handles HTTP communication
- `settings` (Object) - Configuration settings object passed to the constructor

## Constructor

```4d
Class constructor($settings : Object)
    $settings.apiURL:="https://api.blinfo.com/metaltech/Production/Entry/Secondary"
    $settings.apiMethod:="POST"
    This.request:=cs.request.new($settings)
    This.request.secondary()
    This.settings:=$settings
```

The constructor automatically configures the API endpoint and HTTP method, creates a request object, and calls the secondary endpoint.

### Parameters
- `$settings` (Object) - A settings object, typically `cs.responseSettings.new()` containing:
  - `CompanyID` (Text) - Company identifier
  - `DateFormat` (Text) - Date format specification for production dates
  - `DataList` (Collection) - Collection of production data records to enter

### Example Usage
```4d
var $settings : Object
var $secondaryAPI : cs.OdysseyAPI.Secondary

// Create settings object with production parameters
$settings:=cs.responseSettings.new()
$settings.CompanyID:="MANUFACTURING_CORP"
$settings.DateFormat:="YYYY-MM-DD"
$settings.DataList:=New collection()

// Initialize secondary production API client
$secondaryAPI:=cs.OdysseyAPI.Secondary.new($settings)
```

## Usage Examples

### Basic Secondary Production Entry
```4d
var $settings : Object
var $secondaryAPI : cs.OdysseyAPI.Secondary
var $result : Object
var $productionData : Collection

// Initialize settings
$settings:=cs.responseSettings.new()
$settings.CompanyID:="COMP001"
$settings.DateFormat:="YYYY-MM-DD HH:MM:SS"

// Build production data
$productionData:=New collection()
$productionData.push(New object(\
    "PartNumber"; "PART-001"; \
    "Quantity"; 100; \
    "ProductionDate"; "2025-01-27 14:30:00"; \
    "WorkCenter"; "WC-SEC-001"; \
    "Operator"; "JOHN_DOE"; \
    "ShiftCode"; "DAY"))

$productionData.push(New object(\
    "PartNumber"; "PART-002"; \
    "Quantity"; 75; \
    "ProductionDate"; "2025-01-27 15:15:00"; \
    "WorkCenter"; "WC-SEC-002"; \
    "Operator"; "JANE_SMITH"; \
    "ShiftCode"; "DAY"))

$settings.DataList:=$productionData

// Create secondary production API instance and execute
$secondaryAPI:=cs.OdysseyAPI.Secondary.new($settings)
$result:=$secondaryAPI.request.run()

If (Bool($result.Success))
    ALERT("Secondary production entries recorded successfully!")
Else 
    ALERT("Production entry failed: "+String($result.ErrorMessage))
End if
```

### Production Entry Function
```4d
// Function to record secondary production data
Function recordSecondaryProduction($companyID : Text; $productionEntries : Collection; $dateFormat : Text) : Object
    var $settings : Object
    var $secondaryAPI : cs.OdysseyAPI.Secondary
    var $result : Object
    var $entryResult : Object
    
    // Initialize entry result
    $entryResult:=New object()
    $entryResult.success:=False
    $entryResult.timestamp:=String(Current date; ISO date GMT; Current time)
    $entryResult.companyID:=$companyID
    $entryResult.entriesSubmitted:=$productionEntries.length
    
    Try
        // Validate input parameters
        If ($companyID="") || ($productionEntries.length=0)
            $entryResult.message:="Company ID and production entries are required"
            return $entryResult
        End if
        
        // Validate production entries
        var $validationResult : Object
        $validationResult:=validateProductionEntries($productionEntries)
        
        If (Not($validationResult.valid))
            $entryResult.message:="Production entry validation failed: "+$validationResult.errors.join(", ")
            $entryResult.validationErrors:=$validationResult.errors
            return $entryResult
        End if
        
        // Set up production entry request
        $settings:=cs.responseSettings.new()
        $settings.CompanyID:=$companyID
        $settings.DateFormat:=$dateFormat
        $settings.DataList:=$productionEntries
        
        // Record production entries
        $secondaryAPI:=cs.OdysseyAPI.Secondary.new($settings)
        $result:=$secondaryAPI.request.run()
        
        If (Bool($result.Success))
            $entryResult.success:=True
            $entryResult.message:="Secondary production entries recorded successfully"
            $entryResult.entriesProcessed:=$result.EntriesProcessed
            $entryResult.entriesRejected:=$result.EntriesRejected
            $entryResult.batchID:=$result.BatchID
            
            // Log successful production entry
            logProductionEntry("SUCCESS"; "Secondary"; $companyID; $productionEntries.length)
            
            // Update production metrics
            updateProductionMetrics($companyID; "Secondary"; $productionEntries)
            
        Else 
            $entryResult.message:="Production entry failed: "+String($result.ErrorMessage)
            $entryResult.errorCode:=$result.statusCode
            $entryResult.entryErrors:=$result.EntryErrors
            
            // Log failed production entry
            logProductionEntry("FAILED"; "Secondary"; $companyID; $result.ErrorMessage)
        End if
        
    Catch
        $entryResult.message:="Production entry error: "+Last errors[0].message
        $entryResult.exception:=True
        
        // Log production entry exception
        logProductionEntry("ERROR"; "Secondary"; $companyID; Last errors[0].message)
    End try
    
    return $entryResult
```

### Real-time Production Data Collection
```4d
// Function to collect and submit real-time production data
Function collectProductionData($workCenter : Text; $companyID : Text) : Object
    var $collectionResult : Object
    var $productionEntries : Collection
    var $machineData : Collection
    var $machine : Object
    var $productionEntry : Object
    
    $collectionResult:=New object()
    $collectionResult.success:=False
    $collectionResult.workCenter:=$workCenter
    $collectionResult.timestamp:=String(Current date; ISO date GMT; Current time)
    
    Try
        // Get current production data from machines/workstations
        $machineData:=getMachineProductionData($workCenter)
        
        If ($machineData.length>0)
            $productionEntries:=New collection()
            
            For each ($machine; $machineData)
                // Build production entry for each machine
                $productionEntry:=New object()
                $productionEntry.PartNumber:=$machine.currentPart
                $productionEntry.Quantity:=$machine.completedQuantity
                $productionEntry.ProductionDate:=String(Current date; ISO date GMT; Current time)
                $productionEntry.WorkCenter:=$workCenter
                $productionEntry.MachineID:=$machine.machineID
                $productionEntry.Operator:=$machine.currentOperator
                $productionEntry.ShiftCode:=getCurrentShift()
                $productionEntry.CycleTime:=$machine.averageCycleTime
                $productionEntry.QualityCode:=$machine.qualityStatus
                
                // Add optional production metrics
                If ($machine.temperature#Null)
                    $productionEntry.Temperature:=$machine.temperature
                End if
                If ($machine.pressure#Null)
                    $productionEntry.Pressure:=$machine.pressure
                End if
                If ($machine.speed#Null)
                    $productionEntry.Speed:=$machine.speed
                End if
                
                $productionEntries.push($productionEntry)
            End for each
            
            // Submit production data
            var $entryResult : Object
            $entryResult:=recordSecondaryProduction($companyID; $productionEntries; "YYYY-MM-DD HH:MM:SS")
            
            $collectionResult.success:=$entryResult.success
            $collectionResult.message:=$entryResult.message
            $collectionResult.entriesSubmitted:=$productionEntries.length
            $collectionResult.entriesProcessed:=$entryResult.entriesProcessed
            
            If ($entryResult.success)
                // Reset machine counters after successful submission
                resetMachineCounters($workCenter)
            End if
            
        Else 
            $collectionResult.message:="No production data available from work center"
        End if
        
    Catch
        $collectionResult.message:="Production data collection error: "+Last errors[0].message
        $collectionResult.exception:=True
    End try
    
    return $collectionResult
```

### Shift Production Summary
```4d
// Function to record shift production summary
Function recordShiftSummary($shiftCode : Text; $workCenter : Text; $companyID : Text; $shiftStart : Text; $shiftEnd : Text) : Object
    var $shiftSummary : Object
    var $shiftData : Collection
    var $productionTotals : Object
    var $part : Text
    var $entryResult : Object
    
    $shiftSummary:=New object()
    $shiftSummary.success:=False
    $shiftSummary.shiftCode:=$shiftCode
    $shiftSummary.workCenter:=$workCenter
    $shiftSummary.shiftStart:=$shiftStart
    $shiftSummary.shiftEnd:=$shiftEnd
    
    Try
        // Collect shift production totals by part
        $productionTotals:=getShiftProductionTotals($workCenter; $shiftStart; $shiftEnd)
        
        If (OB Keys($productionTotals).length>0)
            $shiftData:=New collection()
            
            // Create summary entry for each part produced
            For each ($part; $productionTotals)
                var $summaryEntry : Object
                $summaryEntry:=New object()
                $summaryEntry.PartNumber:=$part
                $summaryEntry.Quantity:=$productionTotals[$part].totalQuantity
                $summaryEntry.ProductionDate:=$shiftEnd
                $summaryEntry.WorkCenter:=$workCenter
                $summaryEntry.ShiftCode:=$shiftCode
                $summaryEntry.EntryType:="SHIFT_SUMMARY"
                $summaryEntry.UnitsPerHour:=$productionTotals[$part].averageRate
                $summaryEntry.DowntimeMinutes:=$productionTotals[$part].downtime
                $summaryEntry.QualityPercent:=$productionTotals[$part].qualityRate
                
                $shiftData.push($summaryEntry)
            End for each
            
            // Record shift summary
            $entryResult:=recordSecondaryProduction($companyID; $shiftData; "YYYY-MM-DD HH:MM:SS")
            
            $shiftSummary.success:=$entryResult.success
            $shiftSummary.message:=$entryResult.message
            $shiftSummary.summaryEntries:=$shiftData.length
            $shiftSummary.totalQuantity:=calculateTotalQuantity($shiftData)
            
            If ($entryResult.success)
                // Generate shift report
                generateShiftReport($shiftSummary; $shiftData)
                
                // Update shift metrics
                updateShiftMetrics($workCenter; $shiftCode; $shiftSummary)
            End if
            
        Else 
            $shiftSummary.message:="No production data found for shift"
        End if
        
    Catch
        $shiftSummary.message:="Shift summary error: "+Last errors[0].message
        $shiftSummary.exception:=True
    End try
    
    return $shiftSummary
```

### Batch Production Processing
```4d
// Function to process batch production data
Function processBatchProduction($batchFiles : Collection; $companyID : Text) : Collection
    var $batchResults : Collection
    var $batchFile : Object
    var $fileContent : Text
    var $productionData : Collection
    var $entryResult : Object
    var $i : Integer
    
    $batchResults:=New collection()
    
    For ($i; 0; $batchFiles.length-1)
        $batchFile:=$batchFiles[$i]
        
        Try
            // Read production data from file
            var $file : 4D.File
            $file:=File($batchFile.filePath)
            
            If ($file.exists)
                $fileContent:=$file.getText()
                
                // Parse production data based on file format
                Case of 
                    : ($batchFile.format="CSV")
                        $productionData:=parseCSVProductionData($fileContent)
                    : ($batchFile.format="JSON")
                        $productionData:=parseJSONProductionData($fileContent)
                    : ($batchFile.format="XML")
                        $productionData:=parseXMLProductionData($fileContent)
                    Else 
                        $productionData:=New collection()
                End case
                
                If ($productionData.length>0)
                    // Process production entries
                    $entryResult:=recordSecondaryProduction($companyID; $productionData; "YYYY-MM-DD HH:MM:SS")
                    
                    $entryResult.fileName:=$batchFile.fileName
                    $entryResult.filePath:=$batchFile.filePath
                    $entryResult.fileFormat:=$batchFile.format
                    
                    If ($entryResult.success)
                        // Move file to processed folder
                        moveToProcessedFolder($file)
                    Else 
                        // Move file to error folder
                        moveToErrorFolder($file)
                    End if
                Else 
                    $entryResult:=New object(\
                        "success"; False; \
                        "fileName"; $batchFile.fileName; \
                        "message"; "No valid production data found in file")
                End if
            Else 
                $entryResult:=New object(\
                    "success"; False; \
                    "fileName"; $batchFile.fileName; \
                    "message"; "File not found: "+$batchFile.filePath)
            End if
            
        Catch
            $entryResult:=New object(\
                "success"; False; \
                "fileName"; $batchFile.fileName; \
                "message"; "Batch processing error: "+Last errors[0].message; \
                "exception"; True)
        End try
        
        $batchResults.push($entryResult)
        
        // Add delay between file processing
        DELAY PROCESS(Current process; 100)  // 1 second delay
    End for
    
    return $batchResults
```

### Quality Control Integration
```4d
// Function to record production with quality control data
Function recordProductionWithQuality($productionData : Object; $qualityData : Object; $companyID : Text) : Object
    var $qualityResult : Object
    var $enhancedEntry : Collection
    var $productionEntry : Object
    var $entryResult : Object
    
    $qualityResult:=New object()
    $qualityResult.success:=False
    $qualityResult.timestamp:=String(Current date; ISO date GMT; Current time)
    
    Try
        // Validate quality data
        If (Not(validateQualityData($qualityData)))
            $qualityResult.message:="Quality data validation failed"
            return $qualityResult
        End if
        
        // Enhance production entry with quality information
        $enhancedEntry:=New collection()
        $productionEntry:=OB Copy($productionData)
        
        // Add quality metrics
        $productionEntry.QualityGrade:=$qualityData.grade
        $productionEntry.InspectionDate:=String(Current date; ISO date GMT; Current time)
        $productionEntry.Inspector:=$qualityData.inspector
        $productionEntry.QualityNotes:=$qualityData.notes
        $productionEntry.PassedInspection:=$qualityData.passed
        
        // Add dimensional measurements if available
        If ($qualityData.measurements#Null)
            $productionEntry.Measurements:=$qualityData.measurements
        End if
        
        // Add defect information if any
        If ($qualityData.defects#Null)
            $productionEntry.Defects:=$qualityData.defects
            $productionEntry.DefectCount:=$qualityData.defects.length
        End if
        
        $enhancedEntry.push($productionEntry)
        
        // Record enhanced production entry
        $entryResult:=recordSecondaryProduction($companyID; $enhancedEntry; "YYYY-MM-DD HH:MM:SS")
        
        $qualityResult.success:=$entryResult.success
        $qualityResult.message:=$entryResult.message
        $qualityResult.productionEntry:=$productionEntry
        
        If ($entryResult.success)
            // Update quality metrics
            updateQualityMetrics($companyID; $productionData.PartNumber; $qualityData)
            
            // Generate quality report if needed
            If (Not($qualityData.passed))
                generateQualityAlert($productionEntry; $qualityData)
            End if
        End if
        
    Catch
        $qualityResult.message:="Quality integration error: "+Last errors[0].message
        $qualityResult.exception:=True
    End try
    
    return $qualityResult
```

### Production Dashboard Integration
```4d
// Function to update production dashboard with real-time data
Function updateProductionDashboard($companyID : Text; $workCenters : Collection) : Object
    var $dashboardUpdate : Object
    var $workCenter : Text
    var $productionData : Object
    var $dashboardData : Object
    
    $dashboardUpdate:=New object()
    $dashboardUpdate.success:=True
    $dashboardUpdate.timestamp:=String(Current date; ISO date GMT; Current time)
    $dashboardUpdate.workCenterData:=New object()
    $dashboardUpdate.overallMetrics:=New object()
    
    Try
        // Collect current production data for each work center
        For each ($workCenter; $workCenters)
            $productionData:=collectProductionData($workCenter; $companyID)
            
            If ($productionData.success)
                // Calculate real-time metrics
                $dashboardData:=New object()
                $dashboardData.currentProduction:=$productionData.entriesProcessed
                $dashboardData.efficiency:=calculateWorkCenterEfficiency($workCenter)
                $dashboardData.qualityRate:=calculateQualityRate($workCenter)
                $dashboardData.downtime:=getCurrentDowntime($workCenter)
                $dashboardData.lastUpdate:=$productionData.timestamp
                
                $dashboardUpdate.workCenterData[$workCenter]:=$dashboardData
            End if
        End for each
        
        // Calculate overall metrics
        $dashboardUpdate.overallMetrics.totalProduction:=calculateTotalProduction($dashboardUpdate.workCenterData)
        $dashboardUpdate.overallMetrics.averageEfficiency:=calculateAverageEfficiency($dashboardUpdate.workCenterData)
        $dashboardUpdate.overallMetrics.overallQualityRate:=calculateOverallQualityRate($dashboardUpdate.workCenterData)
        $dashboardUpdate.overallMetrics.activeMachines:=countActiveMachines($workCenters)
        
        // Store dashboard data
        storeDashboardData($dashboardUpdate)
        
        // Send real-time updates to connected clients
        broadcastDashboardUpdate($dashboardUpdate)
        
    Catch
        $dashboardUpdate.success:=False
        $dashboardUpdate.message:="Dashboard update error: "+Last errors[0].message
        $dashboardUpdate.exception:=True
    End try
    
    return $dashboardUpdate
```

## Integration Patterns

### Manufacturing Execution System (MES) Integration
```4d
// Function to integrate with MES systems
Function integrateWithMES($mesData : Object; $companyID : Text) : Object
    var $mesIntegration : Object
    var $productionEntries : Collection
    var $mesEntry : Object
    var $productionEntry : Object
    var $entryResult : Object
    
    $mesIntegration:=New object()
    $mesIntegration.success:=False
    $mesIntegration.mesSystem:=$mesData.systemName
    $mesIntegration.timestamp:=String(Current date; ISO date GMT; Current time)
    
    Try
        // Transform MES data to production entries
        $productionEntries:=New collection()
        
        For each ($mesEntry; $mesData.productionEvents)
            $productionEntry:=New object()
            $productionEntry.PartNumber:=$mesEntry.partNumber
            $productionEntry.Quantity:=$mesEntry.quantity
            $productionEntry.ProductionDate:=$mesEntry.eventTimestamp
            $productionEntry.WorkCenter:=$mesEntry.workstation
            $productionEntry.Operator:=$mesEntry.operatorID
            $productionEntry.ShiftCode:=$mesEntry.shift
            $productionEntry.MESEventID:=$mesEntry.eventID
            $productionEntry.MESBatchID:=$mesEntry.batchID
            
            // Add MES-specific data
            If ($mesEntry.routingStep#Null)
                $productionEntry.RoutingStep:=$mesEntry.routingStep
            End if
            If ($mesEntry.setupTime#Null)
                $productionEntry.SetupTime:=$mesEntry.setupTime
            End if
            If ($mesEntry.runTime#Null)
                $productionEntry.RunTime:=$mesEntry.runTime
            End if
            
            $productionEntries.push($productionEntry)
        End for each
        
        // Submit to Odyssey API
        $entryResult:=recordSecondaryProduction($companyID; $productionEntries; "YYYY-MM-DD HH:MM:SS")
        
        $mesIntegration.success:=$entryResult.success
        $mesIntegration.message:=$entryResult.message
        $mesIntegration.entriesProcessed:=$entryResult.entriesProcessed
        
        If ($entryResult.success)
            // Acknowledge successful integration back to MES
            acknowledgeMESIntegration($mesData.systemName; $mesData.batchID)
        End if
        
    Catch
        $mesIntegration.message:="MES integration error: "+Last errors[0].message
        $mesIntegration.exception:=True
    End try
    
    return $mesIntegration
```

### IoT Sensor Integration
```4d
// Function to process IoT sensor data for production tracking
Function processIoTProductionData($sensorData : Collection; $companyID : Text) : Object
    var $iotProcessing : Object
    var $sensor : Object
    var $productionEntries : Collection
    var $aggregatedData : Object
    var $entryResult : Object
    
    $iotProcessing:=New object()
    $iotProcessing.success:=False
    $iotProcessing.sensorsProcessed:=0
    $iotProcessing.timestamp:=String(Current date; ISO date GMT; Current time)
    
    Try
        // Aggregate sensor data by work center and time period
        $aggregatedData:=aggregateSensorData($sensorData)
        
        $productionEntries:=New collection()
        
        For each ($sensor; $aggregatedData.workCenters)
            // Convert sensor readings to production entries
            If ($sensor.productionCount>0)
                var $productionEntry : Object
                $productionEntry:=New object()
                $productionEntry.PartNumber:=$sensor.currentPart
                $productionEntry.Quantity:=$sensor.productionCount
                $productionEntry.ProductionDate:=$sensor.lastReading
                $productionEntry.WorkCenter:=$sensor.workCenterID
                $productionEntry.SensorID:=$sensor.sensorID
                $productionEntry.DataSource:="IoT_SENSOR"
                
                // Add sensor metrics
                $productionEntry.Temperature:=$sensor.averageTemperature
                $productionEntry.Vibration:=$sensor.averageVibration
                $productionEntry.CycleTime:=$sensor.averageCycleTime
                $productionEntry.EnergyConsumption:=$sensor.totalEnergy
                
                $productionEntries.push($productionEntry)
                $iotProcessing.sensorsProcessed:=$iotProcessing.sensorsProcessed+1
            End if
        End for each
        
        If ($productionEntries.length>0)
            // Submit aggregated IoT data
            $entryResult:=recordSecondaryProduction($companyID; $productionEntries; "YYYY-MM-DD HH:MM:SS")
            
            $iotProcessing.success:=$entryResult.success
            $iotProcessing.message:=$entryResult.message
            $iotProcessing.entriesSubmitted:=$productionEntries.length
        Else 
            $iotProcessing.message:="No production data found in sensor readings"
        End if
        
    Catch
        $iotProcessing.message:="IoT processing error: "+Last errors[0].message
        $iotProcessing.exception:=True
    End try
    
    return $iotProcessing
```

## Security Considerations

1. **Data Validation**: Validate all production data before submission to prevent data corruption
2. **Access Control**: Verify operator permissions before allowing production entries
3. **Audit Logging**: Log all production entries with user and timestamp information
4. **Data Integrity**: Ensure production data accuracy and prevent duplicate entries
5. **System Integration**: Secure integration with manufacturing systems and IoT devices

## Key Features

1. **Production Recording**: Record secondary production operations and quantities
2. **Real-time Data**: Support for real-time production data collection and submission
3. **Batch Processing**: Handle multiple production entries in a single operation
4. **Quality Integration**: Integrate production data with quality control information
5. **MES Integration**: Seamless integration with Manufacturing Execution Systems
6. **IoT Support**: Process and record data from IoT sensors and smart manufacturing devices
7. **Shift Tracking**: Support for shift-based production summaries and reporting
8. **Dashboard Integration**: Real-time updates for production monitoring dashboards

## Notes

- This class is specifically designed for the Odyssey API system
- The endpoint requires CompanyID, DateFormat, and DataList in the request body
- Designed for secondary production processes and manufacturing operations
- Ideal for recording completed production, work-in-process tracking, and quality data
- The class automatically calls the secondary endpoint during construction
- Results are available through the `request.run()` method
- Consider implementing real-time data collection for continuous production monitoring
- Always validate production data accuracy and implement proper error handling
- Integration with manufacturing systems should include proper data transformation and validation
