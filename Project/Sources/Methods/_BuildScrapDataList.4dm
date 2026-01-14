//%attributes = {}

// ----------------------------------------------------
// User name (OS): DWeyrick
// Date and time: 04/19/25, 14:19:04
// ----------------------------------------------------
// Method: _BuildScrapDataList
// Description
// Build data list content for Secondary api call
//
// Parameters
// ----------------------------------------------------

#DECLARE()->$list : Collection

var $item : Object
$item.Key:=""
$item.Value:=""

//Default empty return list
$list:=New collection:C1472

//Build manual test list
$item:=New object:C1471()
$item.Operation:="fnlaud"
$item.TransCode:="34"
$item.Product:="217033"
$item.Qty:="15"
$item.Date:="04/22/2025"
$item.Clocknumber:="70352"
$item.reasoncode:="10"
$item.InvAffected:="W"
$item.shift:="1"
$item.x_Datecode:="25110"
$item.tool:="217033/1-6"
$item.config:="1"
$item.groupcode:="DI"
$item.CastDate:="04/20/25"
$item.autopost:="yes"
$list.push($item)

$item:=New object:C1471()
$item.Operation:="fnlaud"
$item.TransCode:="34"
$item.Product:="217033"
$item.Qty:="20"
$item.Date:="04/22/2025"
$item.Clocknumber:="70352"
$item.reasoncode:="10"
$item.InvAffected:="W"
$item.shift:="1"
$item.x_Datecode:="25110"
$item.tool:="217033/1-6"
$item.config:="1"
$item.groupcode:="DI"
$item.CastDate:="04/20/25"
$item.autopost:="yes"
$list.push($item)

