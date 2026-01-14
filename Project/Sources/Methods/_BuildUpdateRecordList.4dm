//%attributes = {}

// ----------------------------------------------------
// User name (OS): DWeyrick
// Date and time: 04/19/25, 14:19:04
// ----------------------------------------------------
// Method: _BuildUpdateRecordList
// Description
// Build test export collection of scale record export data
//
// Parameters
// ----------------------------------------------------
//DLW  07/31/25  Fixed syntax error in var

#DECLARE()->$list : Collection

var $item : Object
$item:=New object:C1471
$item.Key:=""
$item.Value:=""

//Default empty return list
$list:=New collection:C1472

//Build manual test list
$item:=New object:C1471()
$item.Key:="CastDate"
$item.Value:="04/21/25"
$list.push($item)
