
// ----------------------------------------------------
// User name (OS): DWeyrick
// Date and time: 10/20/25, 15:02:01
// ----------------------------------------------------
// Class: cs.OdysseyAPI.companies($settings)
// API Call: /System/Login/Companies
//
// Description
// Gets a list of companies available to the given user/password combination.
//
// Parameters
// $settings = object with settings properties(cs.responseSettings.new)
// ----------------------------------------------------

Class constructor($settings : Object)
	
	$settings.apiURL:="https://api.blinfo.com/metaltech/Login/Companies"
	$settings.apiMethod:="POST"
	This:C1470.request:=cs:C1710.request.new($settings)
	This:C1470.request.companies()
	This:C1470.settings:=$settings
	
	