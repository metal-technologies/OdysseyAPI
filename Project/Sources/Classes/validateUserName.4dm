
// ----------------------------------------------------
// User name (OS): DWeyrick
// Date and time: 10/20/25, 15:02:01
// ----------------------------------------------------
// Method: cs.OdysseyAPI.ValidateUsername
// API Call: /System/ValidateUsername
//
// Description
// This endpoint checks a user ID and password, to see if it is valid.
//
// Parameters
// $settings = object with settings properties(cs.responseSettings.new)
// ----------------------------------------------------

Class constructor($settings : Object)
	
	$settings.apiURL:="https://api.blinfo.com/metaltech/System/ValidateUsername"
	$settings.apiMethod:="POST"
	This:C1470.request:=cs:C1710.request.new($settings)
	This:C1470.request.validateUsername()
	
	