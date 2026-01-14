//%attributes = {}

// ----------------------------------------------------
// User name (OS): DWeyrick
// Date and time: 04/19/25, 14:19:04
// ----------------------------------------------------
// Method: _BuildImportRecordData
// Description
// Build test export collection of scale record export data
//
// Parameters
// ----------------------------------------------------
//DLW  07/31/25  Corrected syntax error in var statement

#DECLARE()->$data : Text

var $file : 4D:C1709.File
$file:=File:C1566("C:\\4DDev\\OdysseyRecordImport.txt"; fk platform path:K87:2)
$data:=$file.getText()

CLEAR VARIABLE:C89($file)
