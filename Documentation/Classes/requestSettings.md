<!-- Type your summary here -->
# requestSettings Documentation

## Overview
The `requestSettings` class is a configuration object that stores all the necessary settings and parameters for making API requests using the `requestClass`. It acts as a centralized configuration object that defines API endpoints, authentication, and request parameters.

## Properties

### API Configuration
- `apiContentType` (Text) - HTTP Content-Type header (e.g., "application/json")
- `apiKey` (Text) - API authentication key
- `apiMethod` (Text) - HTTP method (GET, POST, PUT, DELETE)
- `apiURL` (Text) - Base API endpoint URL
- `errorURL` (Text) - URL for error information requests

### Company and Authentication
- `CompanyID` (Text) - Company identifier for multi-tenant systems
- `Username` (Text) - User authentication username
- `Password` (Text) - User authentication password

### Data Configuration
- `dataArrayName` (Text) - Name of the array in API response containing data
- `dataObjectName` (Text) - Name of the data object in API response
- `delResultProperty` (Text) - Property to delete from result objects
- `DataView` (Text) - Data view identifier for reporting/queries

### Database Operations
- `TableName` (Text) - Target database table name
- `ListOfFieldValues` (Collection) - Collection of field name-value pairs
- `UniqueID` (Real) - Unique identifier for record operations
- `ParameterList` (Collection) - Collection of parameters for data views

### Import/Export
- `ProfileID` (Text) - Import/export profile identifier
- `SourceFileData` (Text) - Source file data for import operations
- `DateFormat` (Text) - Date format specification
- `DataList` (Collection) - Collection of data for batch operations

### Interface Configuration
- `InterfaceID` (Real) - Interface identifier
- `ImportID` (Real) - Import operation identifier
- `errorID` (Real) - Error identifier for error lookup

## Constructor

```4d
Class constructor()
    This.apiContentType:=""
    This.apiKey:=""
    This.apiMethod:=""
    This.apiURL:=""
    This.CompanyID:=""
    This.dataArrayName:=""
    This.dataObjectName:=""
    This.DataView:=""
    This.delResultProperty:=""
    This.errorURL:=""
    This.TableName:=""
    This.ListOfFieldValues:=New collection()
    This.UniqueID:=0
    This.ProfileID:=""
    This.SourceFileData:=""
    This.DateFormat:=""
    This.DataList:=New collection()
    This.InterfaceID:=0
    This.ImportID:=0
    This.errorID:=Null
    This.Username:=""
    This.Password:=""
    This.ParameterList:=New collection()
```

The constructor initializes all properties with default values.

## Usage Examples

### Basic API Configuration
```4d
var $settings : cs.requestSettings

$settings:=cs.requestSettings.new()
$settings.apiKey:="sk-1234567890abcdef"
$settings.apiContentType:="application/json"
$settings.apiMethod:="POST"
$settings.apiURL:="https://api.example.com/v1"
$settings.CompanyID:="ACME_CORP"
```

### Database Operations Configuration
```4d
var $settings : cs.requestSettings

$settings:=cs.requestSettings.new()
// Basic API setup
$settings.apiKey:="your-api-key"
$settings.apiContentType:="application/json"
$settings.apiURL:="https://api.example.com/records"
$settings.CompanyID:="COMP001"

// Database operation settings
$settings.TableName:="Customers"
$settings.dataArrayName:="CustomerData"
$settings.delResultProperty:="InternalID"
```

### Data View Configuration
```4d
var $settings : cs.requestSettings

$settings:=cs.requestSettings.new()
// Basic API setup
$settings.apiKey:="your-api-key"
$settings.apiContentType:="application/json"
$settings.apiMethod:="POST"
$settings.apiURL:="https://api.example.com/dataview"
$settings.CompanyID:="COMP001"

// Data view settings
$settings.DataView:="SalesReport"
$settings.dataArrayName:="ReportData"
$settings.dataObjectName:="DataSetOut"
```

### Authentication Configuration
```4d
var $settings : cs.requestSettings

$settings:=cs.requestSettings.new()
// API setup
$settings.apiKey:="your-api-key"
$settings.apiContentType:="application/json"
$settings.apiMethod:="POST"
$settings.apiURL:="https://api.example.com/auth"

// Authentication settings
$settings.CompanyID:="COMP001"
$settings.Username:="user@example.com"
$settings.Password:="securePassword123"
```

### Import Operation Configuration
```4d
var $settings : cs.requestSettings
var $csvData : Text

$settings:=cs.requestSettings.new()
// API setup
$settings.apiKey:="your-api-key"
$settings.apiContentType:="application/json"
$settings.apiMethod:="POST"
$settings.apiURL:="https://api.example.com/import"
$settings.CompanyID:="COMP001"

// Import settings
$settings.ProfileID:="CUSTOMER_IMPORT_PROFILE"
$csvData:="Name,Email,Phone\nJohn Doe,john@example.com,555-1234"
$settings.SourceFileData:=$csvData
$settings.DateFormat:="MM/DD/YYYY"
```

### Error Handling Configuration
```4d
var $settings : cs.requestSettings

$settings:=cs.requestSettings.new()
// API setup
$settings.apiKey:="your-api-key"
$settings.apiContentType:="application/json"
$settings.apiMethod:="GET"
$settings.apiURL:="https://api.example.com/errors"
$settings.CompanyID:="COMP001"

// Error lookup settings
$settings.errorID:=404
$settings.errorURL:="https://api.example.com/errors"
```

### Complete Configuration Example
```4d
// Create a comprehensive settings object for customer management
var $settings : cs.requestSettings

$settings:=cs.requestSettings.new()

// API Configuration
$settings.apiKey:="sk-prod-1234567890abcdef"
$settings.apiContentType:="application/json"
$settings.apiMethod:="POST"
$settings.apiURL:="https://api.mycompany.com/v2"
$settings.errorURL:="https://api.mycompany.com/v2/errors"

// Company and Authentication
$settings.CompanyID:="ACME_CORP_001"
$settings.Username:="api.user@acme.com"
$settings.Password:="SecureAPIPassword2024!"

// Data Configuration
$settings.TableName:="Customers"
$settings.dataArrayName:="CustomerRecords"
$settings.dataObjectName:="DataSetOut"
$settings.delResultProperty:="sys_id"

// Data View Configuration
$settings.DataView:="ActiveCustomersReport"

// Date Format
$settings.DateFormat:="YYYY-MM-DD"

// Now use this settings object with requestClass
var $request : cs.requestClass
$request:=cs.requestClass.new($settings)
```

### Using Settings with Different Operations
```4d
// Base settings
var $baseSettings : cs.requestSettings
$baseSettings:=cs.requestSettings.new()
$baseSettings.apiKey:="your-api-key"
$baseSettings.apiContentType:="application/json"
$baseSettings.CompanyID:="COMP001"

// For record operations
$baseSettings.apiURL:="https://api.example.com/records"
$baseSettings.apiMethod:="POST"
$baseSettings.TableName:="Products"
$baseSettings.dataArrayName:="ProductData"

// For data views
var $reportSettings : cs.requestSettings
$reportSettings:=$baseSettings  // Copy base settings
$reportSettings.apiURL:="https://api.example.com/dataviews"
$reportSettings.DataView:="ProductSalesReport"
$reportSettings.dataArrayName:="SalesData"

// For authentication
var $authSettings : cs.requestSettings
$authSettings:=$baseSettings  // Copy base settings
$authSettings.apiURL:="https://api.example.com/auth/login"
$authSettings.Username:="user@example.com"
$authSettings.Password:="password123"
```

## Best Practices

1. **Reuse Settings Objects**: Create a base configuration and clone it for different operations to avoid repetitive setup.

2. **Secure API Keys**: Store API keys securely and never hard-code them in production code.

3. **Environment-Specific URLs**: Use different API URLs for development, staging, and production environments.

4. **Validate Configuration**: Always verify that required properties are set before using the settings object.

```4d
// Validation example
Function validateSettings($settings : cs.requestSettings) : Boolean
    If ($settings.apiKey="") || ($settings.apiURL="") || ($settings.CompanyID="")
        return False
    End if
    return True
```

5. **Configuration Management**: Consider creating factory functions for common configurations:

```4d
// Factory function for customer operations
Function createCustomerSettings() : cs.requestSettings
    var $settings : cs.requestSettings
    $settings:=cs.requestSettings.new()
    
    $settings.apiKey:=Get_API_Key()  // Your secure method
    $settings.apiContentType:="application/json"
    $settings.apiURL:="https://api.example.com/customers"
    $settings.CompanyID:=Get_Company_ID()  // Your method
    $settings.TableName:="Customers"
    $settings.dataArrayName:="CustomerData"
    
    return $settings
```

This settings class provides a clean, organized way to manage all the configuration needed for API operations, making your code more maintainable and reducing the chance of configuration errors.