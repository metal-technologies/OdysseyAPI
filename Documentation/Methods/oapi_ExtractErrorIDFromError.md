<!-- Type your summary here -->
## Extract Error ID From Error Message
Parses the error ID from the initial error message returned from an Odyssey API call.  The error ID is parsed from within the parenthesis in the initial error message.

*Note:  this is an internal method only.*

## Parameters
**ErrorMessage** (String) - The full error message string returned from an api call.

```4d
#DECLARE($error : Text)->$id : Text

var $start:=Position("("; $error)+1
var $end:=Position(")"; $error)
var $chars:=$end-$start

$id:=Substring($error; $start; $chars)
```


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


## Example Code Object Property Explanations
(json object ***properties are case-sensitive*** - they must be spelled exactly as shown)

**$result.Success** (Boolean) - A value returned from the api call indicating if the api call function was successful.

**$settings.errorID** (Integer) - the error ID value parsed from the initial error message from the api call.

**$result.errorInfo** (Object) - the extended error information returned from the GetErrorInformation api call.

**$result.errorInfo.errorID** (Integer) - the original error id added to the errorInfo object for easy reference.
