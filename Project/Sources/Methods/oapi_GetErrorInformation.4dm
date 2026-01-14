//%attributes = {}

// ----------------------------------------------------
// User name (OS): DWeyrick
// Date and time: 03/31/25, 08:25:29
// ----------------------------------------------------
// Method: oapi_GetErrorInformation
// API Call: /System/ErrorMessage
// Description
// This endpoint checks a user ID and password, to see if it is valid.
//
// Parameters
// $settings = object with settings properties(cs.responseSettings.new)
// ----------------------------------------------------
//DLW  10/27/25  Commented out unnecessary code

#DECLARE($settings : Object) : Object

var $request : cs:C1710.request
$settings.apiURL:="https://api.blinfo.com/metaltech/System/ErrorMessage"
$settings.apiMethod:="GET"
$request:=cs:C1710.request.new($settings)
$request.errorMessage()
$result:=$request.errorRun()  //If you want to handle the request synchronously
//$result:=$request.apiCall.response.body

////Check for error message
//If ($result.Success)
////do nothing - all is good
//Else 
//$result.errorID:=oapi_ExtractErrorIDFromError($result.ErrorMessage)
//End if 

//Clear variables
CLEAR VARIABLE:C89($request)

return $result


