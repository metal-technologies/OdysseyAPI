//%attributes = {}

// ----------------------------------------------------
// User name (OS): DWeyrick
// Date and time: 04/19/25, 14:19:04
// ----------------------------------------------------
// Method: _BuildFindRecordList
// Description
// Build test export collection of scale record export data
//
// Parameters
// ----------------------------------------------------

#DECLARE()->$list : Collection

var $item : Object
$item:=New object:C1471()
$item.Key:=""
$item.Value:=""

//Default empty return list
$list:=New collection:C1472

//Build manual test list
$item:=New object:C1471()
$item.Key:="UniqueID"
$item.Value:="2507730"
$list.push($item)
