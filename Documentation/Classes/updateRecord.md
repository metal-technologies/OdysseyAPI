<!-- Type your summary here -->
# updateRecord Class Documentation

## Overview
The `updateRecord` class is a specialized API client for updating existing records in the Odyssey API system. This class provides a secure and efficient interface to modify individual records in specified database tables, making it essential for data maintenance and record management workflows.

## Class Information
- **Namespace**: `cs.OdysseyAPI.UpdateRecord`
- **API Endpoint**: `/Record/Update`
- **Base URL**: `https://api.blinfo.com/metaltech/Record/Update`
- **HTTP Method**: POST
- **Authentication**: Requires API key and proper authentication

## Properties

### Core Properties
- `request` (cs.request) - The underlying request object that handles HTTP communication
- `settings` (Object) - Configuration settings object passed to the constructor

## Constructor

```4d
Class constructor($settings : Object)
    $settings.apiURL:="https://api.blinfo.com/metaltech/Record/Update"
    $settings.apiMethod:="POST"
    This.request:=cs.request.new($settings)
    This.request.updateRecord()
    This.settings:=$settings
```

The constructor automatically configures the API endpoint and HTTP method, creates a request object, and calls the updateRecord endpoint.

### Parameters
- `$settings` (Object) - A settings object, typically `cs.responseSettings.new()` containing:
  - `CompanyID` (Text) - Company identifier
  - `TableName` (Text) - Target table name
  - `UniqueID` (Integer/Real) - Unique identifier of the record to update
  - `ListOfFieldValues` (Collection) - Collection of field name-value pairs to update

### Example Usage
```4d
var $settings : Object
var $updateAPI : cs.OdysseyAPI.UpdateRecord

// Create settings object with update parameters
$settings:=cs.responseSettings.new()
$settings.CompanyID:="ACME_CORP"
$settings.TableName:="Customers"
$settings.UniqueID:=12345
$settings.ListOfFieldValues:=New collection()

// Initialize update API client
$updateAPI:=cs.OdysseyAPI.UpdateRecord.new($settings)
```

## Usage Examples

### Basic Record Update
```4d
var $settings : Object
var $updateAPI : cs.OdysseyAPI.UpdateRecord
var $result : Object

// Initialize settings
$settings:=cs.responseSettings.new()
$settings.CompanyID:="COMP001"
$settings.TableName:="Customers"
$settings.UniqueID:=12345

// Build field values to update
$settings.ListOfFieldValues:=New collection()
$settings.ListOfFieldValues.push(New object("Key"; "FirstName"; "Value"; "John"))
$settings.ListOfFieldValues.push(New object("Key"; "LastName"; "Value"; "Smith"))
$settings.ListOfFieldValues.push(New object("Key"; "Email"; "Value"; "john.smith@example.com"))
$settings.ListOfFieldValues.push(New object("Key"; "Phone"; "Value"; "555-0123"))

// Create update API instance and execute
$updateAPI:=cs.OdysseyAPI.UpdateRecord.new($settings)
$result:=$updateAPI.request.run()

If (Bool($result.Success))
    ALERT("Customer record updated successfully!")
Else 
    ALERT("Update failed: "+String($result.ErrorMessage))
End if
```

### Customer Information Update Function
```4d
// Function to update customer information
Function updateCustomerInfo($customerID : Integer; $updates : Object) : Object
    var $settings : Object
    var $updateAPI : cs.OdysseyAPI.UpdateRecord
    var $result : Object
    var $updateStatus : Object
    
    // Initialize update status
    $updateStatus:=New object()
    $updateStatus.success:=False
    $updateStatus.timestamp:=String(Current date; ISO date GMT; Current time)
    $updateStatus.customerID:=$customerID
    
    Try
        // Set up update request
        $settings:=cs.responseSettings.new()
        $settings.CompanyID:=Get_Company_ID()
        $settings.TableName:="Customers"
        $settings.UniqueID:=$customerID
        $settings.ListOfFieldValues:=New collection()
        
        // Build field values from updates object
        var $key : Text
        For each ($key; $updates)
            $settings.ListOfFieldValues.push(New object(\
                "Key"; $key; \
                "Value"; String($updates[$key])))
        End for each
        
        // Execute update
        $updateAPI:=cs.OdysseyAPI.UpdateRecord.new($settings)
        $result:=$updateAPI.request.run()
        
        If (Bool($result.Success))
            $updateStatus.success:=True
            $updateStatus.message:="Customer information updated successfully"
            $updateStatus.updatedFields:=$updates
            
            // Log successful update
            logDataChangeEvent("UPDATE"; "Customers"; $customerID; $updates)
            
        Else 
            $updateStatus.message:="Update failed: "+String($result.ErrorMessage)
            $updateStatus.errorCode:=$result.statusCode
            
            // Log failed update
            logDataChangeEvent("UPDATE_FAILED"; "Customers"; $customerID; $result.ErrorMessage)
        End if
        
    Catch
        $updateStatus.message:="Update error: "+Last errors[0].message
        $updateStatus.exception:=True
        
        // Log update exception
        logDataChangeEvent("UPDATE_ERROR"; "Customers"; $customerID; Last errors[0].message)
    End try
    
    return $updateStatus
```

### Form-Based Record Update
```4d
// Method to handle form submission for record updates
Function handleRecordUpdateForm()
    var $recordID : Integer
    var $tableName : Text
    var $updates : Object
    var $result : Object
    var $fieldName; $fieldValue : Text
    var $i : Integer
    
    // Get form values
    $recordID:=Form.recordID
    $tableName:=Form.tableName
    
    // Validate required fields
    If ($recordID=0) || ($tableName="")
        ALERT("Record ID and Table Name are required")
        return
    End if
    
    // Build updates object from form
    $updates:=New object()
    
    // Example of collecting form field updates
    If (Form.firstName#"")
        $updates.FirstName:=Form.firstName
    End if
    If (Form.lastName#"")
        $updates.LastName:=Form.lastName
    End if
    If (Form.email#"")
        $updates.Email:=Form.email
    End if
    If (Form.phone#"")
        $updates.Phone:=Form.phone
    End if
    If (Form.address#"")
        $updates.Address:=Form.address
    End if
    
    // Check if any updates were made
    If (OB Is empty($updates))
        ALERT("No changes detected")
        return
    End if
    
    // Confirm update with user
    If (CONFIRM("Update record with the following changes?"; "Yes"; "Cancel"))
        $result:=updateCustomerInfo($recordID; $updates)
        
        If ($result.success)
            ALERT("Record updated successfully!")
            // Refresh form or navigate away
            refreshRecordDisplay($recordID)
        Else 
            ALERT("Update failed: "+$result.message)
        End if
    End if
```

### Batch Record Updates
```4d
// Function to update multiple records with different values
Function updateMultipleRecords($tableName : Text; $recordUpdates : Collection) : Collection
    var $updateResults : Collection
    var $recordUpdate : Object
    var $settings : Object
    var $updateAPI : cs.OdysseyAPI.UpdateRecord
    var $result : Object
    var $i : Integer
    
    $updateResults:=New collection()
    
    For ($i; 0; $recordUpdates.length-1)
        $recordUpdate:=$recordUpdates[$i]
        
        Try
            // Set up update request for each record
            $settings:=cs.responseSettings.new()
            $settings.CompanyID:=Get_Company_ID()
            $settings.TableName:=$tableName
            $settings.UniqueID:=$recordUpdate.recordID
            $settings.ListOfFieldValues:=New collection()
            
            // Build field values for this record
            var $key : Text
            For each ($key; $recordUpdate.updates)
                $settings.ListOfFieldValues.push(New object(\
                    "Key"; $key; \
                    "Value"; String($recordUpdate.updates[$key])))
            End for each
            
            // Execute update
            $updateAPI:=cs.OdysseyAPI.UpdateRecord.new($settings)
            $result:=$updateAPI.request.run()
            
            // Store result
            $updateResults.push(New object(\
                "recordID"; $recordUpdate.recordID; \
                "success"; Bool($result.Success); \
                "message"; $result.Success ? "Updated successfully" : String($result.ErrorMessage); \
                "timestamp"; String(Current date; ISO date GMT; Current time)))
            
        Catch
            $updateResults.push(New object(\
                "recordID"; $recordUpdate.recordID; \
                "success"; False; \
                "message"; "Exception: "+Last errors[0].message; \
                "timestamp"; String(Current date; ISO date GMT; Current time)))
        End try
        
        // Add small delay to avoid overwhelming the API
        DELAY PROCESS(Current process; 50)  // 0.5 second delay
    End for
    
    return $updateResults
```

### Status Change Update
```4d
// Function to update record status
Function updateRecordStatus($tableName : Text; $recordID : Integer; $newStatus : Text; $reason : Text) : Object
    var $updates : Object
    var $result : Object
    var $statusChange : Object
    
    $statusChange:=New object()
    $statusChange.success:=False
    $statusChange.recordID:=$recordID
    $statusChange.oldStatus:=""
    $statusChange.newStatus:=$newStatus
    $statusChange.timestamp:=String(Current date; ISO date GMT; Current time)
    
    Try
        // Get current status first (optional verification)
        $currentRecord:=getRecordByID($tableName; $recordID)
        If ($currentRecord#Null)
            $statusChange.oldStatus:=$currentRecord.Status
        End if
        
        // Build status update
        $updates:=New object()
        $updates.Status:=$newStatus
        $updates.StatusChangeReason:=$reason
        $updates.StatusChangeDate:=String(Current date; ISO date GMT)
        $updates.StatusChangedBy:=Current user
        
        // Execute update
        $result:=updateCustomerInfo($recordID; $updates)
        
        If ($result.success)
            $statusChange.success:=True
            $statusChange.message:="Status updated from '"+$statusChange.oldStatus+"' to '"+$newStatus+"'"
            
            // Log status change
            logStatusChangeEvent($tableName; $recordID; $statusChange.oldStatus; $newStatus; $reason)
            
            // Send notifications if needed
            If ($newStatus="Approved") || ($newStatus="Rejected")
                sendStatusChangeNotification($recordID; $newStatus; $reason)
            End if
            
        Else 
            $statusChange.message:="Status update failed: "+$result.message
        End if
        
    Catch
        $statusChange.message:="Status update error: "+Last errors[0].message
        $statusChange.exception:=True
    End try
    
    return $statusChange
```

### Audit Trail Update
```4d
// Function to update record with audit trail
Function updateRecordWithAudit($tableName : Text; $recordID : Integer; $updates : Object; $userID : Text; $changeReason : Text) : Object
    var $auditedUpdates : Object
    var $result : Object
    var $auditInfo : Object
    
    // Add audit fields to updates
    $auditedUpdates:=OB Copy($updates)
    $auditedUpdates.LastModifiedBy:=$userID
    $auditedUpdates.LastModifiedDate:=String(Current date; ISO date GMT; Current time)
    $auditedUpdates.ModificationReason:=$changeReason
    
    // Execute update with audit information
    $result:=updateCustomerInfo($recordID; $auditedUpdates)
    
    If ($result.success)
        // Create detailed audit log entry
        $auditInfo:=New object()
        $auditInfo.table:=$tableName
        $auditInfo.recordID:=$recordID
        $auditInfo.userID:=$userID
        $auditInfo.timestamp:=String(Current date; ISO date GMT; Current time)
        $auditInfo.reason:=$changeReason
        $auditInfo.changes:=$updates
        
        // Store in audit log
        createAuditLogEntry($auditInfo)
    End if
    
    return $result
```

### Conditional Update
```4d
// Function to update record only if conditions are met
Function conditionalUpdateRecord($tableName : Text; $recordID : Integer; $updates : Object; $conditions : Object) : Object
    var $currentRecord : Object
    var $conditionsMet : Boolean
    var $result : Object
    var $updateStatus : Object
    
    $updateStatus:=New object()
    $updateStatus.success:=False
    $updateStatus.conditionsMet:=False
    
    Try
        // Get current record to check conditions
        $currentRecord:=getRecordByID($tableName; $recordID)
        
        If ($currentRecord=Null)
            $updateStatus.message:="Record not found"
            return $updateStatus
        End if
        
        // Check all conditions
        $conditionsMet:=True
        var $field : Text
        For each ($field; $conditions)
            If ($currentRecord[$field]#$conditions[$field])
                $conditionsMet:=False
                break
            End if
        End for each
        
        $updateStatus.conditionsMet:=$conditionsMet
        
        If ($conditionsMet)
            // Conditions met, proceed with update
            $result:=updateCustomerInfo($recordID; $updates)
            $updateStatus.success:=$result.success
            $updateStatus.message:=$result.message
        Else 
            $updateStatus.message:="Update conditions not met"
        End if
        
    Catch
        $updateStatus.message:="Conditional update error: "+Last errors[0].message
        $updateStatus.exception:=True
    End try
    
    return $updateStatus
```

### Integration with Validation
```4d
// Function to update record with field validation
Function updateRecordWithValidation($tableName : Text; $recordID : Integer; $updates : Object) : Object
    var $validationResult : Object
    var $updateResult : Object
    
    // Validate updates before sending to API
    $validationResult:=validateFieldUpdates($tableName; $updates)
    
    If ($validationResult.valid)
        // Validation passed, proceed with update
        $updateResult:=updateCustomerInfo($recordID; $updates)
        
        If ($updateResult.success)
            $updateResult.validationPassed:=True
        End if
    Else 
        // Validation failed
        $updateResult:=New object()
        $updateResult.success:=False
        $updateResult.validationPassed:=False
        $updateResult.message:="Validation failed: "+$validationResult.errors.join(", ")
        $updateResult.validationErrors:=$validationResult.errors
    End if
    
    return $updateResult
```

## Integration Patterns

### REST API Wrapper
```4d
// RESTful update endpoint wrapper
Function handleRESTUpdate($request : Object) : Object
    var $recordID : Integer
    var $tableName : Text
    var $updates : Object
    var $result : Object
    var $response : Object
    
    // Extract parameters from REST request
    $recordID:=Num($request.params.id)
    $tableName:=$request.params.table
    $updates:=$request.body
    
    // Validate request
    If ($recordID=0) || ($tableName="")
        $response:=New object("success"; False; "error"; "Invalid record ID or table name")
        return $response
    End if
    
    // Execute update
    $result:=updateRecordWithValidation($tableName; $recordID; $updates)
    
    // Format response
    $response:=New object()
    $response.success:=$result.success
    $response.timestamp:=String(Current date; ISO date GMT; Current time)
    $response.recordID:=$recordID
    $response.table:=$tableName
    
    If ($result.success)
        $response.message:="Record updated successfully"
        $response.data:=$result.updatedFields
    Else 
        $response.error:=$result.message
        If ($result.validationErrors#Null)
            $response.validationErrors:=$result.validationErrors
        End if
    End if
    
    return $response
```

### Change Tracking System
```4d
// Function to track and log all record changes
Function trackRecordChanges($tableName : Text; $recordID : Integer; $oldValues : Object; $newValues : Object)
    var $changes : Collection
    var $change : Object
    var $field : Text
    
    $changes:=New collection()
    
    // Compare old and new values
    For each ($field; $newValues)
        If ($oldValues[$field]#$newValues[$field])
            $change:=New object()
            $change.field:=$field
            $change.oldValue:=$oldValues[$field]
            $change.newValue:=$newValues[$field]
            $change.timestamp:=String(Current date; ISO date GMT; Current time)
            $change.user:=Current user
            $changes.push($change)
        End if
    End for each
    
    // Store change history
    If ($changes.length>0)
        storeChangeHistory($tableName; $recordID; $changes)
    End if
```

## Security Considerations

1. **Authorization**: Always verify user permissions before allowing record updates
2. **Input Validation**: Validate all field values before sending to API
3. **Audit Logging**: Log all update operations for compliance and security
4. **Field Restrictions**: Implement field-level security to prevent unauthorized changes
5. **Concurrent Updates**: Handle potential race conditions when multiple users update the same record

## Key Features

1. **Flexible Updates**: Update any combination of fields in a single operation
2. **Type Safety**: Automatic handling of different data types in field values
3. **Error Handling**: Comprehensive error reporting for failed updates
4. **Audit Support**: Built-in support for change tracking and audit trails
5. **Validation Integration**: Easy integration with field validation systems
6. **Batch Capabilities**: Support for updating multiple records efficiently

## Notes

- This class is specifically designed for the Odyssey API system
- The endpoint requires CompanyID, TableName, UniqueID, and ListOfFieldValues in the request body
- Ideal for form-based updates, bulk operations, and automated data maintenance
- Should implement proper authorization checks before allowing updates
- The class automatically calls the updateRecord endpoint during construction
- Results are available through the `request.run()` method
- Consider implementing optimistic locking to prevent concurrent update conflicts
- Always validate field values and user permissions before executing updates
