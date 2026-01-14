//%attributes = {}

// ----------------------------------------------------
// User name (OS): DWeyrick
// Date and time: 04/19/25, 14:19:04
// ----------------------------------------------------
// Method: _BuildSecondaryDataList
// Description
// Build data list content for Secondary api call
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
$item.ContainerID:="200090906"
$item.Product:="217033"
$item.Qty:="455"
$item.Date:="04/19/2025"
$item.Clocknumber:="70352"
$item.InvAffected:="W"
$item.InvLocation:="WH"
$item.Totalwgt:="2316"
$item.TareWgt:="57"
$item.Pkgcode:="68"
$item.RtgSeq:="30"
$item.x_Datecode:="25110"
$item.x_Workstation:="mtascale02"
$item.x_WeighTime:="15:50:59"
$item.ReportInvLabel:="internal_fg.rpt"
$item.CastDate:="04/20/25"
$item.Operation:="Scale"
$item.TransCode:="43"
$item.hours:="0"
$item.gencontainerid:="A"
$item.inspectstatus:="P"
$item.sampletype:="PN"
$item.samplewgtea:="5.01"
$item.sampleqty:="1"
$item.sampleweight:="5.01"
$item.numofboxes:="1"
$item.groupcode:="DI"
$item.shift:="1"
$item.autopost:="yes"
$item.userptseries:="O"
$list.push($item)

$item:=New object:C1471()
$item.ContainerID:="200090907"
$item.Product:="217033"
$item.Qty:="455"
$item.Date:="04/19/2025"
$item.Clocknumber:="70352"
$item.InvAffected:="W"
$item.InvLocation:="WH"
$item.Totalwgt:="2316"
$item.TareWgt:="57"
$item.Pkgcode:="68"
$item.RtgSeq:="30"
$item.x_Datecode:="25110"
$item.x_Workstation:="mtascale02"
$item.x_WeighTime:="15:50:59"
$item.ReportInvLabel:="internal_fg.rpt"
$item.CastDate:="04/20/25"
$item.Operation:="Scale"
$item.TransCode:="43"
$item.hours:="0"
$item.gencontainerid:="A"
$item.inspectstatus:="P"
$item.sampletype:="PN"
$item.samplewgtea:="5.01"
$item.sampleqty:="1"
$item.sampleweight:="5.01"
$item.numofboxes:="1"
$item.groupcode:="DI"
$item.shift:="1"
$item.autopost:="yes"
$item.userptseries:="O"
$list.push($item)

