//%attributes = {}
var $body; $headers : Object
var $data : Object
var $settings : cs:C1710.requestSettings

var $mtiquery : Text
var $mtiood : Text
var $list : Collection
$list:=New collection:C1472

$mtiquery:="de0bd03b-5daa-5080-9e14-8f1048e973cc"
$mtiood:="d6a6068e-e2e9-ddab-6a14-4d0364a585de"

$list:=_BuildScrapDataList
$settings:=cs:C1710.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiood
$settings.CompanyID:="tmta"
$settings.DateFormat:="MDY"
$settings.DataList:=$list

$data:=oapi_EnterScrap($settings)

$list:=_BuildSecondaryDataList
$settings:=cs:C1710.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiood
$settings.CompanyID:="tmta"
$settings.DateFormat:="MDY"
$settings.DataList:=$list

$data:=oapi_EnterSecondaryProduction($settings)

$settings:=cs:C1710.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiood
$settings.Username:="dweyrick@metal-technologies.com"
$settings.Password:="MTIProgrammer2024!"

$data:=oapi_Companies($settings)

$settings:=cs:C1710.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiood
$settings.CompanyID:="tmta"
$settings.Username:="dweyrick1@metal-technologies.com"
$settings.Password:="MTIProgrammer2024!"

$data:=oapi_ValidateUsername($settings)

$settings:=cs:C1710.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiquery
$settings.CompanyID:="tmta"
$settings.Username:="dweyrick@metal-technologies.com"
$settings.Password:="MTIProgrammer2024!"

$data:=oapi_LoginToOdyssey($settings)

$settings:=cs:C1710.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiquery
$settings.CompanyID:="tmta"

$data:=oapi_SystemTime($settings)

$settings:=cs:C1710.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiood
$settings.CompanyID:="tmta"
$settings.ProfileID:="Create WIP Container"
$settings.SourceFileData:=_BuildImportRecordData

$data:=oapi_ImportRecords($settings)

$settings:=cs:C1710.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiood
$settings.CompanyID:="tmta"
$settings.ProfileID:="ContainerInv"
$settings.SourceFileData:=""

$data:=oapi_DeleteRecord($settings)

$settings:=cs:C1710.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiood
$settings.CompanyID:="tmta"
$settings.TableName:="ContainerInv"
$settings.UniqueID:=2507730

$data:=oapi_DeleteRecord($settings)

$list:=_BuildUpdateRecordList
$settings:=cs:C1710.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiood
$settings.CompanyID:="tmta"
$settings.TableName:="ContainerInv"
$settings.ListOfFieldValues:=$list
$settings.UniqueID:=2507730

$data:=oapi_UpdateRecord($settings)

$list:=_BuildFindRecordList
$settings:=cs:C1710.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiood
$settings.CompanyID:="tmta"
$settings.TableName:="ContainerInv"
$settings.ListOfFieldValues:=$list

$data:=oapi_FindRecord($settings)

$list:=_BuildAddRecordList
$settings:=cs:C1710.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiood
$settings.CompanyID:="tmta"
$settings.TableName:="ContainerInv"
$settings.ListOfFieldValues:=$list

$data:=oapi_AddRecord($settings)

$settings:=cs:C1710.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiquery
$settings.CompanyID:="tmta"
$settings.dataArrayName:="maindb_products"
$settings.dataObjectName:="DataSetOut"
$settings.delResultProperty:="@z_internal@"
$settings.DataView:="Active Parts List"

$data:=oapi_FetchDataView($settings)

$settings:=cs:C1710.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:=$mtiquery
$settings.CompanyID:="tmta"

$data:=oapi_ApiVersion($settings)
