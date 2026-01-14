


// ----------------------------------------------------
// User name (OS): dweyr
// Date and time: 10/20/25, 15:02:01
// ----------------------------------------------------
// Class: cs.OdysseyAPI.fetchDataView($settings)
// API Call: /FetchData/DataView
//
// Description
// This method will run the specified data view and return the resulting data.
// All records, regardless of the batch size defined in the data view, will be returned.
//
// Parameters
// $settings = object with settings properties(cs.responseSettings.new)
// ----------------------------------------------------

Class constructor($settings : Object)
	
	$settings.apiURL:="https://api.blinfo.com/metaltech/FetchData/DataView"
	$settings.apiMethod:="Post"
	This:C1470.request:=cs:C1710.request.new($settings)
	This:C1470.request.dataview()
	
	