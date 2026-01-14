<!-- Type your summary here -->
## Update A Record
The Update method is used to update a single record in the database with new values.

The return object property, ErrorMessage, will inform you of any error that might have occurred when attempting the deletion.

Uses the ***<span style='color:red'>POST</span> /Record/Update*** api endpoint.


## Parameters
**TableName** (String) - This input parameter identifies the name of the table in the database that contains the record you wish to delete.

**UniqueID** (Integer) - This input parameter specifies the Unique ID of the record that you wish to delete.

**CompanyID** (String) - This is the Company that you are logging into. Your user that you are logging into Odyssey with must have access to this company. You can fetch records from any company, based your query.

**ListOfFieldValues** (Collection of objects) - Type List of String[key] and String[value] pairs : This is an array of key-value-pairs. The key is the field name, and the value is the value you wish to set for that field.


```4d
{
  "TableName": "Employees",
  "UniqueID": 9504,
  "ListOfFieldValues": [
    {
      "Key": "Name",
      "Value": "Allison Smith (Modified)"
    },
    {
      "Key": "Address1",
      "Value": "1234 Main Street"
    }
  ],
  "CompanyID": "ODSY"
}
```

## Response
Success - Type boolean : Returns true if there were no errors generated during the processing of your production records.

ErrorMessage - Type string : The error message that was returned by the system, if any was present.

Attempted - Type integer : The number of production records that were attempted to be processed.

Successful - Type integer : The number of production records that were successfully processed.

Logging - Type Collection of EntryLogging : If errors were generated during the processing of your production records, this collection of errors will contain an entry for each error.

An EntryLogging object contains the following fields:

- ErrorType - Type string : - The type of error generated from your production record
- TextString - Type string : - The content of the error that was generated
- LineNumber - Type string : - The line number associated with this error, if one exists

request - the full HTTP request object used to make the api call.  Can be stored and reused in the future as needed.


## Example of Use
```4d
var $settings : Object
$settings:=cs.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiood
$settings.CompanyID:="tmta"
$settings.TableName:="ContainerInv"
$settings.ListOfFieldValues:=_BuildUpdateRecordList
$settings.UniqueID:=2507730

$data:=oapi_UpdateRecord($settings)
```

## Settings Object Property Explanations
(json object ***properties are case-sensitive*** - they must be spelled exactly as shown)

**cs.requestSettings.new()** - creates the standard settings object used for all api calls.

**apiContentType** - defines the data type returned by the api call (defined in the api documentation).

**apiKey** - the Odyssey user account apikey value with permissions to access the Odyssey database via the api call (MTIOOD (for update) or MTIQuery (for read)).

**CompanyID** - the Odyssey company code for the company database being accessed.

**TableName** - internal name of the Odyssey database table being accessed.

**ListOfFieldValues** - a json collection of data record objects defining field values for each data record to be added to the specified Odyssey database.

**UniqueID** - the internal record ID of the data record in the specified database table.


## Creating DataList Collection (_BuildUpdateRecordList)
```4d
#DECLARE()->$list : Collection

var $item:=New object()
$item.Key:=""
$item.Value:=""

//Default empty return list
$list:=New collection

//Build manual test list
var $item:=New object()
$item.Key:="CastDate"
$item.Value:="04/21/25"
$list.push($item)
```
