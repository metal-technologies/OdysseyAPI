
// ----------------------------------------------------
// User name (OS): dweyr
// Date and time: 10/20/25, 15:02:01
// ----------------------------------------------------
// Method: cs.OdysseyAPI.UpdateRecord
// API Call: /Record/Update
//
// Description
// Update a single record in the specified table in Odyssey
//
// Parameters
// $settings = object with settings properties(cs.responseSettings.new)
// ----------------------------------------------------

Class constructor($settings : Object)
	
	$settings.apiURL:="https://api.blinfo.com/metaltech/Record/Update"
	$settings.apiMethod:="POST"
	This:C1470.request:=cs:C1710.request.new($settings)
	This:C1470.request.updateRecord()
	
	