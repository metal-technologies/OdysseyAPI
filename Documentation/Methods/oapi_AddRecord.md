<!-- Type your summary here -->
## Add a Record
This method is used to add a single record into the database. This method returns an AddRecordResponse, which contains the UniqueID of the added record. This UniqueID can then be used elsewhere for updating or deleting.

Uses the ***<span style='color:red'>POST</span> /Record/Add*** api endpoint.

## Parameters
**TableName** (String) - This input parameter identifies the name of the table in the database where you will add a new record.

**ListOfFieldValues** (List of objects) - 
Type List of String[key] and String[value] pairs : This is an array of key-value-pairs. The key is the field name, and the value is the value you wish to set for that field.

```4d
{
  "CompanyID": "ODSY",
  "TableName": "Employees",
  "ListOfFieldValues": [
    {
      "Key": "ClockNumber",
      "Value": ""
    },
    {
      "Key": "Name",
      "Value": "Allison Smith"
    },
    {
      "Key": "Shift",
      "Value": "1"
    },
    {
      "Key": "Foreman",
      "Value": "DOUG"
    },
    {
      "Key": "Department",
      "Value": "1"
    },
    {
    "Key":"Badge",
    "Value":"456456"
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
$list:=_BuildAddRecordList
$settings:=cs.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiood
$settings.CompanyID:="tmta"
$settings.TableName:="ContainerInv"
$settings.ListOfFieldValues:=$list

$data:=oapi_AddRecord($settings)
```


## Settings Object Property Explanations
(json object ***properties are case-sensitive*** - they must be spelled exactly as shown)

**cs.requestSettings.new()** - creates the standard settings object used for all api calls.

**apiContentType** - defines the data type returned by the api call (defined in the api documentation).

**apiKey** - the Odyssey user account apikey value with permissions to access the Odyssey database via the api call (MTIOOD (for update) or MTIQuery (for read)).

**CompanyID** - the Odyssey company code for the company database being accessed.

**TableName** - internal name of the Odyssey database table being accessed.

**ListOfFieldValues** - a json collection of data record objects defining field values for each data record to be added to the specified Odyssey database.


## Creating ListOfFieldValues collection
```4d
var $item:=New object()
$item.Key:=""
$item.Value:=""

//Default empty return list
$list:=New collection

//Build manual test list
$item:=New object()
$item.Key:="ContainerID"
$item.Value:="200090904"
$list.push($item)

//Build manual test list
$item:=New object()
$item.Key:="Product"
$item.Value:="2199-V2"
$list.push($item)

//Build manual test list
$item:=New object()
$item.Key:="Qty"
$item.Value:="455"
$list.push($item)

//Build manual test list
$item:=New object()
$item.Key:="CreateDate"
$item.Value:="04/19/2025"
$list.push($item)

//Build manual test list
$item:=New object()
$item.Key:="clocknumber"
$item.Value:="70352"
$list.push($item)

//Build manual test list
$item:=New object()
$item.Key:="InventoryType"
$item.Value:="W"
$list.push($item)

//Build manual test list
$item:=New object()
$item.Key:="Location"
$item.Value:="WH"
$list.push($item)

//Build manual test list
$item:=New object()
$item.Key:="ContainerWgt"
$item.Value:="2316"
$list.push($item)

//Build manual test list
$item:=New object()
$item.Key:="TareWgt"
$item.Value:="57"
$list.push($item)

//Build manual test list
$item:=New object()
$item.Key:="TotalCstgWgt"
$item.Value:="2259"
$list.push($item)

//Build manual test list
$item:=New object()
$item.Key:="PkgCode"
$item.Value:="68"
$list.push($item)

//Build manual test list
$item:=New object()
$item.Key:="PcType"
$item.Value:="P"
$list.push($item)

//Build manual test list
$item:=New object()
$item.Key:="ContStatus"
$item.Value:="AVL"
$list.push($item)

//Build manual test list
$item:=New object()
$item.Key:="RtgSeq"
$item.Value:="10"
$list.push($item)

//Build manual test list
$item:=New object()
$item.Key:="x_Datecode"
$item.Value:="25110"
$list.push($item)

//Build manual test list
$item:=New object()
$item.Key:="x_Workstation"
$item.Value:="mtascale02"
$list.push($item)

//Build manual test list
$item:=New object()
$item.Key:="x_WeighTime"
$item.Value:="15:50:59"
$list.push($item)

//Build manual test list
$item:=New object()
$item.Key:="ReportInvLabel"
$item.Value:="internal_fg.rpt"
$list.push($item)

//Build manual test list
$item:=New object()
$item.Key:="CastDate"
$item.Value:="04/20/25"
$list.push($item)
```
