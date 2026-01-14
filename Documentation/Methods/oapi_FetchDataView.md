<!-- Type your summary here -->
## Fetch DataView Data
This method will run the specified data view and return the resulting data. All records, regardless of the batch size defined in the data view, will be returned.

Uses the ***<span style='color:red'>POST</span> /FetchData/DataView*** api endpoint.

## Parameters
**DataView** (String) - This identifies the name of the Data View to run. It must exist in the same company that you logged into.

**ParameterList** (Collection) - Type List of DataViewParameter :
A list of DataViewParameter's that define the parameters you're passing to the data view. Each Parameter name must be fully qualified using periods to separate the database, table, and field names (e.g. maindb.orderitem.customer). If your parameter is defined as a filter with multiple values, those different values can be specified by separating them with a tilde (~) (e.g. "FieldName": "maindb.orderitem.groupcode", "Operator": "Between", “ParameterValue": "GRP1~GRP2”).

```4d
{
  "CompanyID": "ODSY",
  "DataView": "OODAPITest",
  "ParameterList": [
    {
      "FieldName": "maindb.products.product",
      "Operator": ">=",
      "ParameterValue" : "b"
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
$settings:=cs.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiquery
$settings.CompanyID:="tmta"
$settings.dataArrayName:="maindb_products"
$settings.dataObjectName:="DataSetOut"
$settings.delResultProperty:="@z_internal@"
$settings.DataView:="Active Parts List"

$data:=oapi_FetchDataView($settings)
```


## Settings Object Property Explanations
(json object ***properties are case-sensitive*** - they must be spelled exactly as shown)

**cs.requestSettings.new()** - creates the standard settings object used for all api calls.

**apiContentType** - defines the data type returned by the api call (defined in the api documentation).

**apiKey** - the Odyssey user account apikey value with permissions to access the Odyssey database via the api call (MTIOOD (for update) or MTIQuery (for read)).

**CompanyID** - the Odyssey company code for the company database being accessed.

**dataArrayName** - the object name of the json collection returned from the api that contains the data records (one object per record).

**dataObjectName** - the object name of the json object returned from the api that contains the json collection of data records (.dataArrayName).

**delResultProperty** - the name of object properties to be removed from the initial data returned by the api call.  This eliminates unnecessary properties from each data object returned.

**DataView** - the name of the Odyssey data view to run to return data records from the api call.