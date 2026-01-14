//%attributes = {}

// ----------------------------------------------------
// User name (OS): dweyrick-spa
// Date and time: 10/21/25, 08:58:30
// ----------------------------------------------------
// Method: oapi_delArrayProperties
//
// Method Description
// Delete specified object properties from the API returned data
//
// Modification Comments
// Comment Style: Dev Initials  Date of Modification  Comments on the change
// ----------------------------------------------------
#DECLARE($array : Collection; $propName : Text) : Collection

//Remove unnecessary array objects
var $item : Object
var $property : Text
var $propObj : Object
var $col; $propcol : Collection

//Create return collection object
$col:=New collection:C1472

For each ($item; $array)
	//
	$propcol:=New collection:C1472()
	OB GET PROPERTY NAMES:C1232($item; $properties)
	ARRAY TO COLLECTION:C1563($propcol; $properties)
	//
	For each ($property; $propcol)
		//
		If ($property=$propName)
			OB REMOVE:C1226($item; $property)
		End if 
		//
	End for each 
	//
	$col.push($item)
	//
End for each 

return $col


