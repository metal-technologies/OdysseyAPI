<!-- Type your summary here -->
# findRecord Class Documentation

## Overview
The `findRecord` class is a specialized API client for locating specific records in the Odyssey API system. This class provides a powerful interface to search for individual records in specified database tables using field criteria, making it essential for data retrieval, record lookup, and search functionality in applications.

## Class Information
- **Namespace**: `cs.OdysseyAPI.FindRecord`
- **API Endpoint**: `/Record/Find`
- **Base URL**: `https://api.blinfo.com/metaltech/Record/Find`
- **HTTP Method**: POST
- **Authentication**: Requires API key and proper authentication

## Properties

### Core Properties
- `request` (cs.request) - The underlying request object that handles HTTP communication
- `settings` (Object) - Configuration settings object passed to the constructor

## Constructor

```4d
Class constructor($settings : Object)
    $settings.apiURL:="https://api.blinfo.com/metaltech/Record/Find"
    $settings.apiMethod:="POST"
    This.request:=cs.request.new($settings)
    This.request.findRecord()
    This.settings:=$settings
```

The constructor automatically configures the API endpoint and HTTP method, creates a request object, and calls the findRecord endpoint.

### Parameters
- `$settings` (Object) - A settings object, typically `cs.responseSettings.new()` containing:
  - `CompanyID` (Text) - Company identifier
  - `TableName` (Text) - Target table name
  - `ListOfFieldValues` (Collection) - Collection of field name-value pairs to search for

### Example Usage
```4d
var $settings : Object
var $findAPI : cs.OdysseyAPI.FindRecord

// Create settings object with search parameters
$settings:=cs.responseSettings.new()
$settings.CompanyID:="ACME_CORP"
$settings.TableName:="Customers"
$settings.ListOfFieldValues:=New collection()

// Initialize find record API client
$findAPI:=cs.OdysseyAPI.FindRecord.new($settings)
```

## Usage Examples

### Basic Record Search
```4d
var $settings : Object
var $findAPI : cs.OdysseyAPI.FindRecord
var $result : Object

// Initialize settings
$settings:=cs.responseSettings.new()
$settings.CompanyID:="COMP001"
$settings.TableName:="Customers"

// Build search criteria
$settings.ListOfFieldValues:=New collection()
$settings.ListOfFieldValues.push(New object("Key"; "Email"; "Value"; "john.doe@example.com"))

// Create find API instance and execute
$findAPI:=cs.OdysseyAPI.FindRecord.new($settings)
$result:=$findAPI.request.run()

If (Bool($result.Success))
    If ($result.data.length>0)
        var $customer : Object
        $customer:=$result.data[0]
        ALERT("Customer found: "+String($customer.FirstName)+" "+String($customer.LastName))
    Else 
        ALERT("No customer found with that email address")
    End if
Else 
    ALERT("Search failed: "+String($result.ErrorMessage))
End if
```

### Customer Lookup Function
```4d
// Function to find customer by various criteria
Function findCustomer($searchCriteria : Object; $companyID : Text) : Object
    var $settings : Object
    var $findAPI : cs.OdysseyAPI.FindRecord
    var $result : Object
    var $searchResult : Object
    
    // Initialize search result
    $searchResult:=New object()
    $searchResult.found:=False
    $searchResult.timestamp:=String(Current date; ISO date GMT; Current time)
    $searchResult.searchCriteria:=$searchCriteria
    $searchResult.companyID:=$companyID
    
    Try
        // Set up search request
        $settings:=cs.responseSettings.new()
        $settings.CompanyID:=$companyID
        $settings.TableName:="Customers"
        $settings.ListOfFieldValues:=New collection()
        
        // Build search criteria from input object
        var $field : Text
        For each ($field; $searchCriteria)
            If ($searchCriteria[$field]#"")
                $settings.ListOfFieldValues.push(New object(\
                    "Key"; $field; \
                    "Value"; String($searchCriteria[$field])))
            End if
        End for each
        
        // Execute search
        $findAPI:=cs.OdysseyAPI.FindRecord.new($settings)
        $result:=$findAPI.request.run()
        
        If (Bool($result.Success))
            If ($result.data.length>0)
                $searchResult.found:=True
                $searchResult.customer:=$result.data[0]
                $searchResult.recordCount:=$result.data.length
                $searchResult.message:="Customer found successfully"
                
                // Log successful search
                logSearchEvent("SUCCESS"; "Customers"; $searchCriteria; $companyID)
                
            Else 
                $searchResult.message:="No customer found matching the search criteria"
                logSearchEvent("NO_RESULTS"; "Customers"; $searchCriteria; $companyID)
            End if
        Else 
            $searchResult.message:="Search failed: "+String($result.ErrorMessage)
            $searchResult.errorCode:=$result.statusCode
            
            // Log failed search
            logSearchEvent("FAILED"; "Customers"; $searchCriteria; $result.ErrorMessage)
        End if
        
    Catch
        $searchResult.message:="Search error: "+Last errors[0].message
        $searchResult.exception:=True
        
        // Log search exception
        logSearchEvent("ERROR"; "Customers"; $searchCriteria; Last errors[0].message)
    End try
    
    return $searchResult
```

### Multi-Field Search
```4d
// Function to search using multiple field criteria
Function findRecordByMultipleFields($tableName : Text; $companyID : Text; $searchFields : Object) : Object
    var $settings : Object
    var $findAPI : cs.OdysseyAPI.FindRecord
    var $result : Object
    var $searchResult : Object
    
    $searchResult:=New object()
    $searchResult.found:=False
    $searchResult.tableName:=$tableName
    $searchResult.searchFields:=$searchFields
    
    Try
        // Validate input
        If ($tableName="") || ($companyID="")
            $searchResult.message:="Table name and company ID are required"
            return $searchResult
        End if
        
        If (OB Is empty($searchFields))
            $searchResult.message:="At least one search field is required"
            return $searchResult
        End if
        
        // Set up search request
        $settings:=cs.responseSettings.new()
        $settings.CompanyID:=$companyID
        $settings.TableName:=$tableName
        $settings.ListOfFieldValues:=New collection()
        
        // Build field values collection
        var $fieldName : Text
        For each ($fieldName; $searchFields)
            $settings.ListOfFieldValues.push(New object(\
                "Key"; $fieldName; \
                "Value"; String($searchFields[$fieldName])))
        End for each
        
        // Execute search
        $findAPI:=cs.OdysseyAPI.FindRecord.new($settings)
        $result:=$findAPI.request.run()
        
        If (Bool($result.Success))
            $searchResult.found:=($result.data.length>0)
            $searchResult.records:=$result.data
            $searchResult.recordCount:=$result.data.length
            
            If ($searchResult.found)
                $searchResult.message:="Found "+String($result.data.length)+" record(s)"
            Else 
                $searchResult.message:="No records found matching criteria"
            End if
        Else 
            $searchResult.message:="Search failed: "+String($result.ErrorMessage)
            $searchResult.errorCode:=$result.statusCode
        End if
        
    Catch
        $searchResult.message:="Multi-field search error: "+Last errors[0].message
        $searchResult.exception:=True
    End try
    
    return $searchResult
```

### Record Existence Checker
```4d
// Function to check if a record exists
Function recordExists($tableName : Text; $companyID : Text; $keyField : Text; $keyValue : Text) : Boolean
    var $searchCriteria : Object
    var $searchResult : Object
    
    // Build simple search criteria
    $searchCriteria:=New object()
    $searchCriteria[$keyField]:=$keyValue
    
    // Perform search
    $searchResult:=findRecordByMultipleFields($tableName; $companyID; $searchCriteria)
    
    return $searchResult.found
```

### Duplicate Detection Function
```4d
// Function to find duplicate records
Function findDuplicateRecords($tableName : Text; $companyID : Text; $duplicateFields : Collection) : Collection
    var $duplicates : Collection
    var $field : Object
    var $searchResult : Object
    var $i : Integer
    
    $duplicates:=New collection()
    
    For ($i; 0; $duplicateFields.length-1)
        $field:=$duplicateFields[$i]
        
        // Search for records with this field value
        var $searchCriteria : Object
        $searchCriteria:=New object()
        $searchCriteria[$field.fieldName]:=$field.fieldValue
        
        $searchResult:=findRecordByMultipleFields($tableName; $companyID; $searchCriteria)
        
        If ($searchResult.found) && ($searchResult.recordCount>1)
            // Found duplicates
            var $duplicateEntry : Object
            $duplicateEntry:=New object()
            $duplicateEntry.fieldName:=$field.fieldName
            $duplicateEntry.fieldValue:=$field.fieldValue
            $duplicateEntry.duplicateCount:=$searchResult.recordCount
            $duplicateEntry.records:=$searchResult.records
            
            $duplicates.push($duplicateEntry)
        End if
    End for
    
    return $duplicates
```

### Advanced Search with Form Integration
```4d
// Method to handle advanced search form
Function handleAdvancedSearchForm()
    var $searchCriteria : Object
    var $searchResult : Object
    var $tableName; $companyID : Text
    
    // Get form values
    $tableName:=Form.tableName
    $companyID:=Form.companyID
    
    // Validate required fields
    If ($tableName="") || ($companyID="")
        ALERT("Table name and company are required")
        return
    End if
    
    // Build search criteria from form
    $searchCriteria:=New object()
    
    If (Form.searchFirstName#"")
        $searchCriteria.FirstName:=Form.searchFirstName
    End if
    If (Form.searchLastName#"")
        $searchCriteria.LastName:=Form.searchLastName
    End if
    If (Form.searchEmail#"")
        $searchCriteria.Email:=Form.searchEmail
    End if
    If (Form.searchPhone#"")
        $searchCriteria.Phone:=Form.searchPhone
    End if
    If (Form.searchCompany#"")
        $searchCriteria.Company:=Form.searchCompany
    End if
    
    // Check if any search criteria were provided
    If (OB Is empty($searchCriteria))
        ALERT("Please enter at least one search criterion")
        return
    End if
    
    // Show loading indicator
    Form.searchInProgress:=True
    OBJECT SET ENABLED(Form.searchButton; False)
    
    // Perform search
    $searchResult:=findRecordByMultipleFields($tableName; $companyID; $searchCriteria)
    
    If ($searchResult.found)
        // Display results
        Form.searchResults:=$searchResult.records
        Form.resultCount:=$searchResult.recordCount
        Form.searchMessage:="Found "+String($searchResult.recordCount)+" record(s)"
        
        // Show results area
        OBJECT SET VISIBLE(Form.resultsArea; True)
    Else 
        // No results found
        Form.searchResults:=New collection()
        Form.resultCount:=0
        Form.searchMessage:=$searchResult.message
        
        // Hide results area
        OBJECT SET VISIBLE(Form.resultsArea; False)
        
        If (Not($searchResult.exception))
            ALERT("No records found matching your search criteria")
        Else 
            ALERT("Search error: "+$searchResult.message)
        End if
    End if
    
    // Hide loading indicator
    Form.searchInProgress:=False
    OBJECT SET ENABLED(Form.searchButton; True)
```

### Cached Record Lookup
```4d
// Function to find records with caching support
Function findRecordCached($tableName : Text; $companyID : Text; $searchCriteria : Object; $cacheTimeout : Integer) : Object
    var $cacheKey : Text
    var $cachedResult : Object
    var $searchResult : Object
    
    // Generate cache key from search criteria
    $cacheKey:=generateSearchCacheKey($tableName; $companyID; $searchCriteria)
    
    // Check cache first
    $cachedResult:=getFromSearchCache($cacheKey)
    
    If ($cachedResult#Null)
        // Return cached result
        $cachedResult.fromCache:=True
        $cachedResult.cacheHit:=True
        return $cachedResult
    Else 
        // Perform fresh search
        $searchResult:=findRecordByMultipleFields($tableName; $companyID; $searchCriteria)
        
        If ($searchResult.found)
            // Cache successful results
            $searchResult.cachedAt:=String(Current date; ISO date GMT; Current time)
            $searchResult.fromCache:=False
            $searchResult.cacheHit:=False
            
            storeInSearchCache($cacheKey; $searchResult; $cacheTimeout)
        End if
        
        return $searchResult
    End if
```

### Batch Record Lookup
```4d
// Function to find multiple records in batch
Function findMultipleRecords($searchRequests : Collection) : Collection
    var $batchResults : Collection
    var $searchRequest : Object
    var $searchResult : Object
    var $i : Integer
    
    $batchResults:=New collection()
    
    For ($i; 0; $searchRequests.length-1)
        $searchRequest:=$searchRequests[$i]
        
        Try
            // Find record using provided criteria
            $searchResult:=findRecordByMultipleFields(\
                $searchRequest.tableName; \
                $searchRequest.companyID; \
                $searchRequest.searchCriteria)
            
            // Add batch context
            $searchResult.batchIndex:=$i
            $searchResult.requestID:=$searchRequest.requestID
            
            $batchResults.push($searchResult)
            
        Catch
            // Add error entry for failed search
            $batchResults.push(New object(\
                "found"; False; \
                "batchIndex"; $i; \
                "requestID"; $searchRequest.requestID; \
                "message"; "Exception during search: "+Last errors[0].message; \
                "exception"; True))
        End try
        
        // Add small delay to avoid overwhelming the API
        DELAY PROCESS(Current process; 100)  // 1 second delay
    End for
    
    return $batchResults
```

### Record Relationship Finder
```4d
// Function to find related records
Function findRelatedRecords($primaryRecord : Object; $relationshipConfig : Object) : Object
    var $relatedData : Object
    var $relationship : Object
    var $searchResult : Object
    var $relationName : Text
    
    $relatedData:=New object()
    $relatedData.primaryRecord:=$primaryRecord
    $relatedData.relationships:=New object()
    
    // Find related records for each configured relationship
    For each ($relationName; $relationshipConfig)
        $relationship:=$relationshipConfig[$relationName]
        
        // Build search criteria for this relationship
        var $searchCriteria : Object
        $searchCriteria:=New object()
        $searchCriteria[$relationship.foreignKey]:=$primaryRecord[$relationship.primaryKey]
        
        // Find related records
        $searchResult:=findRecordByMultipleFields(\
            $relationship.relatedTable; \
            $primaryRecord.CompanyID; \
            $searchCriteria)
        
        // Store relationship results
        $relatedData.relationships[$relationName]:=New object(\
            "found"; $searchResult.found; \
            "records"; $searchResult.records; \
            "count"; $searchResult.recordCount; \
            "relationshipType"; $relationship.type)
    End for each
    
    return $relatedData
```

### Search Analytics
```4d
// Function to track and analyze search patterns
Function trackSearchAnalytics($searchCriteria : Object; $tableName : Text; $companyID : Text; $resultCount : Integer)
    var $analytics : Object
    
    $analytics:=New object()
    $analytics.timestamp:=String(Current date; ISO date GMT; Current time)
    $analytics.tableName:=$tableName
    $analytics.companyID:=$companyID
    $analytics.searchCriteria:=$searchCriteria
    $analytics.resultCount:=$resultCount
    $analytics.user:=Current user
    $analytics.sessionID:=getCurrentSessionID()
    
    // Count search fields used
    $analytics.fieldsSearched:=OB Keys($searchCriteria).length
    
    // Categorize search type
    Case of 
        : ($analytics.fieldsSearched=1)
            $analytics.searchType:="Single Field"
        : ($analytics.fieldsSearched<=3)
            $analytics.searchType:="Multi Field"
        Else 
            $analytics.searchType:="Complex"
    End case
    
    // Determine search effectiveness
    Case of 
        : ($resultCount=0)
            $analytics.effectiveness:="No Results"
        : ($resultCount=1)
            $analytics.effectiveness:="Exact Match"
        : ($resultCount<=5)
            $analytics.effectiveness:="Good Results"
        Else 
            $analytics.effectiveness:="Too Many Results"
    End case
    
    // Store analytics data
    storeSearchAnalytics($analytics)
    
    // Update search statistics
    updateSearchStatistics($tableName; $companyID; $analytics.searchType; $analytics.effectiveness)
```

## Integration Patterns

### REST API Wrapper
```4d
// RESTful search endpoint wrapper
Function handleRESTSearch($request : Object) : Object
    var $tableName; $companyID : Text
    var $searchCriteria : Object
    var $searchResult : Object
    var $response : Object
    
    // Extract parameters from REST request
    $tableName:=$request.params.table
    $companyID:=$request.params.company
    $searchCriteria:=$request.body.criteria
    
    // Validate request
    If ($tableName="") || ($companyID="") || (OB Is empty($searchCriteria))
        $response:=New object("success"; False; "error"; "Table name, company ID, and search criteria are required")
        return $response
    End if
    
    // Execute search
    $searchResult:=findRecordByMultipleFields($tableName; $companyID; $searchCriteria)
    
    // Format response
    $response:=New object()
    $response.success:=$searchResult.found
    $response.timestamp:=String(Current date; ISO date GMT; Current time)
    $response.table:=$tableName
    $response.company:=$companyID
    $response.searchCriteria:=$searchCriteria
    
    If ($searchResult.found)
        $response.records:=$searchResult.records
        $response.count:=$searchResult.recordCount
        $response.message:="Search completed successfully"
    Else 
        $response.message:=$searchResult.message
        $response.records:=New collection()
        $response.count:=0
        
        If ($searchResult.exception)
            $response.error:=$searchResult.message
        End if
    End if
    
    return $response
```

### Auto-Complete Integration
```4d
// Function for auto-complete search functionality
Function performAutoCompleteSearch($tableName : Text; $companyID : Text; $fieldName : Text; $searchTerm : Text; $maxResults : Integer) : Collection
    var $suggestions : Collection
    var $searchCriteria : Object
    var $searchResult : Object
    
    $suggestions:=New collection()
    
    If (Length($searchTerm)>=2)  // Minimum 2 characters for auto-complete
        // Create search criteria with partial match
        $searchCriteria:=New object()
        $searchCriteria[$fieldName]:=$searchTerm+"*"  // Assuming wildcard support
        
        // Perform search
        $searchResult:=findRecordByMultipleFields($tableName; $companyID; $searchCriteria)
        
        If ($searchResult.found)
            // Extract unique values for suggestions
            var $record : Object
            var $uniqueValues : Collection
            $uniqueValues:=New collection()
            
            For each ($record; $searchResult.records)
                var $value : Text
                $value:=String($record[$fieldName])
                
                If ($uniqueValues.indexOf($value)=-1) && ($uniqueValues.length<$maxResults)
                    $uniqueValues.push($value)
                End if
            End for each
            
            $suggestions:=$uniqueValues
        End if
    End if
    
    return $suggestions
```

## Security Considerations

1. **Access Control**: Verify user permissions before allowing record searches
2. **Input Sanitization**: Sanitize search criteria to prevent injection attacks
3. **Rate Limiting**: Implement rate limiting to prevent abuse of search functionality
4. **Audit Logging**: Log search operations for security monitoring
5. **Data Privacy**: Ensure search results comply with data privacy regulations
6. **Field Restrictions**: Implement field-level security for sensitive data

## Key Features

1. **Flexible Search**: Search using any combination of field criteria
2. **Single Record Focus**: Optimized for finding specific individual records
3. **Multiple Field Support**: Search across multiple fields simultaneously
4. **Caching Support**: Optional caching to improve search performance
5. **Batch Operations**: Support for multiple search requests
6. **Integration Ready**: Easy integration with forms and auto-complete functionality
7. **Analytics Support**: Built-in search analytics and tracking
8. **Error Handling**: Comprehensive error reporting for failed searches

## Notes

- This class is specifically designed for the Odyssey API system
- The endpoint requires CompanyID, TableName, and ListOfFieldValues in the request body
- Designed to find single records rather than performing complex queries
- Ideal for record lookup, duplicate detection, and existence checking
- The class automatically calls the findRecord endpoint during construction
- Results are available through the `request.run()` method
- Consider implementing caching for frequently searched records
- Search criteria should be specific enough to avoid returning too many results
- Always validate search input and implement appropriate security measures
