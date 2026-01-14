<!-- Type your summary here -->
## Enter Secondary Production
Allows you to submit a *non-jobbing production entry for a 43*, Secondary operation. In order to use this method, you must be authorized for both the Odyssey API module and the Production Interface module.

Uses the ***<span style='color:red'>POST</span> /Entry/Secondary*** api endpoint.


## Parameters
**DateFormat** (String) - The DateFormat that should be used when providing date values to Odyssey.

Valid options are:

- MDY : This format means dates will be sent in Month/Day/Year format
- DMY : This format means dates will be sent in Day/Month/Year format
- YMD : This format means dates will be sent in Year/Month/Day format

**DataList** (Collection of objects) - A list of all the production transaction records to submit to Odyssey. ***Any ProductionTran field, or User Defined Field in ProductionTran*** can be supplied in this list. Data supplied in this list is validated through standard production entry logic. Please see the Production Entry Scope document for detailed information on required fields.

**CompanyID** (String) - This is the Company that you are logging into. Your user that you are logging into Odyssey with must have access to this company. You can fetch records from any company, based your query.


```4d
{
  "CompanyID": "ODSY",
  "DateFormat": "MDY",
  "DataList": [
    {
    	"OrderNumber" : "21854",
    	"OrderItem": "1",
    	"OrderType": "S",
    	"Operation" : "GRIND",
    	"Product" : "R4512",
    	"ShiftDate" : "02/08/2020",
    	"Qty": "2",
    	"Hours": "3",
    	"ShiftName": "1",
    	"Remarks": "Test from Production/Entry/Secondary from the Odyssey API"
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


## Example of Use
```4d
$list:=_BuildSecondaryDataList
$settings:=cs.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiood
$settings.CompanyID:="tmta"
$settings.DateFormat:="MDY"
$settings.DataList:=$list

$data:=oapi_EnterSecondaryProduction($settings)
```


## Settings Object Property Explanations
(json object ***properties are case-sensitive*** - they must be spelled exactly as shown)

**cs.requestSettings.new()** - creates the standard settings object used for all api calls.

**apiContentType** - defines the data type returned by the api call (defined in the api documentation).

**apiKey** - the Odyssey user account apikey value with permissions to access the Odyssey database via the api call (MTIOOD (for update) or MTIQuery (for read)).

**CompanyID** - the Odyssey company code for the company database being accessed.

**DateFormat** - the date format used in the specified Odyssey company being accessed.

**DataList** - a json collection of data record objects defining field values for each data record to be added to the specified Odyssey database.


## Creating DataList Collection
```4d
#DECLARE()->$list : Collection

var $item:=New object()
$item.Key:=""
$item.Value:=""

//Default empty return list
$list:=New collection

//Build manual test list
$item:=New object()
$item.ContainerID:="200090906"
$item.Product:="217033"
$item.Qty:="455"
$item.Date:="04/19/2025"
$item.Clocknumber:="70352"
$item.InvAffected:="W"
$item.InvLocation:="WH"
$item.Totalwgt:="2316"
$item.TareWgt:="57"
$item.Pkgcode:="68"
$item.RtgSeq:="30"
$item.x_Datecode:="25110"
$item.x_Workstation:="mtascale02"
$item.x_WeighTime:="15:50:59"
$item.ReportInvLabel:="internal_fg.rpt"
$item.CastDate:="04/20/25"
$item.Operation:="Scale"
$item.TransCode:="43"
$item.hours:="0"
$item.gencontainerid:="A"
$item.inspectstatus:="P"
$item.sampletype:="PN"
$item.samplewgtea:="5.01"
$item.sampleqty:="1"
$item.sampleweight:="5.01"
$item.numofboxes:="1"
$item.groupcode:="DI"
$item.shift:="1"
$item.autopost:="yes"
$item.userptseries:="O"
$list.push($item)

$item:=New object()
$item.ContainerID:="200090907"
$item.Product:="217033"
$item.Qty:="455"
$item.Date:="04/19/2025"
$item.Clocknumber:="70352"
$item.InvAffected:="W"
$item.InvLocation:="WH"
$item.Totalwgt:="2316"
$item.TareWgt:="57"
$item.Pkgcode:="68"
$item.RtgSeq:="30"
$item.x_Datecode:="25110"
$item.x_Workstation:="mtascale02"
$item.x_WeighTime:="15:50:59"
$item.ReportInvLabel:="internal_fg.rpt"
$item.CastDate:="04/20/25"
$item.Operation:="Scale"
$item.TransCode:="43"
$item.hours:="0"
$item.gencontainerid:="A"
$item.inspectstatus:="P"
$item.sampletype:="PN"
$item.samplewgtea:="5.01"
$item.sampleqty:="1"
$item.sampleweight:="5.01"
$item.numofboxes:="1"
$item.groupcode:="DI"
$item.shift:="1"
$item.autopost:="yes"
$item.userptseries:="O"
$list.push($item)
```