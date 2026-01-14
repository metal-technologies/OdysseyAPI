<!-- Type your summary here -->
# deleteRecord Class Documentation

## Overview
The `deleteRecord` class is a specialized API client for deleting individual records from the Odyssey API system. This class provides a secure interface to remove specific records from database tables using unique identifiers, making it essential for data management, record maintenance, and cleanup operations in applications.

## Class Information
- **Namespace**: `cs.OdysseyAPI.deleteRecord`
- **API Endpoint**: `/Record/Delete`
- **Base URL**: `https://api.blinfo.com/metaltech/Record/Delete`
- **HTTP Method**: POST
- **Authentication**: Requires API key and proper authentication

## Properties

### Core Properties
- `request` (cs.request) - The underlying request object that handles HTTP communication
- `settings` (Object) - Configuration settings object passed to the constructor

## Constructor

```4d
Class constructor($settings : Object)
    $settings.apiURL:="https://api.blinfo.com/metaltech/Record/Delete"
    $settings.apiMethod:="POST"
    This.request:=cs.request.new($settings)
    This.request.deleteRecord()
    This.settings:=$settings
```

The constructor automatically configures the API endpoint and HTTP method, creates a request object using the `requestClass`, and calls the deleteRecord endpoint.

### Parameters
- `$settings` (Object) - A settings object, typically `cs.responseSettings.new()` containing:
  - `CompanyID` (Text) - Company identifier
  - `TableName` (Text) - Target table name
  - `UniqueID` (Integer/Real) - Unique identifier of the record to delete

### Example Usage
```4d
var $settings : Object
var $deleteAPI : cs.OdysseyAPI.deleteRecord

// Create settings object with delete parameters
$settings:=cs.responseSettings.new()
$settings.CompanyID:="ACME_CORP"
$settings.TableName:="Customers"
$settings.UniqueID:=12345

// Initialize delete record API client
$deleteAPI:=cs.OdysseyAPI.deleteRecord.new($settings)
```

## Usage Examples

### Basic Record Deletion
```4d
var $settings : Object
var $deleteAPI : cs.OdysseyAPI.deleteRecord
var $result : Object

// Initialize settings
$settings:=cs.responseSettings.new()
$settings.CompanyID:="COMP001"
$settings.TableName:="Customers"
$settings.UniqueID:=12345

// Create delete API instance and execute
$deleteAPI:=cs.OdysseyAPI.deleteRecord.new($settings)
$result:=$deleteAPI.request.run()

If (Bool($result.Success))
    ALERT("Record deleted successfully!")
Else 
    ALERT("Delete failed: "+String($result.ErrorMessage))
End if
```

### Safe Record Deletion Function
```4d
// Function to safely delete a record with validation
Function safeDeleteRecord($tableName : Text; $recordID : Integer; $companyID : Text; $userID : Text) : Object
    var $settings : Object
    var $deleteAPI : cs.OdysseyAPI.deleteRecord
    var $result : Object
    var $deleteResult : Object
    var $recordExists : Boolean
    
    // Initialize delete result
    $deleteResult:=New object()
    $deleteResult.success:=False
    $deleteResult.timestamp:=String(Current date; ISO date GMT; Current time)
    $deleteResult.tableName:=$tableName
    $deleteResult.recordID:=$recordID
    $deleteResult.companyID:=$companyID
    $deleteResult.requestedBy:=$userID
    
    Try
        // Validate input parameters
        If ($tableName="") || ($recordID=0) || ($companyID="")
            $deleteResult.message:="Table name, record ID, and company ID are required"
            return $deleteResult
        End if
        
        // Check if user has permission to delete records
        If (Not(hasDeletePermission($userID; $tableName; $companyID)))
            $deleteResult.message:="User does not have permission to delete records in table: "+$tableName
            $deleteResult.permissionDenied:=True
            return $deleteResult
        End if
        
        // Verify record exists before attempting deletion
        $recordExists:=verifyRecordExists($tableName; $recordID; $companyID)
        
        If (Not($recordExists))
            $deleteResult.message:="Record not found - ID: "+String($recordID)+" in table: "+$tableName
            $deleteResult.recordNotFound:=True
            return $deleteResult
        End if
        
        // Check for dependent records
        var $dependencyCheck : Object
        $dependencyCheck:=checkRecordDependencies($tableName; $recordID; $companyID)
        
        If ($dependencyCheck.hasDependencies)
            $deleteResult.message:="Cannot delete record - dependent records exist: "+$dependencyCheck.dependencyDetails.join(", ")
            $deleteResult.hasDependencies:=True
            $deleteResult.dependencies:=$dependencyCheck.dependencies
            return $deleteResult
        End if
        
        // Create backup before deletion
        var $backupResult : Object
        $backupResult:=createRecordBackup($tableName; $recordID; $companyID)
        
        If ($backupResult.success)
            $deleteResult.backupID:=$backupResult.backupID
        End if
        
        // Perform the deletion
        $settings:=cs.responseSettings.new()
        $settings.CompanyID:=$companyID
        $settings.TableName:=$tableName
        $settings.UniqueID:=$recordID
        
        $deleteAPI:=cs.OdysseyAPI.deleteRecord.new($settings)
        $result:=$deleteAPI.request.run()
        
        If (Bool($result.Success))
            $deleteResult.success:=True
            $deleteResult.message:="Record deleted successfully"
            
            // Log successful deletion
            logRecordDeletion("SUCCESS"; $tableName; $recordID; $companyID; $userID)
            
            // Update related caches
            invalidateRecordCache($tableName; $recordID; $companyID)
            
            // Send audit notification
            sendDeletionAuditNotification($deleteResult)
            
        Else 
            $deleteResult.message:="Delete operation failed: "+String($result.ErrorMessage)
            $deleteResult.errorCode:=$result.statusCode
            
            // Log failed deletion
            logRecordDeletion("FAILED"; $tableName; $recordID; $companyID; $result.ErrorMessage)
        End if
        
    Catch
        $deleteResult.message:="Delete operation error: "+Last errors[0].message
        $deleteResult.exception:=True
        
        // Log deletion exception
        logRecordDeletion("ERROR"; $tableName; $recordID; $companyID; Last errors[0].message)
    End try
    
    return $deleteResult
```

### Batch Record Deletion
```4d
// Function to delete multiple records with validation
Function batchDeleteRecords($deleteRequests : Collection) : Collection
    var $batchResults : Collection
    var $deleteRequest : Object
    var $deleteResult : Object
    var $i : Integer
    
    $batchResults:=New collection()
    
    For ($i; 0; $deleteRequests.length-1)
        $deleteRequest:=$deleteRequests[$i]
        
        Try
            // Delete each record safely
            $deleteResult:=safeDeleteRecord(\
                $deleteRequest.tableName; \
                $deleteRequest.recordID; \
                $deleteRequest.companyID; \
                $deleteRequest.userID)
            
            // Add batch context
            $deleteResult.batchIndex:=$i
            $deleteResult.requestID:=$deleteRequest.requestID
            
            $batchResults.push($deleteResult)
            
        Catch
            // Add error entry for failed deletion
            $batchResults.push(New object(\
                "success"; False; \
                "batchIndex"; $i; \
                "requestID"; $deleteRequest.requestID; \
                "tableName"; $deleteRequest.tableName; \
                "recordID"; $deleteRequest.recordID; \
                "message"; "Exception during deletion: "+Last errors[0].message; \
                "exception"; True))
        End try
        
        // Add small delay to avoid overwhelming the API
        DELAY PROCESS(Current process; 50)  // 0.5 second delay
    End for
    
    return $batchResults
```

### Conditional Record Deletion
```4d
// Function to delete records based on conditions
Function conditionalDeleteRecord($tableName : Text; $recordID : Integer; $companyID : Text; $conditions : Object; $userID : Text) : Object
    var $conditionalResult : Object
    var $recordData : Object
    var $conditionsMet : Boolean
    var $deleteResult : Object
    
    $conditionalResult:=New object()
    $conditionalResult.success:=False
    $conditionalResult.conditionsMet:=False
    $conditionalResult.tableName:=$tableName
    $conditionalResult.recordID:=$recordID
    
    Try
        // Get current record data to check conditions
        $recordData:=getRecordData($tableName; $recordID; $companyID)
        
        If ($recordData=Null)
            $conditionalResult.message:="Record not found for condition checking"
            return $conditionalResult
        End if
        
        // Check all conditions
        $conditionsMet:=True
        var $field : Text
        For each ($field; $conditions)
            If ($recordData[$field]#$conditions[$field])
                $conditionsMet:=False
                $conditionalResult.failedCondition:=$field
                $conditionalResult.expectedValue:=$conditions[$field]
                $conditionalResult.actualValue:=$recordData[$field]
                break
            End if
        End for each
        
        $conditionalResult.conditionsMet:=$conditionsMet
        
        If ($conditionsMet)
            // Conditions met, proceed with deletion
            $deleteResult:=safeDeleteRecord($tableName; $recordID; $companyID; $userID)
            $conditionalResult.success:=$deleteResult.success
            $conditionalResult.message:=$deleteResult.message
            $conditionalResult.deleteDetails:=$deleteResult
        Else 
            $conditionalResult.message:="Delete conditions not met - condition '"+$field+"' failed"
        End if
        
    Catch
        $conditionalResult.message:="Conditional delete error: "+Last errors[0].message
        $conditionalResult.exception:=True
    End try
    
    return $conditionalResult
```

### Soft Delete Implementation
```4d
// Function to implement soft delete (mark as deleted instead of physical deletion)
Function softDeleteRecord($tableName : Text; $recordID : Integer; $companyID : Text; $userID : Text) : Object
    var $softDeleteResult : Object
    var $updateData : Object
    var $updateResult : Object
    
    $softDeleteResult:=New object()
    $softDeleteResult.success:=False
    $softDeleteResult.tableName:=$tableName
    $softDeleteResult.recordID:=$recordID
    $softDeleteResult.deletionType:="SOFT"
    
    Try
        // Check if table supports soft delete
        If (Not(tableSupporstSoftDelete($tableName)))
            $softDeleteResult.message:="Table does not support soft delete: "+$tableName
            return $softDeleteResult
        End if
        
        // Prepare soft delete update
        $updateData:=New object()
        $updateData.IsDeleted:=True
        $updateData.DeletedAt:=String(Current date; ISO date GMT; Current time)
        $updateData.DeletedBy:=$userID
        $updateData.DeletionReason:="Soft delete operation"
        
        // Update record to mark as deleted
        $updateResult:=updateRecord($tableName; $recordID; $companyID; $updateData)
        
        If ($updateResult.success)
            $softDeleteResult.success:=True
            $softDeleteResult.message:="Record soft deleted successfully"
            $softDeleteResult.deletedAt:=$updateData.DeletedAt
            
            // Log soft deletion
            logRecordDeletion("SOFT_DELETE"; $tableName; $recordID; $companyID; $userID)
            
            // Update search indexes to exclude soft deleted records
            updateSearchIndexes($tableName; $recordID; "EXCLUDE")
            
        Else 
            $softDeleteResult.message:="Soft delete failed: "+$updateResult.message
        End if
        
    Catch
        $softDeleteResult.message:="Soft delete error: "+Last errors[0].message
        $softDeleteResult.exception:=True
    End try
    
    return $softDeleteResult
```

### Record Recovery Function
```4d
// Function to recover a deleted record from backup
Function recoverDeletedRecord($tableName : Text; $recordID : Integer; $companyID : Text; $backupID : Text; $userID : Text) : Object
    var $recoveryResult : Object
    var $backupData : Object
    var $restoreResult : Object
    
    $recoveryResult:=New object()
    $recoveryResult.success:=False
    $recoveryResult.tableName:=$tableName
    $recoveryResult.recordID:=$recordID
    $recoveryResult.backupID:=$backupID
    
    Try
        // Validate recovery permissions
        If (Not(hasRecoveryPermission($userID; $tableName; $companyID)))
            $recoveryResult.message:="User does not have permission to recover records"
            $recoveryResult.permissionDenied:=True
            return $recoveryResult
        End if
        
        // Retrieve backup data
        $backupData:=getRecordBackup($backupID)
        
        If ($backupData=Null)
            $recoveryResult.message:="Backup not found: "+$backupID
            $recoveryResult.backupNotFound:=True
            return $recoveryResult
        End if
        
        // Verify backup matches request
        If ($backupData.tableName#$tableName) || ($backupData.recordID#$recordID)
            $recoveryResult.message:="Backup does not match recovery request"
            return $recoveryResult
        End if
        
        // Check if record currently exists
        If (verifyRecordExists($tableName; $recordID; $companyID))
            $recoveryResult.message:="Cannot recover - record already exists with ID: "+String($recordID)
            $recoveryResult.recordExists:=True
            return $recoveryResult
        End if
        
        // Restore record from backup
        $restoreResult:=restoreRecordFromBackup($backupData; $companyID)
        
        If ($restoreResult.success)
            $recoveryResult.success:=True
            $recoveryResult.message:="Record recovered successfully from backup"
            $recoveryResult.restoredData:=$backupData.recordData
            
            // Log recovery operation
            logRecordRecovery($tableName; $recordID; $companyID; $userID; $backupID)
            
            // Update caches
            invalidateRecordCache($tableName; $recordID; $companyID)
            
        Else 
            $recoveryResult.message:="Recovery failed: "+$restoreResult.message
        End if
        
    Catch
        $recoveryResult.message:="Recovery error: "+Last errors[0].message
        $recoveryResult.exception:=True
    End try
    
    return $recoveryResult
```

### Scheduled Cleanup Operations
```4d
// Function to perform scheduled cleanup of old records
Function performScheduledCleanup($cleanupRules : Collection) : Object
    var $cleanupResult : Object
    var $rule : Object
    var $recordsToDelete : Collection
    var $deleteResults : Collection
    var $totalDeleted : Integer
    
    $cleanupResult:=New object()
    $cleanupResult.success:=False
    $cleanupResult.timestamp:=String(Current date; ISO date GMT; Current time)
    $cleanupResult.rulesProcessed:=0
    $cleanupResult.totalRecordsDeleted:=0
    $cleanupResult.ruleResults:=New collection()
    
    Try
        For each ($rule; $cleanupRules)
            var $ruleResult : Object
            $ruleResult:=New object()
            $ruleResult.ruleName:=$rule.name
            $ruleResult.tableName:=$rule.tableName
            $ruleResult.recordsDeleted:=0
            
            Try
                // Find records matching cleanup criteria
                $recordsToDelete:=findRecordsForCleanup($rule)
                
                If ($recordsToDelete.length>0)
                    // Build delete requests
                    var $deleteRequests : Collection
                    $deleteRequests:=New collection()
                    
                    For each (var $record; $recordsToDelete)
                        $deleteRequests.push(New object(\
                            "tableName"; $rule.tableName; \
                            "recordID"; $record.ID; \
                            "companyID"; $rule.companyID; \
                            "userID"; "SYSTEM_CLEANUP"; \
                            "requestID"; "CLEANUP_"+String($record.ID)))
                    End for each
                    
                    // Execute batch deletion
                    $deleteResults:=batchDeleteRecords($deleteRequests)
                    
                    // Count successful deletions
                    For each (var $deleteResult; $deleteResults)
                        If ($deleteResult.success)
                            $ruleResult.recordsDeleted:=$ruleResult.recordsDeleted+1
                        End if
                    End for each
                    
                    $ruleResult.success:=True
                    $ruleResult.message:="Cleanup rule processed successfully"
                Else 
                    $ruleResult.success:=True
                    $ruleResult.message:="No records found matching cleanup criteria"
                End if
                
            Catch
                $ruleResult.success:=False
                $ruleResult.message:="Cleanup rule error: "+Last errors[0].message
                $ruleResult.exception:=True
            End try
            
            $cleanupResult.ruleResults.push($ruleResult)
            $cleanupResult.rulesProcessed:=$cleanupResult.rulesProcessed+1
            $cleanupResult.totalRecordsDeleted:=$cleanupResult.totalRecordsDeleted+$ruleResult.recordsDeleted
        End for each
        
        $cleanupResult.success:=True
        $cleanupResult.message:="Scheduled cleanup completed successfully"
        
        // Log cleanup summary
        logCleanupSummary($cleanupResult)
        
        // Send cleanup report
        sendCleanupReport($cleanupResult)
        
    Catch
        $cleanupResult.message:="Scheduled cleanup error: "+Last errors[0].message
        $cleanupResult.exception:=True
    End try
    
    return $cleanupResult
```

### Deletion Audit and Compliance
```4d
// Function to generate deletion audit report
Function generateDeletionAuditReport($companyID : Text; $auditParams : Object) : Object
    var $auditReport : Object
    var $deletionLog : Collection
    var $auditAnalysis : Object
    
    $auditReport:=New object()
    $auditReport.success:=False
    $auditReport.companyID:=$companyID
    $auditReport.reportDate:=String(Current date; ISO date GMT; Current time)
    $auditReport.auditParams:=$auditParams
    
    Try
        // Retrieve deletion log for audit period
        $deletionLog:=getDeletionLogForPeriod($companyID; $auditParams.startDate; $auditParams.endDate)
        
        If ($deletionLog.length>0)
            // Analyze deletion patterns
            $auditAnalysis:=analyzeDeletionPatterns($deletionLog)
            
            $auditReport.totalDeletions:=$deletionLog.length
            $auditReport.deletionsByTable:=$auditAnalysis.tableBreakdown
            $auditReport.deletionsByUser:=$auditAnalysis.userBreakdown
            $auditReport.deletionsByType:=$auditAnalysis.typeBreakdown
            $auditReport.suspiciousActivity:=$auditAnalysis.suspiciousPatterns
            
            // Generate compliance summary
            $auditReport.complianceStatus:=assessDeletionCompliance($deletionLog; $auditParams.complianceRules)
            
            // Create detailed audit trail
            $auditReport.auditTrail:=createDetailedAuditTrail($deletionLog)
            
            $auditReport.success:=True
            $auditReport.message:="Deletion audit report generated successfully"
            
            // Store audit report
            storeAuditReport($auditReport)
            
        Else 
            $auditReport.message:="No deletion records found for the specified period"
        End if
        
    Catch
        $auditReport.message:="Audit report error: "+Last errors[0].message
        $auditReport.exception:=True
    End try
    
    return $auditReport
```

## Integration Patterns

### REST API Wrapper
```4d
// RESTful delete endpoint wrapper
Function handleRESTDelete($request : Object) : Object
    var $tableName; $companyID; $userID : Text
    var $recordID : Integer
    var $deleteResult : Object
    var $response : Object
    
    // Extract parameters from REST request
    $tableName:=$request.params.table
    $recordID:=Num($request.params.id)
    $companyID:=$request.params.company
    $userID:=$request.user.id
    
    // Validate request
    If ($tableName="") || ($recordID=0) || ($companyID="")
        $response:=New object("success"; False; "error"; "Table name, record ID, and company ID are required")
        return $response
    End if
    
    // Execute safe deletion
    $deleteResult:=safeDeleteRecord($tableName; $recordID; $companyID; $userID)
    
    // Format response
    $response:=New object()
    $response.success:=$deleteResult.success
    $response.timestamp:=String(Current date; ISO date GMT; Current time)
    $response.table:=$tableName
    $response.recordID:=$recordID
    $response.company:=$companyID
    
    If ($deleteResult.success)
        $response.message:="Record deleted successfully"
        If ($deleteResult.backupID#"")
            $response.backupID:=$deleteResult.backupID
        End if
    Else 
        $response.error:=$deleteResult.message
        
        If ($deleteResult.permissionDenied)
            $response.permissionDenied:=True
        End if
        
        If ($deleteResult.hasDependencies)
            $response.dependencies:=$deleteResult.dependencies
        End if
    End if
    
    return $response
```

### Database Transaction Management
```4d
// Function to manage deletions within database transactions
Function transactionalDelete($deleteOperations : Collection; $companyID : Text; $userID : Text) : Object
    var $transactionResult : Object
    var $transactionID : Text
    var $operation : Object
    var $deleteResult : Object
    var $rollbackNeeded : Boolean
    
    $transactionResult:=New object()
    $transactionResult.success:=False
    $transactionResult.operationsCompleted:=0
    $transactionResult.operationResults:=New collection()
    
    // Start database transaction
    $transactionID:=startDatabaseTransaction()
    
    Try
        For each ($operation; $deleteOperations)
            $deleteResult:=safeDeleteRecord(\
                $operation.tableName; \
                $operation.recordID; \
                $companyID; \
                $userID)
            
            $deleteResult.operationIndex:=$transactionResult.operationsCompleted
            $transactionResult.operationResults.push($deleteResult)
            
            If ($deleteResult.success)
                $transactionResult.operationsCompleted:=$transactionResult.operationsCompleted+1
            Else 
                // Mark for rollback on any failure
                $rollbackNeeded:=True
                break
            End if
        End for each
        
        If ($rollbackNeeded)
            // Rollback transaction
            rollbackDatabaseTransaction($transactionID)
            $transactionResult.message:="Transaction rolled back due to deletion failure"
        Else 
            // Commit transaction
            commitDatabaseTransaction($transactionID)
            $transactionResult.success:=True
            $transactionResult.message:="All deletions completed successfully"
        End if
        
    Catch
        rollbackDatabaseTransaction($transactionID)
        $transactionResult.message:="Transaction error: "+Last errors[0].message
        $transactionResult.exception:=True
    End try
    
    return $transactionResult
```

## Security Considerations

1. **Access Control**: Always verify user permissions before allowing record deletions
2. **Audit Logging**: Log all deletion operations with user, timestamp, and reason
3. **Backup Strategy**: Create backups before deletion for recovery purposes
4. **Dependency Checking**: Verify no dependent records exist before deletion
5. **Soft Delete Option**: Consider soft delete for critical data that may need recovery
6. **Rate Limiting**: Implement rate limiting to prevent abuse of delete operations

## Key Features

1. **Safe Deletion**: Comprehensive validation and permission checking before deletion
2. **Backup Creation**: Automatic backup creation before record deletion
3. **Dependency Checking**: Verification of related records before deletion
4. **Batch Operations**: Support for multiple record deletions
5. **Soft Delete Support**: Option to mark records as deleted instead of physical removal
6. **Recovery Functionality**: Ability to recover deleted records from backups
7. **Audit Trail**: Complete audit logging for compliance and security
8. **Conditional Deletion**: Delete records only when specific conditions are met

## Notes

- This class is specifically designed for the Odyssey API system
- The endpoint requires CompanyID, TableName, and UniqueID in the request body
- Uses the `requestClass` for HTTP communication and error handling
- Designed for single record deletion - use batch functions for multiple records
- The class automatically calls the deleteRecord endpoint during construction
- Results are available through the `request.run()` method
- Always implement proper backup and recovery procedures before using in production
- Consider implementing soft delete for critical business data
- Deletion operations should be carefully audited and logged for compliance
- Implement proper access controls and permission checking before allowing deletions