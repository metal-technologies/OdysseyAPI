//%attributes = {}

// ----------------------------------------------------
// User name (OS): DWeyrick
// Date and time: 03/31/25, 08:25:29
// ----------------------------------------------------
// Method: oapi_SystemTime
// API Call: /System/ServerTime?CompanyID=
// Description
// This endpoint returns UTC date and time of the server in ISO format.
// This endpoint does not require an APIKey or any validation.
//
// Parameters
// $settings = object with settings properties(cs.responseSettings.new)
// ----------------------------------------------------

#DECLARE($settings : Object)->$result : Object

var $request : cs:C1710.request

$settings.apiURL:="https://api.blinfo.com/metaltech/System/ServerTime"
$settings.apiMethod:="GET"
$request:=cs:C1710.request.new($settings)
$request.systemTime()
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




