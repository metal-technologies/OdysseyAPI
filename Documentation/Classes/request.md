# request Documentation

## Overview
The `requestClass` is a comprehensive HTTP API client class designed for making various types of API requests. It provides methods for common database operations like adding, updating, deleting, and finding records, as well as utility functions for login, data views, and system operations.

## Properties
The class contains numerous properties for managing API requests:

### Core Properties
- `settings` (Object) - Configuration settings for the request
- `body` (Object) - Request body data
- `headers` (Object) - HTTP headers
- `method` (Text) - HTTP method (GET, POST, etc.)
- `options` (Object) - Request options
- `apiCall` (4D.HTTPRequest) - The actual HTTP request object
- `result` (Object) - Response result

### Data Properties
- `CompanyID` (Text) - Company identifier
- `TableName` (Text) - Database table name
- `ListOfFieldValues` (Collection) - Field values for operations
- `DataView` (Text) - Data view identifier
- `UniqueID` (Integer) - Record unique identifier
- `Username` (Text) - User credentials
- `Password` (Text) - User credentials

## Constructor

```4d
Class constructor($settings)
    This.settings:=$settings
    This.headers:=This._requestHeaders()
```

The constructor takes a settings object and initializes the request headers.

### Example Usage
```4d
var $settings : cs.requestSettings
var $request : cs.requestClass

$settings:=cs.requestSettings.new()
$settings.apiKey:="your-api-key"
$settings.apiContentType:="application/json"
$settings.apiMethod:="POST"
$settings.apiURL:="https://api.example.com/data"
$settings.CompanyID:="COMP001"

$request:=cs.requestClass.new($settings)
```

## Main API Methods

### addRecord()
Adds a new record to the specified table.

```4d
Function addRecord()
    This.body:=This._addRecordBody(This.settings)
    This.options:=This._requestOptions(This.settings.apiMethod; This.headers; This.body)
```

**Example Usage:**
```4d
var $request : cs.requestClass
var $settings : cs.requestSettings

$settings:=cs.requestSettings.new()
// Configure settings...
$settings.TableName:="Customers"

$request:=cs.requestClass.new($settings)
$request.addFieldValueToList("Name"; "John Doe")
$request.addFieldValueToList("Email"; "john@example.com")
$request.addRecord()

var $result : Object
$result:=$request.run()
```

### updateRecord()
Updates an existing record by UniqueID.

```4d
Function updateRecord()
    This.body:=This._updateRecordBody(This.settings)
    This.options:=This._requestOptions(This.settings.apiMethod; This.headers; This.body)
```

**Example Usage:**
```4d
var $request : cs.requestClass
var $settings : cs.requestSettings

$settings:=cs.requestSettings.new()
// Configure settings...
$settings.TableName:="Customers"
$settings.UniqueID:=12345

$request:=cs.requestClass.new($settings)
$request.addFieldValueToList("Name"; "Jane Smith")
$request.addFieldValueToList("Email"; "jane@example.com")
$request.updateRecord()

var $result : Object
$result:=$request.run()
```

### deleteRecord()
Deletes a record by UniqueID.

```4d
Function deleteRecord()
    This.body:=This._deleteRecordBody(This.settings)
    This.options:=This._requestOptions(This.settings.apiMethod; This.headers; This.body)
```

**Example Usage:**
```4d
var $request : cs.requestClass
var $settings : cs.requestSettings

$settings:=cs.requestSettings.new()
// Configure settings...
$settings.TableName:="Customers"
$settings.UniqueID:=12345

$request:=cs.requestClass.new($settings)
$request.deleteRecord()

var $result : Object
$result:=$request.run()
```

### findRecord()
Finds records based on field values.

```4d
Function findRecord()
    This.body:=This._findRecordBody(This.settings)
    This.options:=This._requestOptions(This.settings.apiMethod; This.headers; This.body)
```

**Example Usage:**
```4d
var $request : cs.requestClass
var $settings : cs.requestSettings

$settings:=cs.requestSettings.new()
// Configure settings...
$settings.TableName:="Customers"

$request:=cs.requestClass.new($settings)
$request.addFieldValueToList("Email"; "john@example.com")
$request.findRecord()

var $result : Object
$result:=$request.run()
```

### dataview()
Executes a data view with optional parameters.

```4d
Function dataview()
    This.body:=This._dataviewBody(This.settings)
    This.options:=This._dataviewOptions()
```

**Example Usage:**
```4d
var $request : cs.requestClass
var $settings : cs.requestSettings

$settings:=cs.requestSettings.new()
// Configure settings...
$settings.DataView:="CustomerReport"
$settings.dataArrayName:="Customers"

$request:=cs.requestClass.new($settings)
$request.dataview()

// Add parameters if needed
$request.body.ParameterList:=$request.addParameterToList("Status"; "="; "Active")

var $result : Object
$result:=$request.run()
```

### login()
Authenticates a user with username and password.

```4d
Function login()
    This.body:=This._loginBody(This.settings)
    This.options:=This._requestOptions(This.settings.apiMethod; This.headers; This.body)
```

**Example Usage:**
```4d
var $request : cs.requestClass
var $settings : cs.requestSettings

$settings:=cs.requestSettings.new()
// Configure settings...
$settings.Username:="user@example.com"
$settings.Password:="password123"
$settings.CompanyID:="COMP001"

$request:=cs.requestClass.new($settings)
$request.login()

var $result : Object
$result:=$request.run()
```

## Utility Methods

### addParameterToList()
Adds a parameter to the parameter list for data views.

```4d
Function addParameterToList($fieldName : Text; $operator : Text; $parmValue : Text) : Collection
```

**Example Usage:**
```4d
var $request : cs.requestClass
var $paramList : Collection

$paramList:=$request.addParameterToList("CustomerID"; "="; "12345")
$paramList:=$request.addParameterToList("Status"; "!="; "Inactive")
```

### addFieldValueToList()
Adds field values for record operations.

```4d
Function addFieldValueToList($fieldName : Text; $fieldValue : Text)
```

**Example Usage:**
```4d
var $request : cs.requestClass

$request.addFieldValueToList("FirstName"; "John")
$request.addFieldValueToList("LastName"; "Doe")
$request.addFieldValueToList("Age"; "30")
```

### run()
Executes the HTTP request and returns the result.

```4d
Function run() : Object
```

**Example Usage:**
```4d
var $request : cs.requestClass
var $result : Object

// Configure and prepare request...
$request.addRecord()

// Execute the request
$result:=$request.run()

If (Bool($result.Success))
    // Handle success
    ALERT("Record added successfully")
Else 
    // Handle error
    ALERT("Error: "+$result.ErrorMessage)
End if
```

### errorRun()
Executes an error information request.

```4d
Function errorRun() : Object
```

**Example Usage:**
```4d
var $request : cs.requestClass
var $settings : cs.requestSettings
var $errorInfo : Object

$settings:=cs.requestSettings.new()
$settings.errorID:=404
$settings.DataView:="CustomerReport"

$request:=cs.requestClass.new($settings)
$request.errorMessage()
$errorInfo:=$request.errorRun()

ALERT("Error Details: "+$errorInfo.message)
```

## Complete Example: Customer Management

```4d
// Initialize settings
var $settings : cs.requestSettings
$settings:=cs.requestSettings.new()
$settings.apiKey:="your-api-key-here"
$settings.apiContentType:="application/json"
$settings.apiMethod:="POST"
$settings.apiURL:="https://api.yourcompany.com/customers"
$settings.CompanyID:="COMP001"
$settings.TableName:="Customers"
$settings.dataArrayName:="CustomerData"

// Create new customer
var $addRequest : cs.requestClass
$addRequest:=cs.requestClass.new($settings)
$addRequest.addFieldValueToList("FirstName"; "John")
$addRequest.addFieldValueToList("LastName"; "Doe")
$addRequest.addFieldValueToList("Email"; "john.doe@example.com")
$addRequest.addRecord()

var $addResult : Object
$addResult:=$addRequest.run()

If (Bool($addResult.Success))
    ALERT("Customer created successfully")
    
    // Update the customer
    $settings.UniqueID:=$addResult.data[0].ID  // Assuming ID is returned
    
    var $updateRequest : cs.requestClass
    $updateRequest:=cs.requestClass.new($settings)
    $updateRequest.addFieldValueToList("Phone"; "555-1234")
    $updateRequest.updateRecord()
    
    var $updateResult : Object
    $updateResult:=$updateRequest.run()
    
    If (Bool($updateResult.Success))
        ALERT("Customer updated successfully")
    End if
Else 
    ALERT("Error creating customer: "+$addResult.ErrorMessage)
End if
```

## Notes
- Always check the `Success` property in the result to determine if the operation was successful
- Use `addFieldValueToList()` to build field values before calling record operations
- The class handles HTTP request configuration automatically based on the settings
- Error handling is built-in with detailed error messages and codes