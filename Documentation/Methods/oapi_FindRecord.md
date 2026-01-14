<!-- Type your summary here -->
## Find a Record
This method will allow you to find a single record in the database using one or more fields and their values.

Uses the ***<span style='color:red'>POST</span> /Record/Find*** api endpoint.


## Parameters
**CompanyID** (String) - This is the Company that you are logging into. Your user that you are logging into Odyssey with must have access to this company. You can fetch records from any company, based your query.

**TableName** (String) - This identifies the name of the Data View to run. It must exist in the same company that you logged into.

**ListOfFieldValues** (Collection) - Type List of String[key] and String[value] pairs : This is an array of key-value-pairs. The key is the field name, and the value is the value you wish to set for that field.


```4d
{
  "CompanyID": "ODSY",
  "TableName": "Employees",
  "ListOfFieldValues": [
    {
      "Key": "ClockNumber",
      "Value": "10500"
    }
  ]
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
$list:=_BuildFindRecordList
$settings:=cs.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiood
$settings.CompanyID:="tmta"
$settings.TableName:="ContainerInv"
$settings.ListOfFieldValues:=$list

$data:=oapi_FindRecord($settings)

```


## Settings Object Property Explanations
(json object ***properties are case-sensitive*** - they must be spelled exactly as shown)

**cs.requestSettings.new()** - creates the standard settings object used for all api calls.

**apiContentType** - defines the data type returned by the api call (defined in the api documentation).

**apiKey** - the Odyssey user account apikey value with permissions to access the Odyssey database via the api call (MTIOOD (for update) or MTIQuery (for read)).

**CompanyID** - the Odyssey company code for the company database being accessed.

**TableName** - internal name of the Odyssey database table being accessed.

**ListOfFieldValues** - a json collection of objects which define the internal unique record ID of each records to be found by the api call (one object per UniqueID).


## Creating ListOfFieldValues collection
```4d
#DECLARE()->$list : Collection

var $item:=New object()
$item.Key:=""
$item.Value:=""

//Default empty return list
$list:=New collection

//Build manual test list
var $item:=New object()
$item.Key:="UniqueID"
$item.Value:="2507730"
$list.push($item)
```