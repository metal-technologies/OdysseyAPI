//%attributes = {}

// ----------------------------------------------------
// User name (OS): DWeyrick
// Date and time: 03/31/25, 08:25:29
// ----------------------------------------------------
// Method: oapi_ValidateUsername
// API Call: /System/ValidateUsername
// Description
// This endpoint checks a user ID and password, to see if it is valid.
//
// Parameters
// $settings = object with settings properties(cs.responseSettings.new)
// ----------------------------------------------------

#DECLARE($settings : Object)->$result : Object

var $request : cs:C1710.request

$settings.apiURL:="https://api.blinfo.com/metaltech/System/ValidateUsername"
$settings.apiMethod:="POST"
$request:=cs:C1710.request.new($settings)
$request.validateUsername()
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




