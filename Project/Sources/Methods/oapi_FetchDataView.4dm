//%attributes = {}

// ----------------------------------------------------
// User name (OS): dweyr
// Date and time: 03/27/25, 19:06:01
// ----------------------------------------------------
// Method: oapi_FetchDataView
// API Call: /FetchData/DataView
// Description
// This method will run the specified data view and return the resulting data.
// All records, regardless of the batch size defined in the data view, will be returned.
//
// Parameters
// $settings = object with settings properties(cs.responseSettings.new)
// ----------------------------------------------------

#DECLARE($settings : Object)->$result : Object

var $request : cs:C1710.request

$settings.apiURL:="https://api.blinfo.com/metaltech/FetchData/DataView"
$settings.apiMethod:="Post"
$request:=cs:C1710.request.new($settings)
$request.dataview()
$request.run()

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

