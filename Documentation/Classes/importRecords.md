<!-- Type your summary here -->
# importRecords Class Documentation

## Overview
The `importRecords` class is a specialized API client for bulk data import operations through the Odyssey API system. This class provides a robust interface to import large datasets into specified database tables using predefined Odyssey Import Definitions, making it essential for data migration, bulk updates, and automated data synchronization workflows.

## Class Information
- **Namespace**: `cs.OdysseyAPI.ImportRecords`
- **API Endpoint**: `/Record/Import`
- **Base URL**: `https://api.blinfo.com/metaltech/Record/Import`
- **HTTP Method**: POST
- **Authentication**: Requires API key and proper authentication

## Properties

### Core Properties
- `request` (cs.request) - The underlying request object that handles HTTP communication
- `settings` (Object) - Configuration settings object passed to the constructor

## Constructor

```4d
Class constructor($settings : Object)
    $settings.apiURL:="https://api.blinfo.com/metaltech/Record/Import"
    $settings.apiMethod:="POST"
    This.request:=cs.request.new($settings)
    This.request.importRecords()
    This.settings:=$settings
```

The constructor automatically configures the API endpoint and HTTP method, creates a request object, and calls the importRecords endpoint.

### Parameters
- `$settings` (Object) - A settings object, typically `cs.responseSettings.new()` containing:
  - `CompanyID` (Text) - Company identifier
  - `ProfileID` (Text) - Import profile/definition identifier
  - `SourceFileData` (Text) - The actual data to import (CSV, XML, etc.)

### Example Usage
```4d
var $settings : Object
var $importAPI : cs.OdysseyAPI.ImportRecords

// Create settings object with import parameters
$settings:=cs.responseSettings.new()
$settings.CompanyID:="ACME_CORP"
$settings.ProfileID:="CUSTOMER_IMPORT_PROFILE"
$settings.SourceFileData:="Name,Email,Phone\nJohn Doe,john@example.com,555-0123"

// Initialize import API client
$importAPI:=cs.OdysseyAPI.ImportRecords.new($settings)
```

## Usage Examples

### Basic CSV Data Import
```4d
var $settings : Object
var $importAPI : cs.OdysseyAPI.ImportRecords
var $result : Object
var $csvData : Text

// Prepare CSV data
$csvData:="FirstName,LastName,Email,Phone,Company\n"
$csvData:=$csvData+"John,Doe,john.doe@example.com,555-0123,Acme Corp\n"
$csvData:=$csvData+"Jane,Smith,jane.smith@example.com,555-0124,Tech Solutions\n"
$csvData:=$csvData+"Mike,Johnson,mike.johnson@example.com,555-0125,Global Industries"

// Initialize settings
$settings:=cs.responseSettings.new()
$settings.CompanyID:="COMP001"
$settings.ProfileID:="CUSTOMER_CSV_IMPORT"
$settings.SourceFileData:=$csvData

// Create import API instance and execute
$importAPI:=cs.OdysseyAPI.ImportRecords.new($settings)
$result:=$importAPI.request.run()

If (Bool($result.Success))
    ALERT("Import completed successfully! "+String($result.RecordsImported)+" records imported.")
Else 
    ALERT("Import failed: "+String($result.ErrorMessage))
    
    // Display import errors if available
    If ($result.ImportErrors#Null)
        showImportErrors($result.ImportErrors)
    End if
End if
```

### File-Based Import Function
```4d
// Function to import data from a file
Function importDataFromFile($filePath : Text; $profileID : Text; $companyID : Text) : Object
    var $settings : Object
    var $importAPI : cs.OdysseyAPI.ImportRecords
    var $result : Object
    var $importStatus : Object
    var $fileContent : Text
    var $fileDoc : 4D.File
    
    // Initialize import status
    $importStatus:=New object()
    $importStatus.success:=False
    $importStatus.timestamp:=String(Current date; ISO date GMT; Current time)
    $importStatus.filePath:=$filePath
    $importStatus.profileID:=$profileID
    $importStatus.companyID:=$companyID
    
    Try
        // Read file content
        $fileDoc:=File($filePath)
        
        If ($fileDoc.exists)
            $fileContent:=$fileDoc.getText()
            
            If ($fileContent#"")
                // Set up import request
                $settings:=cs.responseSettings.new()
                $settings.CompanyID:=$companyID
                $settings.ProfileID:=$profileID
                $settings.SourceFileData:=$fileContent
                
                // Execute import
                $importAPI:=cs.OdysseyAPI.ImportRecords.new($settings)
                $result:=$importAPI.request.run()
                
                If (Bool($result.Success))
                    $importStatus.success:=True
                    $importStatus.message:="File imported successfully"
                    $importStatus.recordsImported:=$result.RecordsImported
                    $importStatus.recordsRejected:=$result.RecordsRejected
                    $importStatus.importID:=$result.ImportID
                    
                    // Log successful import
                    logImportEvent("SUCCESS"; $filePath; $profileID; $companyID; $result)
                    
                    // Move file to processed folder
                    moveToProcessedFolder($fileDoc)
                    
                Else 
                    $importStatus.message:="Import failed: "+String($result.ErrorMessage)
                    $importStatus.errorCode:=$result.statusCode
                    $importStatus.importErrors:=$result.ImportErrors
                    
                    // Log failed import
                    logImportEvent("FAILED"; $filePath; $profileID; $companyID; $result.ErrorMessage)
                    
                    // Move file to error folder
                    moveToErrorFolder($fileDoc)
                End if
            Else 
                $importStatus.message:="File is empty"
            End if
        Else 
            $importStatus.message:="File not found: "+$filePath
        End if
        
    Catch
        $importStatus.message:="Import error: "+Last errors[0].message
        $importStatus.exception:=True
        
        // Log import exception
        logImportEvent("ERROR"; $filePath; $profileID; $companyID; Last errors[0].message)
    End try
    
    return $importStatus
```

### Batch File Import Processing
```4d
// Function to process multiple import files
Function processBatchImports($importFolder : Text; $profileID : Text; $companyID : Text) : Collection
    var $importResults : Collection
    var $folder : 4D.Folder
    var $files : Collection
    var $file : 4D.File
    var $importResult : Object
    var $i : Integer
    
    $importResults:=New collection()
    
    Try
        $folder:=Folder($importFolder)
        
        If ($folder.exists)
            // Get all CSV files in the folder
            $files:=$folder.files().query("extension == :1"; ".csv")
            
            For ($i; 0; $files.length-1)
                $file:=$files[$i]
                
                // Import each file
                $importResult:=importDataFromFile($file.platformPath; $profileID; $companyID)
                $importResult.fileName:=$file.name
                $importResult.fileSize:=$file.size
                
                $importResults.push($importResult)
                
                // Add delay between imports to avoid overwhelming the API
                DELAY PROCESS(Current process; 200)  // 2 second delay
            End for
            
        Else 
            $importResult:=New object()
            $importResult.success:=False
            $importResult.message:="Import folder not found: "+$importFolder
            $importResults.push($importResult)
        End if
        
    Catch
        $importResult:=New object()
        $importResult.success:=False
        $importResult.message:="Batch import error: "+Last errors[0].message
        $importResult.exception:=True
        $importResults.push($importResult)
    End try
    
    return $importResults
```

### Data Validation Before Import
```4d
// Function to validate data before importing
Function validateAndImportData($rawData : Text; $profileID : Text; $companyID : Text) : Object
    var $validationResult : Object
    var $importResult : Object
    var $cleanedData : Text
    
    // Validate data format and content
    $validationResult:=validateImportData($rawData; $profileID)
    
    If ($validationResult.valid)
        // Clean and format data if needed
        $cleanedData:=cleanImportData($rawData; $validationResult.suggestions)
        
        // Proceed with import
        $importResult:=importDataFromString($cleanedData; $profileID; $companyID)
        
        If ($importResult.success)
            $importResult.validationPassed:=True
            $importResult.dataCleanedUp:=($cleanedData#$rawData)
        End if
    Else 
        // Validation failed
        $importResult:=New object()
        $importResult.success:=False
        $importResult.validationPassed:=False
        $importResult.message:="Data validation failed: "+$validationResult.errors.join(", ")
        $importResult.validationErrors:=$validationResult.errors
    End if
    
    return $importResult
```

### Scheduled Import Processing
```4d
// Function for automated scheduled imports
Function processScheduledImports()
    var $importSchedules : Collection
    var $schedule : Object
    var $importResult : Object
    var $summary : Object
    var $i : Integer
    
    // Get all active import schedules
    $importSchedules:=getActiveImportSchedules()
    
    $summary:=New object()
    $summary.timestamp:=String(Current date; ISO date GMT; Current time)
    $summary.schedulesProcessed:=0
    $summary.successfulImports:=0
    $summary.failedImports:=0
    $summary.totalRecordsImported:=0
    $summary.results:=New collection()
    
    For ($i; 0; $importSchedules.length-1)
        $schedule:=$importSchedules[$i]
        
        Try
            // Check if schedule is due for processing
            If (isScheduleDue($schedule))
                // Process the scheduled import
                $importResult:=processBatchImports(\
                    $schedule.importFolder; \
                    $schedule.profileID; \
                    $schedule.companyID)
                
                $summary.schedulesProcessed:=$summary.schedulesProcessed+1
                
                // Count successful and failed imports
                var $result : Object
                For each ($result; $importResult)
                    If ($result.success)
                        $summary.successfulImports:=$summary.successfulImports+1
                        $summary.totalRecordsImported:=$summary.totalRecordsImported+$result.recordsImported
                    Else 
                        $summary.failedImports:=$summary.failedImports+1
                    End if
                End for each
                
                $summary.results.push(New object(\
                    "scheduleID"; $schedule.id; \
                    "scheduleName"; $schedule.name; \
                    "results"; $importResult))
                
                // Update schedule last run time
                updateScheduleLastRun($schedule.id)
                
                // Send notifications if configured
                If ($schedule.notifyOnCompletion)
                    sendImportNotification($schedule; $importResult)
                End if
            End if
            
        Catch
            $summary.failedImports:=$summary.failedImports+1
            
            // Log schedule processing error
            logScheduleError($schedule.id; Last errors[0].message)
        End try
        
        // Small delay between schedules
        DELAY PROCESS(Current process; 100)  // 1 second delay
    End for
    
    // Log summary
    logScheduledImportSummary($summary)
    
    // Send admin summary if there were any issues
    If ($summary.failedImports>0)
        sendAdminImportSummary($summary)
    End if
```

### Import with Progress Tracking
```4d
// Function to import large datasets with progress tracking
Function importLargeDataset($dataCollection : Collection; $profileID : Text; $companyID : Text; $batchSize : Integer) : Object
    var $importProgress : Object
    var $batch : Collection
    var $batchData : Text
    var $batchResult : Object
    var $currentIndex : Integer
    var $totalBatches : Integer
    var $processedRecords : Integer
    
    $importProgress:=New object()
    $importProgress.success:=False
    $importProgress.startTime:=String(Current date; ISO date GMT; Current time)
    $importProgress.totalRecords:=$dataCollection.length
    $importProgress.batchSize:=$batchSize
    $importProgress.processedRecords:=0
    $importProgress.successfulBatches:=0
    $importProgress.failedBatches:=0
    $importProgress.batches:=New collection()
    
    $totalBatches:=Int($dataCollection.length/$batchSize)+1
    $currentIndex:=0
    
    While ($currentIndex<$dataCollection.length)
        // Create batch
        $batch:=$dataCollection.slice($currentIndex; $currentIndex+$batchSize)
        
        // Convert batch to CSV format
        $batchData:=convertCollectionToCSV($batch)
        
        // Import batch
        $batchResult:=importDataFromString($batchData; $profileID; $companyID)
        $batchResult.batchNumber:=$importProgress.successfulBatches+$importProgress.failedBatches+1
        $batchResult.batchSize:=$batch.length
        $batchResult.startIndex:=$currentIndex
        
        $importProgress.batches.push($batchResult)
        
        If ($batchResult.success)
            $importProgress.successfulBatches:=$importProgress.successfulBatches+1
            $importProgress.processedRecords:=$importProgress.processedRecords+$batchResult.recordsImported
        Else 
            $importProgress.failedBatches:=$importProgress.failedBatches+1
        End if
        
        // Update progress
        $importProgress.percentComplete:=($currentIndex/$dataCollection.length)*100
        
        // Report progress
        reportImportProgress($importProgress)
        
        $currentIndex:=$currentIndex+$batchSize
        
        // Delay between batches
        DELAY PROCESS(Current process; 300)  // 3 second delay
    End while
    
    $importProgress.endTime:=String(Current date; ISO date GMT; Current time)
    $importProgress.success:=($importProgress.failedBatches=0)
    $importProgress.percentComplete:=100
    
    return $importProgress
```

### Import Error Analysis
```4d
// Function to analyze and categorize import errors
Function analyzeImportErrors($importResult : Object) : Object
    var $errorAnalysis : Object
    var $error : Object
    var $errorCategories : Object
    var $i : Integer
    
    $errorAnalysis:=New object()
    $errorAnalysis.totalErrors:=0
    $errorCategories:=New object()
    $errorCategories.validationErrors:=New collection()
    $errorCategories.dataFormatErrors:=New collection()
    $errorCategories.duplicateErrors:=New collection()
    $errorCategories.constraintErrors:=New collection()
    $errorCategories.unknownErrors:=New collection()
    
    If ($importResult.ImportErrors#Null)
        $errorAnalysis.totalErrors:=$importResult.ImportErrors.length
        
        For ($i; 0; $importResult.ImportErrors.length-1)
            $error:=$importResult.ImportErrors[$i]
            
            // Categorize error based on error message or code
            Case of 
                : (String($error.Message)="@validation@")
                    $errorCategories.validationErrors.push($error)
                    
                : (String($error.Message)="@format@") || (String($error.Message)="@invalid@")
                    $errorCategories.dataFormatErrors.push($error)
                    
                : (String($error.Message)="@duplicate@") || (String($error.Message)="@already exists@")
                    $errorCategories.duplicateErrors.push($error)
                    
                : (String($error.Message)="@constraint@") || (String($error.Message)="@foreign key@")
                    $errorCategories.constraintErrors.push($error)
                    
                Else 
                    $errorCategories.unknownErrors.push($error)
            End case
        End for
        
        $errorAnalysis.categories:=$errorCategories
        $errorAnalysis.validationErrorCount:=$errorCategories.validationErrors.length
        $errorAnalysis.dataFormatErrorCount:=$errorCategories.dataFormatErrors.length
        $errorAnalysis.duplicateErrorCount:=$errorCategories.duplicateErrors.length
        $errorAnalysis.constraintErrorCount:=$errorCategories.constraintErrors.length
        $errorAnalysis.unknownErrorCount:=$errorCategories.unknownErrors.length
    End if
    
    return $errorAnalysis
```

### Import Rollback Functionality
```4d
// Function to rollback a failed import
Function rollbackImport($importID : Text; $companyID : Text) : Object
    var $rollbackStatus : Object
    var $importedRecords : Collection
    var $record : Object
    var $deleteResult : Object
    var $i : Integer
    
    $rollbackStatus:=New object()
    $rollbackStatus.success:=False
    $rollbackStatus.importID:=$importID
    $rollbackStatus.recordsDeleted:=0
    $rollbackStatus.errors:=New collection()
    
    Try
        // Get all records that were imported in this batch
        $importedRecords:=getImportedRecords($importID; $companyID)
        
        If ($importedRecords.length>0)
            // Delete each imported record
            For ($i; 0; $importedRecords.length-1)
                $record:=$importedRecords[$i]
                
                $deleteResult:=deleteImportedRecord($record.TableName; $record.RecordID; $companyID)
                
                If ($deleteResult.success)
                    $rollbackStatus.recordsDeleted:=$rollbackStatus.recordsDeleted+1
                Else 
                    $rollbackStatus.errors.push(New object(\
                        "recordID"; $record.RecordID; \
                        "tableName"; $record.TableName; \
                        "error"; $deleteResult.message))
                End if
            End for
            
            If ($rollbackStatus.errors.length=0)
                $rollbackStatus.success:=True
                $rollbackStatus.message:="Import rollback completed successfully"
                
                // Mark import as rolled back
                markImportAsRolledBack($importID)
            Else 
                $rollbackStatus.message:="Partial rollback completed with "+String($rollbackStatus.errors.length)+" errors"
            End if
        Else 
            $rollbackStatus.message:="No records found for import ID: "+$importID
        End if
        
    Catch
        $rollbackStatus.message:="Rollback error: "+Last errors[0].message
        $rollbackStatus.exception:=True
    End try
    
    return $rollbackStatus
```

## Integration Patterns

### REST API Wrapper
```4d
// RESTful import endpoint wrapper
Function handleRESTImport($request : Object) : Object
    var $fileData : Text
    var $profileID; $companyID : Text
    var $importResult : Object
    var $response : Object
    
    // Extract parameters from REST request
    $profileID:=$request.body.profileID
    $companyID:=$request.body.companyID
    $fileData:=$request.body.data
    
    // Validate request
    If ($profileID="") || ($companyID="") || ($fileData="")
        $response:=New object("success"; False; "error"; "Profile ID, Company ID, and data are required")
        return $response
    End if
    
    // Execute import
    $importResult:=importDataFromString($fileData; $profileID; $companyID)
    
    // Format response
    $response:=New object()
    $response.success:=$importResult.success
    $response.timestamp:=String(Current date; ISO date GMT; Current time)
    $response.profileID:=$profileID
    $response.companyID:=$companyID
    
    If ($importResult.success)
        $response.message:="Import completed successfully"
        $response.recordsImported:=$importResult.recordsImported
        $response.importID:=$importResult.importID
    Else 
        $response.error:=$importResult.message
        If ($importResult.importErrors#Null)
            $response.importErrors:=$importResult.importErrors
        End if
    End if
    
    return $response
```

### Data Pipeline Integration
```4d
// Function to integrate with data processing pipeline
Function processDataPipeline($pipelineConfig : Object) : Object
    var $pipelineResult : Object
    var $stage : Object
    var $stageResult : Object
    var $data : Text
    var $i : Integer
    
    $pipelineResult:=New object()
    $pipelineResult.success:=True
    $pipelineResult.stages:=New collection()
    $pipelineResult.startTime:=String(Current date; ISO date GMT; Current time)
    
    // Get initial data
    $data:=extractDataFromSource($pipelineConfig.source)
    
    // Process each pipeline stage
    For ($i; 0; $pipelineConfig.stages.length-1)
        $stage:=$pipelineConfig.stages[$i]
        
        Case of 
            : ($stage.type="transform")
                $stageResult:=transformData($data; $stage.config)
                $data:=$stageResult.transformedData
                
            : ($stage.type="validate")
                $stageResult:=validateData($data; $stage.config)
                
            : ($stage.type="import")
                $stageResult:=importDataFromString($data; $stage.profileID; $stage.companyID)
                
        End case
        
        $stageResult.stageName:=$stage.name
        $stageResult.stageType:=$stage.type
        $pipelineResult.stages.push($stageResult)
        
        If (Not($stageResult.success))
            $pipelineResult.success:=False
            $pipelineResult.failedStage:=$stage.name
            break
        End if
    End for
    
    $pipelineResult.endTime:=String(Current date; ISO date GMT; Current time)
    
    return $pipelineResult
```

## Security Considerations

1. **Data Validation**: Always validate import data before processing
2. **File Security**: Scan uploaded files for malicious content
3. **Access Control**: Verify user permissions for import operations
4. **Audit Logging**: Log all import operations with user and timestamp information
5. **Data Sanitization**: Clean and sanitize imported data to prevent injection attacks
6. **Rate Limiting**: Implement rate limiting for import operations
7. **Backup Strategy**: Ensure proper backup before large import operations

## Key Features

1. **Bulk Data Import**: Efficiently import large datasets using predefined profiles
2. **Multiple Data Formats**: Support for CSV, XML, and other structured data formats
3. **Error Handling**: Comprehensive error reporting with detailed import logs
4. **Progress Tracking**: Monitor import progress for large datasets
5. **Batch Processing**: Process multiple files and large datasets in batches
6. **Rollback Capability**: Ability to rollback failed imports
7. **Validation Integration**: Pre-import data validation and cleaning
8. **Scheduled Processing**: Support for automated scheduled imports

## Notes

- This class is specifically designed for the Odyssey API system
- The endpoint requires CompanyID, ProfileID, and SourceFileData in the request body
- Import profiles must be predefined in the Odyssey system
- Large imports should be processed in batches to avoid timeouts
- The class automatically calls the importRecords endpoint during construction
- Results are available through the `request.run()` method
- Consider implementing data validation and error handling for production use
- Monitor import performance and adjust batch sizes as needed
- Implement proper rollback procedures for failed imports
