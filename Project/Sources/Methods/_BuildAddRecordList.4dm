//%attributes = {}

// ----------------------------------------------------
// User name (OS): DWeyrick
// Date and time: 04/19/25, 14:19:04
// ----------------------------------------------------
// Method: _BuildAddRecordList
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
$item.Key:="ContainerID"
$item.Value:="200090904"
$list.push($item)

//Build manual test list
$item:=New object:C1471()
$item.Key:="Product"
$item.Value:="2199-V2"
$list.push($item)

//Build manual test list
$item:=New object:C1471()
$item.Key:="Qty"
$item.Value:="455"
$list.push($item)

//Build manual test list
$item:=New object:C1471()
$item.Key:="CreateDate"
$item.Value:="04/19/2025"
$list.push($item)

//Build manual test list
$item:=New object:C1471()
$item.Key:="clocknumber"
$item.Value:="70352"
$list.push($item)

//Build manual test list
$item:=New object:C1471()
$item.Key:="InventoryType"
$item.Value:="W"
$list.push($item)

//Build manual test list
$item:=New object:C1471()
$item.Key:="Location"
$item.Value:="WH"
$list.push($item)

//Build manual test list
$item:=New object:C1471()
$item.Key:="ContainerWgt"
$item.Value:="2316"
$list.push($item)

//Build manual test list
$item:=New object:C1471()
$item.Key:="TareWgt"
$item.Value:="57"
$list.push($item)

//Build manual test list
$item:=New object:C1471()
$item.Key:="TotalCstgWgt"
$item.Value:="2259"
$list.push($item)

//Build manual test list
$item:=New object:C1471()
$item.Key:="PkgCode"
$item.Value:="68"
$list.push($item)

//Build manual test list
$item:=New object:C1471()
$item.Key:="PcType"
$item.Value:="P"
$list.push($item)

//Build manual test list
$item:=New object:C1471()
$item.Key:="ContStatus"
$item.Value:="AVL"
$list.push($item)

//Build manual test list
$item:=New object:C1471()
$item.Key:="RtgSeq"
$item.Value:="10"
$list.push($item)

//Build manual test list
$item:=New object:C1471()
$item.Key:="x_Datecode"
$item.Value:="25110"
$list.push($item)

//Build manual test list
$item:=New object:C1471()
$item.Key:="x_Workstation"
$item.Value:="mtascale02"
$list.push($item)

//Build manual test list
$item:=New object:C1471()
$item.Key:="x_WeighTime"
$item.Value:="15:50:59"
$list.push($item)

//Build manual test list
$item:=New object:C1471()
$item.Key:="ReportInvLabel"
$item.Value:="internal_fg.rpt"
$list.push($item)

//Build manual test list
$item:=New object:C1471()
$item.Key:="CastDate"
$item.Value:="04/20/25"
$list.push($item)


