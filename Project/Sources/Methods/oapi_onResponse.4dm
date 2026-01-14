//%attributes = {}

// ----------------------------------------------------
// User name (OS): dweyrick-spa
// Date and time: 10/20/25, 17:13:05
// ----------------------------------------------------
// Method: oapi_onResponse
//
// Method Description
// 
//
// Modification Comments
// Comment Style: Dev Initials  Date of Modification  Comments on the change
// ----------------------------------------------------

#DECLARE($request : 4D:C1709.HTTPRequest; $event : Object) : Object

//My onResponse method, if you want to handle the request asynchronously
var $array; $props : Collection
var $result : Object
var $prop; $propName : Text
$result:=New object:C1471()

//TRACE

//Get property name from Storage defined by request caller
$propName:=This:C1470.delPropertyName

//Returned array of data objects
If ($request.response.body.DataSetOut#Null:C1517)
	//Get list or object property names
	$props:=OB Keys:C1719($request.response.body.DataSetOut)
	$prop:=$props[0]
	
	$array:=$request.response.body.DataSetOut[$prop]
	$result.dataArray:=oapi_delArrayProperties($array; $propName)
	
Else 
	$result.dataArray:=New collection:C1472
	
End if 

$result.errorMessage:=$request.response.body.ErrorMessage
$result.statusText:=$request.response.statusText
$result.statusCode:=$request.response.status
$result.success:=$request.response.body.Success
$result.terminated:=$request.terminated

CLEAR VARIABLE:C89($propName)

return $result



