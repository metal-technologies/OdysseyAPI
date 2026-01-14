
// ----------------------------------------------------
// User name (OS): DWeyrick
// Date and time: 10/20/25, 15:02:01
// ----------------------------------------------------
// Class: cs.OdysseyAPI.SystemTime
// API Call: /System/ServerTime?CompanyID=
//
// Description
// This endpoint returns UTC date and time of the server in ISO format.
// This endpoint does not require an APIKey or any validation.
//
// Parameters
// $settings = object with settings properties(cs.responseSettings.new)
// ----------------------------------------------------

Class constructor($settings : Object)
	
	$settings.apiURL:="https://api.blinfo.com/metaltech/System/ServerTime"
	$settings.apiMethod:="POST"
	This:C1470.request:=cs:C1710.request.new($settings)
	This:C1470.request.systemTime()
	
	