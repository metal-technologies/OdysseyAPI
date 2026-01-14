<!-- Type your summary here -->
## Get List of Companies
Gets a list of companies available to the given user/password combination. Will return an error if invalid credentials are supplied.

Uses the ***<span style='color:red'>POST</span> /Login/Companies*** api endpoint.

## Parameters
**Username** (String) - The username of the user you're logging in for

**Password** (String) - The password of the user you're logging in for

```4d
{
  "Username": "user@blinfo.com",
  "Password": "password"
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
$settings.Username:="someone@somewhere.com"
$settings.Password:="MyCoolPassword"

$data:=oapi_Companies($settings)
```


## Settings Object Property Explanations
(json object ***properties are case-sensitive*** - they must be spelled exactly as shown)

**cs.requestSettings.new()** - creates the standard settings object used for all api calls.

**apiContentType** - defines the data type returned by the api call (defined in the api documentation).

**apiKey** - the Odyssey user account apikey value with permissions to access the Odyssey database via the api call (MTIOOD (for update) or MTIQuery (for read)).

**Username** - the Odyssey login user account (full email address) used by the api call to return all Odyssey companies that user account can access.

**Password** - the Odyssey login user account password used by the api call to return all Odyssey companies that user account can access.

**UniqueID** - the internal record ID of the data record in the specified database table.
