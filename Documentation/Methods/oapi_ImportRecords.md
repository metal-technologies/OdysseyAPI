<!-- Type your summary here -->
## Import Records
This method is used to import records into the database.

Uses the ***<span style='color:red'>POST</span> /Record/Import*** api endpoint.


## Parameters
**ProfileID** (String) - The Import Profile ID that you are running.

**SourceFileData** (String) - The content of the file you are importing from (a CSV data file converted to a string).

**CompanyID** (String) - This is the Company that you are logging into. Your user that you are logging into Odyssey with must have access to this company. You can fetch records from any company, based your query.


```4d
{
  "ProfileID": "OOD-ImportTest",
  "SourceFileData": "ClockNumber,Name,Shift,Foreman,Department,Badge\r\n10551,Allison Smith-T1,1,DOUG,1,10551\r\n10552,Allison Smith-T2,1,DOUG,1,10552\r\n10553,Allison Smith-T3,1,DOUG,1,10553\r\n10554,Allison Smith-T4,1,DOUG,1,10554\r\n10555,Allison Smith-T5,1,DOUG,1,10555",
  "CompanyID":"ODSY"
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
$settings.apiKey:=$mtiood
$settings.CompanyID:="tmta"
$settings.ProfileID:="Create WIP Container"
$settings.SourceFileData:=_BuildImportRecordData

$data:=oapi_ImportRecords($settings)
```


## Settings Object Property Explanations
(json object ***properties are case-sensitive*** - they must be spelled exactly as shown)

**cs.requestSettings.new()** - creates the standard settings object used for all api calls.

**apiContentType** - defines the data type returned by the api call (defined in the api documentation).

**apiKey** - the Odyssey user account apikey value with permissions to access the Odyssey database via the api call (MTIOOD (for update) or MTIQuery (for read)).

**CompanyID** - the Odyssey company code for the company database being accessed.

**ProfileID** - internal name of the Odyssey import profile used to add the data into the Odyssey database.

**SourceFileData** - a string containing the full content of a CSV data file containing all records to be added to the Odyssey database.


## Creating SourceFileData String
```4d
#DECLARE()->$data : Text

var $file:=File("C:\\4DDev\\OdysseyRecordImport.txt"; fk platform path)
$data:=$file.getText()

CLEAR VARIABLE($file)
```