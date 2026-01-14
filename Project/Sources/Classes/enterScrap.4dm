
// ----------------------------------------------------
// User name (OS): dweyr
// Date and time: 10/20/25, 15:02:01
// ----------------------------------------------------
// Class: cs.OdysseyAPI.Scrap
// API Call: /Production/Entry/Scrap
//
// Description
// Writes a new 34 scrap production transaction in Odyssey
//
// Parameters
// $settings = object with settings properties(cs.responseSettings.new)
// ----------------------------------------------------

Class constructor($settings : Object)
	
	$settings.apiURL:="https://api.blinfo.com/metaltech/Production/Entry/Scrap"
	$settings.apiMethod:="POST"
	This:C1470.request:=cs:C1710.request.new($settings)
	This:C1470.request.scrap()
	This:C1470.settings:=$settings
	
	