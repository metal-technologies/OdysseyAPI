//%attributes = {}

var $settings : cs:C1710.requestSettings
var $data : Variant
var $dv : cs:C1710.fetchDataView
var $result : Object
//$result:=New object()

//Download settings object
$settings:=cs:C1710.requestSettings.new()
$settings.apiContentType:="application/json"
$settings.apiKey:="d6a6068e-e2e9-ddab-6a14-4d0364a585de"
$settings.apiURL:="https://api.blinfo.com/metaltech/FetchData/DataView"
$settings.apiMethod:="Post"
$settings.CompanyID:="mti"
$settings.dataArrayName:="maindb_routingdtl"
$settings.dataObjectName:="DataSetOut"
$settings.delResultProperty:="@z_internal@"
$settings.DataView:="4DLabelTypeDefault"

//Define the api call request
$dv:=cs:C1710.fetchDataView.new($settings)

//Add parm to request call
$dv.request.body.ParameterList:=$dv.request.addParameterToList("maindb.RoutingDtl.CompanyID"; "="; "mta")

//Execute the api call request and return data
$result:=$dv.request.run()



