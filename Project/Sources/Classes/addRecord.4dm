
// ----------------------------------------------------
// User name (OS): dweyr
// Date and time: 10/20/25, 15:02:01
// ----------------------------------------------------
// Class: cs.OdysseyAPI.addRecord($settings)
//
// API Call: /Record/Add
// Description
// Writes a new record to the specified table in Odyssey
//
// Parameters
// $settings = object with settings properties(cs.responseSettings.new)
// ----------------------------------------------------

Class constructor($settings : Object)
	
	$settings.apiURL:="https://api.blinfo.com/metaltech/Record/Add"
	$settings.apiMethod:="POST"
	This:C1470.request:=cs:C1710.request.new($settings)
	This:C1470.request.addRecord()
	This:C1470.settings:=$settings
	
	