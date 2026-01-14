//%attributes = {}

// ----------------------------------------------------
// User name (OS): DWeyrick
// Date and time: 04/22/25, 10:51:01
// ----------------------------------------------------
// Method: oapi_ExtractErrorIDFromError
// Description
// Returns the error id from the specifed error message
//
// Parameters
// ----------------------------------------------------

#DECLARE($error : Text)->$id : Text

var $chars; $end; $start : Integer
$start:=Position:C15("("; $error)+1
$end:=Position:C15(")"; $error)
$chars:=$end-$start

$id:=Substring:C12($error; $start; $chars)