<!-- Type your summary here -->
## Get Error Information
Gets detailed information about the given Error Message.

Uses the ***<span style='color:darkgreen'>GET</span> /System/ErrorMessage*** api endpoint.


## Parameters
**ErrorID** (String) - The ID of the error message you wish to get information about.

**CompanyID** (String) - This optional parameter defines the CompanyID to use for APIKey validation, if using a global APIKey. If your APIKey was generated for a specific company, you do not have to supply this parameter.

```4d
curl --location 'https://api.blinfo.com/company/System/ErrorMessage/0020?CompanyID=ODSY' \
--header 'X-API-Key: <Your-APIKey-FromOdyssey>' \
--header 'Content-Type: application/json' \
--data ''
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
//Check for error message
If ($result.Success)
	//do nothing - all is good
Else 
	$settings.errorID:=oapi_ExtractErrorIDFromError($result.ErrorMessage)
	$result.errorInfo:=oapi_GetErrorInformation($settings)
	$result.errorInfo.errorID:=$settings.errorID
End if 
```