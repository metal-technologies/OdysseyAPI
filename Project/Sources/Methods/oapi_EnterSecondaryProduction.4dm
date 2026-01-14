//%attributes = {}

// ----------------------------------------------------
// User name (OS): dweyr
// Date and time: 04/19/25, 19:06:01
// ----------------------------------------------------
// Method: oapi_Secondary
// API Call: /Production/Entry/Secondary
// Description
// Writes a new record to the specified table in Odyssey
//
// Parameters
// $settings = object with settings properties(cs.responseSettings.new)
// ----------------------------------------------------

#DECLARE($settings : Object)->$result : Object

var $request : cs:C1710.request

$settings.apiURL:="https://api.blinfo.com/metaltech/Production/Entry/Secondary"
$settings.apiMethod:="POST"
$request:=cs:C1710.request.new($settings)
$request.secondary()
$request.apiCall.wait()  //If you want to handle the request synchronously
$result:=$request.apiCall.response.body
$result.request:=$request

//Check for error message
If ($result.Success)
	//do nothing - all is good
Else 
	$settings.errorID:=oapi_ExtractErrorIDFromError($result.ErrorMessage)
	$result.errorInfo:=oapi_GetErrorInformation($settings)
	$result.errorInfo.errorID:=$settings.errorID
End if 

//Clear variables
CLEAR VARIABLE:C89($request)

