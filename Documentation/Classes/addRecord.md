<!-- Type your summary here -->
# addRecord Class Documentation

## Overview
The `addRecord` class is a specialized API client for creating new records in the Odyssey API system. This class provides a secure interface to add individual records to specified database tables, making it essential for data entry, record creation, and content management operations in applications.

## Class Information
- **Namespace**: `cs.OdysseyAPI.addRecord`
- **API Endpoint**: `/Record/Add`
- **Base URL**: `https://api.blinfo.com/metaltech/Record/Add`
- **HTTP Method**: POST
- **Authentication**: Requires API key and proper authentication

## Properties

### Core Properties
- `request` (cs.request) - The underlying request object that handles HTTP communication
- `settings` (Object) - Configuration settings object passed to the constructor

## Constructor

```4d
Class constructor($settings : Object)
    $settings.apiURL:="https://api.blinfo.com/metaltech/Record/Add"
    $settings.apiMethod:="POST"
    This.request:=cs.request.new($settings)
    This.request.addRecord()
    This.settings:=$settings
```

The constructor automatically configures the API endpoint and HTTP method, creates a request object using the `requestClass`, and calls the addRecord endpoint.

### Parameters
- `$settings` (Object) - A settings object, typically `cs.responseSettings.new()` containing:
  - `CompanyID` (Text) - Company identifier
  - `TableName` (Text) - Target table name
  - `ListOfFieldValues` (Collection) - Collection of field name-value pairs for the new record

### Example Usage
```4d
var $settings : Object
var $addRecordAPI : cs.OdysseyAPI.addRecord

// Create settings object with record parameters
$settings:=cs.responseSettings.new()
$settings.CompanyID:="ACME_CORP"
$settings.TableName:="Customers"
$settings.ListOfFieldValues:=New collection()

// Initialize add record API client
$addRecordAPI:=cs.OdysseyAPI.addRecord.new($settings)
```

## Usage Examples

### Basic Record Addition
```4d
var $settings : Object
var $addRecordAPI : cs.OdysseyAPI.addRecord
var $result : Object

// Initialize settings
$settings:=cs.responseSettings.new()
$settings.CompanyID:="COMP001"
$settings.TableName:="Customers"

// Build field values for new record
$settings.ListOfFieldValues:=New collection()
$settings.ListOfFieldValues.push(New object("Key"; "FirstName"; "Value"; "John"))
$settings.ListOfFieldValues.push(New object("Key"; "LastName"; "Value"; "Doe"))
$settings.ListOfFieldValues.push(New object("Key"; "Email"; "Value"; "john.doe@example.com"))
$settings.ListOfFieldValues.push(New object("Key"; "Phone"; "Value"; "555-0123"))
$settings.ListOfFieldValues.push(New object("Key"; "Company"; "Value"; "Acme Corp"))
$settings.ListOfFieldValues.push(New object("Key"; "CreatedDate"; "Value"; "2025-10-27 22:00:04"))

// Create add record API instance and execute
$addRecordAPI:=cs.OdysseyAPI.addRecord.new($settings)
$result:=$addRecordAPI.request.run()

If (Bool($result.Success))
    ALERT("Customer record added successfully!")
Else 
    ALERT("Add record failed: "+String($result.ErrorMessage))
End if
```

### Customer Creation Function
```4d
// Function to create a new customer record
Function createCustomerRecord($customerData : Object; $companyID : Text) : Object
    var $settings : Object
    var $addRecordAPI : cs.OdysseyAPI.addRecord
    var $result : Object
    var $creationResult : Object
    
    // Initialize creation result
    $creationResult:=New object()
    $creationResult.success:=False
    $creationResult.timestamp:=String(Current date; ISO date GMT; Current time)
    $creationResult.customerData:=$customerData
    $creationResult.companyID:=$companyID
    
    Try
        // Validate input parameters
        If ($companyID="") || (OB Is empty($customerData))
            $creationResult.message:="Company ID and customer data are required"
            return $creationResult
        End if
        
        // Validate required customer fields
        var $validationResult : Object
        $validationResult:=validateCustomerData($customerData)
        
        If (Not($validationResult.valid))
            $creationResult.message:="Customer data validation failed: "+$validationResult.errors.join(", ")
            $creationResult.validationErrors:=$validationResult.errors
            return $creationResult
        End if
        
        // Check for duplicate customer
        var $duplicateCheck : Object
        $duplicateCheck:=checkDuplicateCustomer($customerData; $companyID)
        
        If ($duplicateCheck.isDuplicate)
            $creationResult.message:="Duplicate customer found: "+$duplicateCheck.duplicateField
            $creationResult.isDuplicate:=True
            $creationResult.existingRecordID:=$duplicateCheck.existingRecordID
            return $creationResult
        End if
        
        // Set up record creation request
        $settings:=cs.responseSettings.new()
        $settings.CompanyID:=$companyID
        $settings.TableName:="Customers"
        $settings.ListOfFieldValues:=New collection()
        
        // Build field values from customer data
        var $field : Text
        For each ($field; $customerData)
            If ($customerData[$field]#"")
                $settings.ListOfFieldValues.push(New object(\
                    "Key"; $field; \
                    "Value"; String($customerData[$field])))
            End if
        End for each
        
        // Add system fields
        $settings.ListOfFieldValues.push(New object("Key"; "CreatedDate"; "Value"; String(Current date; ISO date GMT; Current time)))
        $settings.ListOfFieldValues.push(New object("Key"; "CreatedBy"; "Value"; Current user))
        $settings.ListOfFieldValues.push(New object("Key"; "LastModifiedDate"; "Value"; String(Current date; ISO date GMT; Current time)))
        $settings.ListOfFieldValues.push(New object("Key"; "LastModifiedBy"; "Value"; Current user))
        
        // Create customer record
        $addRecordAPI:=cs.OdysseyAPI.addRecord.new($settings)
        $result:=$addRecordAPI.request.run()
        
        If (Bool($result.Success))
            $creationResult.success:=True
            $creationResult.message:="Customer record created successfully"
            $creationResult.newRecordID:=$result.NewRecordID
            $creationResult.recordData:=$customerData
            
            // Log successful customer creation
            logRecordCreation("SUCCESS"; "Customers"; $companyID; $result.NewRecordID; Current user)
            
            // Generate customer welcome email
            If ($customerData.Email#"")
                generateWelcomeEmail($customerData; $result.NewRecordID)
            End if
            
            // Update customer metrics
            updateCustomerMetrics($companyID; "CREATED")
            
        Else 
            $creationResult.message:="Customer creation failed: "+String($result.ErrorMessage)
            $creationResult.errorCode:=$result.statusCode
            
            // Log failed customer creation
            logRecordCreation("FAILED"; "Customers"; $companyID; $result.ErrorMessage; Current user)
        End if
        
    Catch
        $creationResult.message:="Customer creation error: "+Last errors[0].message
        $creationResult.exception:=True
        
        // Log customer creation exception
        logRecordCreation("ERROR"; "Customers"; $companyID; Last errors[0].message; Current user)
    End try
    
    return $creationResult
```

### Form-Based Record Creation
```4d
// Method to handle form submission for new records
Function handleRecordCreationForm()
    var $recordData : Object
    var $tableName; $companyID : Text
    var $creationResult : Object
    var $fieldName; $fieldValue : Text
    
    // Get form values
    $tableName:=Form.tableName
    $companyID:=Form.companyID
    
    // Validate required fields
    If ($tableName="") || ($companyID="")
        ALERT("Table name and company are required")
        return
    End if
    
    // Build record data from form
    $recordData:=New object()
    
    // Example of collecting form field data
    If (Form.firstName#"")
        $recordData.FirstName:=Form.firstName
    End if
    If (Form.lastName#"")
        $recordData.LastName:=Form.lastName
    End if
    If (Form.email#"")
        $recordData.Email:=Form.email
    End if
    If (Form.phone#"")
        $recordData.Phone:=Form.phone
    End if
    If (Form.address#"")
        $recordData.Address:=Form.address
    End if
    If (Form.company#"")
        $recordData.Company:=Form.company
    End if
    
    // Check if any data was provided
    If (OB Is empty($recordData))
        ALERT("Please enter at least one field")
        return
    End if
    
    // Show loading indicator
    Form.creationInProgress:=True
    OBJECT SET ENABLED(Form.createButton; False)
    
    // Create the record
    $creationResult:=createRecord($tableName; $recordData; $companyID; Current user)
    
    If ($creationResult.success)
        ALERT("Record created successfully! ID: "+String($creationResult.newRecordID))
        
        // Clear form or navigate away
        clearForm()
        // OR navigate to record detail view
        // navigateToRecordDetail($creationResult.newRecordID)
        
    Else 
        ALERT("Creation failed: "+$creationResult.message)
        
        If ($creationResult.isDuplicate)
            If (CONFIRM("A similar record already exists. Would you like to view it?"; "View Existing"; "Continue"))
                navigateToRecordDetail($creationResult.existingRecordID)
            End if
        End if
    End if
    
    // Hide loading indicator
    Form.creationInProgress:=False
    OBJECT SET ENABLED(Form.createButton; True)
```

### Batch Record Creation
```4d
// Function to create multiple records in batch
Function batchCreateRecords($recordsData : Collection; $tableName : Text; $companyID : Text) : Collection
    var $batchResults : Collection
    var $recordData : Object
    var $creationResult : Object
    var $i : Integer
    
    $batchResults:=New collection()
    
    For ($i; 0; $recordsData.length-1)
        $recordData:=$recordsData[$i]
        
        Try
            // Create each record
            $creationResult:=createRecord($tableName; $recordData; $companyID; Current user)
            
            // Add batch context
            $creationResult.batchIndex:=$i
            $creationResult.originalData:=$recordData
            
            $batchResults.push($creationResult)
            
        Catch
            // Add error entry for failed creation
            $batchResults.push(New object(\
                "success"; False; \
                "batchIndex"; $i; \
                "originalData"; $recordData; \
                "message"; "Exception during creation: "+Last errors[0].message; \
                "exception"; True))
        End try
        
        // Add small delay to avoid overwhelming the API
        DELAY PROCESS(Current process; 100)  // 1 second delay
    End for
    
    return $batchResults
```

### CSV Import to Records
```4d
// Function to import CSV data as new records
Function importCSVToRecords($csvFilePath : Text; $tableName : Text; $companyID : Text; $fieldMappings : Object) : Object
    var $importResult : Object
    var $csvData : Collection
    var $recordsData : Collection
    var $csvRow : Object
    var $recordData : Object
    var $batchResults : Collection
    
    $importResult:=New object()
    $importResult.success:=False
    $importResult.filePath:=$csvFilePath
    $importResult.tableName:=$tableName
    $importResult.timestamp:=String(Current date; ISO date GMT; Current time)
    
    Try
        // Read and parse CSV file
        $csvData:=parseCSVFile($csvFilePath)
        
        If ($csvData.length>0)
            $recordsData:=New collection()
            
            // Transform CSV data to record format
            For each ($csvRow; $csvData)
                $recordData:=New object()
                
                // Map CSV columns to record fields
                var $csvField : Text
                For each ($csvField; $fieldMappings)
                    var $recordField : Text
                    $recordField:=$fieldMappings[$csvField]
                    
                    If ($csvRow[$csvField]#Null)
                        $recordData[$recordField]:=$csvRow[$csvField]
                    End if
                End for each
                
                // Add import metadata
                $recordData.ImportSource:="CSV"
                $recordData.ImportFile:=File($csvFilePath).name
                $recordData.ImportDate:=String(Current date; ISO date GMT; Current time)
                
                $recordsData.push($recordData)
            End for each
            
            // Create records in batch
            $batchResults:=batchCreateRecords($recordsData; $tableName; $companyID)
            
            // Analyze batch results
            var $successCount; $failureCount : Integer
            $successCount:=0
            $failureCount:=0
            
            For each (var $result; $batchResults)
                If ($result.success)
                    $successCount:=$successCount+1
                Else 
                    $failureCount:=$failureCount+1
                End if
            End for each
            
            $importResult.success:=($failureCount=0)
            $importResult.totalRows:=$csvData.length
            $importResult.successfulCreations:=$successCount
            $importResult.failedCreations:=$failureCount
            $importResult.batchResults:=$batchResults
            
            If ($importResult.success)
                $importResult.message:="CSV import completed successfully - "+String($successCount)+" records created"
            Else 
                $importResult.message:="CSV import completed with errors - "+String($successCount)+" successful, "+String($failureCount)+" failed"
            End if
            
            // Generate import report
            generateImportReport($importResult)
            
        Else 
            $importResult.message:="No data found in CSV file"
        End if
        
    Catch
        $importResult.message:="CSV import error: "+Last errors[0].message
        $importResult.exception:=True
    End try
    
    return $importResult
```

### Record Template System
```4d
// Function to create records from predefined templates
Function createRecordFromTemplate($templateName : Text; $templateData : Object; $companyID : Text) : Object
    var $templateResult : Object
    var $template : Object
    var $recordData : Object
    var $creationResult : Object
    
    $templateResult:=New object()
    $templateResult.success:=False
    $templateResult.templateName:=$templateName
    $templateResult.timestamp:=String(Current date; ISO date GMT; Current time)
    
    Try
        // Load record template
        $template:=loadRecordTemplate($templateName)
        
        If ($template=Null)
            $templateResult.message:="Template not found: "+$templateName
            return $templateResult
        End if
        
        // Merge template with provided data
        $recordData:=OB Copy($template.defaultValues)
        
        // Override with provided template data
        var $field : Text
        For each ($field; $templateData)
            $recordData[$field]:=$templateData[$field]
        End for each
        
        // Apply template transformations
        If ($template.transformations#Null)
            $recordData:=applyTemplateTransformations($recordData; $template.transformations)
        End if
        
        // Validate template data
        If ($template.validationRules#Null)
            var $validationResult : Object
            $validationResult:=validateTemplateData($recordData; $template.validationRules)
            
            If (Not($validationResult.valid))
                $templateResult.message:="Template validation failed: "+$validationResult.errors.join(", ")
                $templateResult.validationErrors:=$validationResult.errors
                return $templateResult
            End if
        End if
        
        // Create record using template
        $creationResult:=createRecord($template.tableName; $recordData; $companyID; Current user)
        
        $templateResult.success:=$creationResult.success
        $templateResult.message:=$creationResult.message
        $templateResult.newRecordID:=$creationResult.newRecordID
        $templateResult.recordData:=$recordData
        $templateResult.tableName:=$template.tableName
        
        If ($creationResult.success)
            // Log template usage
            logTemplateUsage($templateName; $creationResult.newRecordID; Current user)
            
            // Execute post-creation actions if defined
            If ($template.postCreationActions#Null)
                executePostCreationActions($template.postCreationActions; $creationResult)
            End if
        End if
        
    Catch
        $templateResult.message:="Template creation error: "+Last errors[0].message
        $templateResult.exception:=True
    End try
    
    return $templateResult
```

### Record Validation and Sanitization
```4d
// Function to create record with comprehensive validation
Function createValidatedRecord($tableName : Text; $recordData : Object; $companyID : Text; $validationRules : Object) : Object
    var $validatedResult : Object
    var $sanitizedData : Object
    var $validationResult : Object
    var $creationResult : Object
    
    $validatedResult:=New object()
    $validatedResult.success:=False
    $validatedResult.tableName:=$tableName
    $validatedResult.originalData:=$recordData
    
    Try
        // Sanitize input data
        $sanitizedData:=sanitizeRecordData($recordData; $tableName)
        
        // Validate sanitized data
        $validationResult:=validateRecordData($sanitizedData; $validationRules)
        
        If ($validationResult.valid)
            // Enhance data with business rules
            $sanitizedData:=applyBusinessRules($sanitizedData; $tableName; $companyID)
            
            // Create the record
            $creationResult:=createRecord($tableName; $sanitizedData; $companyID; Current user)
            
            $validatedResult.success:=$creationResult.success
            $validatedResult.message:=$creationResult.message
            $validatedResult.newRecordID:=$creationResult.newRecordID
            $validatedResult.sanitizedData:=$sanitizedData
            $validatedResult.validationPassed:=True
            
            If ($creationResult.success)
                // Store data quality metrics
                storeDataQualityMetrics($tableName; $recordData; $sanitizedData)
            End if
            
        Else 
            $validatedResult.message:="Data validation failed: "+$validationResult.errors.join(", ")
            $validatedResult.validationPassed:=False
            $validatedResult.validationErrors:=$validationResult.errors
            $validatedResult.sanitizedData:=$sanitizedData
        End if
        
    Catch
        $validatedResult.message:="Validated creation error: "+Last errors[0].message
        $validatedResult.exception:=True
    End try
    
    return $validatedResult
```

### Workflow Integration
```4d
// Function to create record with workflow integration
Function createRecordWithWorkflow($tableName : Text; $recordData : Object; $companyID : Text; $workflowConfig : Object) : Object
    var $workflowResult : Object
    var $creationResult : Object
    var $workflowInstance : Object
    
    $workflowResult:=New object()
    $workflowResult.success:=False
    $workflowResult.tableName:=$tableName
    $workflowResult.workflowName:=$workflowConfig.name
    
    Try
        // Create the record first
        $creationResult:=createRecord($tableName; $recordData; $companyID; Current user)
        
        If ($creationResult.success)
            // Initialize workflow for the new record
            $workflowInstance:=initializeWorkflow(\
                $workflowConfig; \
                $creationResult.newRecordID; \
                $tableName; \
                $companyID)
            
            If ($workflowInstance.success)
                $workflowResult.success:=True
                $workflowResult.message:="Record created and workflow initiated successfully"
                $workflowResult.newRecordID:=$creationResult.newRecordID
                $workflowResult.workflowInstanceID:=$workflowInstance.instanceID
                $workflowResult.currentWorkflowStep:=$workflowInstance.currentStep
                
                // Update record with workflow information
                updateRecordWorkflowStatus(\
                    $tableName; \
                    $creationResult.newRecordID; \
                    $companyID; \
                    $workflowInstance.instanceID; \
                    $workflowInstance.currentStep)
                
                // Send workflow notifications
                sendWorkflowNotifications($workflowInstance; $recordData)
                
            Else 
                $workflowResult.success:=False
                $workflowResult.message:="Record created but workflow initiation failed: "+$workflowInstance.message
                $workflowResult.newRecordID:=$creationResult.newRecordID
                $workflowResult.workflowError:=$workflowInstance.message
            End if
        Else 
            $workflowResult.message:="Record creation failed: "+$creationResult.message
        End if
        
    Catch
        $workflowResult.message:="Workflow creation error: "+Last errors[0].message
        $workflowResult.exception:=True
    End try
    
    return $workflowResult
```

## Integration Patterns

### REST API Wrapper
```4d
// RESTful record creation endpoint wrapper
Function handleRESTRecordCreation($request : Object) : Object
    var $tableName; $companyID; $userID : Text
    var $recordData : Object
    var $creationResult : Object
    var $response : Object
    
    // Extract parameters from REST request
    $tableName:=$request.params.table
    $companyID:=$request.params.company
    $userID:=$request.user.id
    $recordData:=$request.body
    
    // Validate request
    If ($tableName="") || ($companyID="") || (OB Is empty($recordData))
        $response:=New object("success"; False; "error"; "Table name, company ID, and record data are required")
        return $response
    End if
    
    // Execute record creation
    $creationResult:=createRecord($tableName; $recordData; $companyID; $userID)
    
    // Format response
    $response:=New object()
    $response.success:=$creationResult.success
    $response.timestamp:=String(Current date; ISO date GMT; Current time)
    $response.table:=$tableName
    $response.company:=$companyID
    
    If ($creationResult.success)
        $response.recordID:=$creationResult.newRecordID
        $response.message:="Record created successfully"
        $response.data:=$creationResult.recordData
    Else 
        $response.error:=$creationResult.message
        
        If ($creationResult.isDuplicate)
            $response.duplicate:=True
            $response.existingRecordID:=$creationResult.existingRecordID
        End if
        
        If ($creationResult.validationErrors#Null)
            $response.validationErrors:=$creationResult.validationErrors
        End if
    End if
    
    return $response
```

### Database Transaction Management
```4d
// Function to manage record creation within database transactions
Function transactionalRecordCreation($recordOperations : Collection; $companyID : Text; $userID : Text) : Object
    var $transactionResult : Object
    var $transactionID : Text
    var $operation : Object
    var $creationResult : Object
    var $rollbackNeeded : Boolean
    
    $transactionResult:=New object()
    $transactionResult.success:=False
    $transactionResult.recordsCreated:=0
    $transactionResult.operationResults:=New collection()
    
    // Start database transaction
    $transactionID:=startDatabaseTransaction()
    
    Try
        For each ($operation; $recordOperations)
            $creationResult:=createRecord(\
                $operation.tableName; \
                $operation.recordData; \
                $companyID; \
                $userID)
            
            $creationResult.operationIndex:=$transactionResult.recordsCreated
            $transactionResult.operationResults.push($creationResult)
            
            If ($creationResult.success)
                $transactionResult.recordsCreated:=$transactionResult.recordsCreated+1
            Else 
                // Mark for rollback on any failure
                $rollbackNeeded:=True
                break
            End if
        End for each
        
        If ($rollbackNeeded)
            // Rollback transaction
            rollbackDatabaseTransaction($transactionID)
            $transactionResult.message:="Transaction rolled back due to creation failure"
        Else 
            // Commit transaction
            commitDatabaseTransaction($transactionID)
            $transactionResult.success:=True
            $transactionResult.message:="All records created successfully"
        End if
        
    Catch
        rollbackDatabaseTransaction($transactionID)
        $transactionResult.message:="Transaction error: "+Last errors[0].message
        $transactionResult.exception:=True
    End try
    
    return $transactionResult
```

## Security Considerations

1. **Input Validation**: Always validate and sanitize input data before record creation
2. **Access Control**: Verify user permissions before allowing record creation
3. **Data Privacy**: Ensure sensitive data is handled according to privacy regulations
4. **Audit Logging**: Log all record creation operations with user and timestamp
5. **Duplicate Prevention**: Implement checks to prevent duplicate record creation
6. **Rate Limiting**: Implement rate limiting to prevent abuse of record creation

## Key Features

1. **Flexible Record Creation**: Create records in any table with dynamic field values
2. **Data Validation**: Comprehensive validation and sanitization before creation
3. **Duplicate Detection**: Check for existing records before creation
4. **Batch Operations**: Support for creating multiple records efficiently
5. **Template System**: Create records from predefined templates
6. **Workflow Integration**: Automatic workflow initiation upon record creation
7. **Import Capabilities**: Import records from CSV and other data sources
8. **Transaction Support**: Create multiple records within database transactions

## Notes

- This class is specifically designed for the Odyssey API system
- The endpoint requires CompanyID, TableName, and ListOfFieldValues in the request body
- Uses the `requestClass` for HTTP communication and error handling
- Designed for single record creation - use batch functions for multiple records
- The class automatically calls the addRecord endpoint during construction
- Results are available through the `request.run()` method
- Always implement proper data validation and duplicate checking
- Consider using templates for consistent record creation
- Integration with workflow systems can automate business processes
- Implement proper error handling and user feedback for creation operations
