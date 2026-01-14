
// ----------------------------------------------------
// User name (OS): DWeyrick
// Date and time: 10/20/25, 15:02:01
// ----------------------------------------------------
// Class: cs.OdysseyAPI.Login
// API Call: /System/Login
//
// Description
// This endpoint attempts to log the given user into the specified Company.
//
// Parameters
// $settings = object with settings properties(cs.responseSettings.new)
// ----------------------------------------------------

Class constructor($settings : Object)
	
	$settings.apiURL:="https://api.blinfo.com/metaltech/Login"
	$settings.apiMethod:="POST"
	This:C1470.request:=cs:C1710.request.new($settings)
	This:C1470.request.login()
	This:C1470.settings:=$settings
	
	