//Define class properties
property settings : Object
property body : Object
property headers : Object
property method : Text
property options : Object
property apiCall : 4D:C1709.HTTPRequest
property dataArrayName : Text
property delPropertyName : Text
property result : Object
property ParameterList : Collection
property arrayName : Text
property Username : Text
property Password : Text
property CompanyID : Text
property TableName : Text
property ListOfFieldValues : Collection
property DataView : Text
property UniqueID : Integer
property data : Text
property ProfileID : Text
property SourceFileData : Text
property apiContentType : Text
property apiKey : Text
property apiMethod : Text
property apiURL : Text
property dataObjectName : Text
property delResultProperty : Text
property DateFormat : Text
property DataList : Collection
property InterfaceID : Real
property ImportID : Real
property errorID : Real

Class constructor($settings)
	
	//Assign specified settings to request
	This:C1470.settings:=$settings
	
	//Build data view api request headers
	This:C1470.headers:=This:C1470._requestHeaders()
	
	
Function addRecord()
	
	//Build version api request body
	This:C1470.body:=This:C1470._addRecordBody(This:C1470.settings)
	
	//Build values for request options
	This:C1470.options:=This:C1470._requestOptions(This:C1470.settings.apiMethod; This:C1470.headers; This:C1470.body)
	
	
Function _addRecordBody($settings : cs:C1710.requestSettings) : Object
	
	var $body : Object
	$body:=New object:C1471()
	
	$body.CompanyID:=$settings.CompanyID
	$body.TableName:=$settings.TableName
	$body.ListOfFieldValues:=$settings.ListOfFieldValues
	
	return $body
	
	
Function companies()
	
	//Build version api request body
	This:C1470.body:=This:C1470._companiesBody(This:C1470.settings)
	
	//Build values for request options
	This:C1470.options:=This:C1470._requestOptions(This:C1470.settings.apiMethod; This:C1470.headers; This:C1470.body)
	
	
Function _companiesBody($settings : cs:C1710.requestSettings) : Object
	
	var $body : Object
	$body:=New object:C1471()
	
	$body.Username:=$settings.Username
	$body.Password:=$settings.Password
	
	return $body
	
	
Function dataview()
	
	//Build data view api request body
	This:C1470.body:=This:C1470._dataviewBody(This:C1470.settings)
	
	//Build request options
	This:C1470.options:=This:C1470._dataviewOptions()
	
	
Function _dataviewBody($settings : cs:C1710.requestSettings) : Object
	
	var $body : Object
	$body:=New object:C1471()
	
	//Build request body object
	$body.CompanyID:=$settings.CompanyID
	$body.DataView:=$settings.DataView
	$body.ParameterList:=New collection:C1472()
	
	return $body
	
	
Function _dataviewOptions() : Object
	
	var $options : Object
	$options:=New object:C1471()
	
	$options.method:=This:C1470.settings.apiMethod
	$options.headers:=This:C1470.headers
	$options.body:=This:C1470.body
	$options.arrayName:=This:C1470.settings.dataArrayName
	$options.delPropertyName:=This:C1470.settings.delResultProperty
	$options.result:=New object:C1471
	
	//Set callback for response processing
	$options.onResponse:=Formula:C1597(oapi_onResponse($1; $2))
	
	return $options
	
	
Function addParameterToList($fieldName : Text; $operator : Text; $parmValue : Text) : Collection
	
	//Build Parameter object
	var $parmObject : Object
	var $list : Collection
	$list:=New collection:C1472
	
	//Define parameter object
	$parmObject:=New object:C1471()
	$parmObject.FieldName:=$fieldName
	$parmObject.Operator:=$operator
	$parmObject.ParameterValue:=$parmValue
	
	//Check for ParameterList body property
	If ((This:C1470.body.ParameterList#Null:C1517) && (This:C1470.body.ParameterList.length>0))
		$list:=This:C1470.body.ParameterList
	End if 
	
	//Build request header parameter object collection
	$list.push($parmObject)
	//
	
	//Clear local variables
	CLEAR VARIABLE:C89($parmObject)
	
	return $list
	
	
Function deleteRecord()
	
	//Build version api request body
	This:C1470.body:=This:C1470._deleteRecordBody(This:C1470.settings)
	
	//Build values for request options
	This:C1470.options:=This:C1470._requestOptions(This:C1470.settings.apiMethod; This:C1470.headers; This:C1470.body)
	
	
Function _deleteRecordBody($settings : cs:C1710.requestSettings) : Object
	
	var $body : Object
	$body:=New object:C1471()
	
	$body.CompanyID:=$settings.CompanyID
	$body.TableName:=$settings.TableName
	$body.UniqueID:=$settings.UniqueID
	
	return $body
	
	
Function errorMessage()
	
	//Update the apiURL with company
	This:C1470.settings.apiURL:=This:C1470.settings.apiURL+"/"+String:C10(This:C1470.settings.errorID)+"?CompanyID="+This:C1470.settings.CompanyID
	
	//Build version api request body
	This:C1470.body:=This:C1470._emptyBody()
	
	//Build values for request options
	This:C1470.options:=This:C1470._requestOptions(This:C1470.settings.apiMethod; This:C1470.headers; This:C1470.body)
	
	
Function findRecord()
	
	//Build version api request body
	This:C1470.body:=This:C1470._findRecordBody(This:C1470.settings)
	
	//Build values for request options
	This:C1470.options:=This:C1470._requestOptions(This:C1470.settings.apiMethod; This:C1470.headers; This:C1470.body)
	
	
Function _findRecordBody($settings : cs:C1710.requestSettings) : Object
	
	var $body : Object
	$body:=New object:C1471()
	
	$body.CompanyID:=$settings.CompanyID
	$body.TableName:=$settings.TableName
	$body.ListOfFieldValues:=$settings.ListOfFieldValues
	
	return $body
	
	
Function importRecords()
	
	//Build version api request body
	This:C1470.body:=This:C1470._importRecordBody(This:C1470.settings)
	
	//Build values for request options
	This:C1470.options:=This:C1470._requestOptions(This:C1470.settings.apiMethod; This:C1470.headers; This:C1470.body)
	
	
Function _importRecordBody($settings : cs:C1710.requestSettings) : Object
	
	var $body : Object
	$body:=New object:C1471()
	
	$body.CompanyID:=$settings.CompanyID
	$body.ProfileID:=$settings.ProfileID
	$body.SourceFileData:=$settings.SourceFileData
	
	return $body
	
	
Function login()
	
	//Build version api request body
	This:C1470.body:=This:C1470._loginBody(This:C1470.settings)
	
	//Build values for request options
	This:C1470.options:=This:C1470._requestOptions(This:C1470.settings.apiMethod; This:C1470.headers; This:C1470.body)
	
	
Function _loginBody($settings : cs:C1710.requestSettings) : Object
	
	var $body : Object
	$body:=New object:C1471()
	
	$body.CompanyID:=$settings.CompanyID
	$body.Username:=$settings.Username
	$body.Password:=$settings.Password
	
	return $body
	
	
Function scrap()
	
	//Build api request body
	This:C1470.body:=This:C1470._secondaryBody(This:C1470.settings)
	
	//Build values for request options
	This:C1470.options:=This:C1470._requestOptions(This:C1470.settings.apiMethod; This:C1470.headers; This:C1470.body)
	
	
Function secondary()
	
	//Build api request body
	This:C1470.body:=This:C1470._secondaryBody(This:C1470.settings)
	
	//Build values for request options
	This:C1470.options:=This:C1470._requestOptions(This:C1470.settings.apiMethod; This:C1470.headers; This:C1470.body)
	
	
Function _secondaryBody($settings : cs:C1710.requestSettings) : Object
	
	var $body : Object
	$body:=New object:C1471()
	
	$body.CompanyID:=$settings.CompanyID
	$body.DateFormat:=$settings.DateFormat
	$body.DataList:=$settings.DataList
	
	return $body
	
	
Function systemTime()
	
	//Update the apiURL with company
	This:C1470.settings.apiURL:=This:C1470.settings.apiURL+"?CompanyID="+This:C1470.settings.CompanyID
	
	//Build version api request body
	This:C1470.body:=This:C1470._emptyBody()
	
	//Build values for request options
	This:C1470.options:=This:C1470._requestOptions(This:C1470.settings.apiMethod; This:C1470.headers; This:C1470.body)
	
	
Function updateRecord()
	
	//Build version api request body
	This:C1470.body:=This:C1470._updateRecordBody(This:C1470.settings)
	
	//Build values for request options
	This:C1470.options:=This:C1470._requestOptions(This:C1470.settings.apiMethod; This:C1470.headers; This:C1470.body)
	
	
Function _updateRecordBody($settings : cs:C1710.requestSettings) : Object
	
	var $body : Object
	$body:=New object:C1471()
	
	$body.CompanyID:=$settings.CompanyID
	$body.TableName:=$settings.TableName
	$body.UniqueID:=$settings.UniqueID
	$body.ListOfFieldValues:=$settings.ListOfFieldValues
	
	return $body
	
	
Function validateUsername()
	
	//Update the apiURL with company
	This:C1470.settings.apiURL:=This:C1470.settings.apiURL+"?CompanyID="+This:C1470.settings.CompanyID
	
	//Build version api request body
	This:C1470.body:=This:C1470._validateUsernameBody(This:C1470.settings)
	
	//Build values for request options
	This:C1470.options:=This:C1470._requestOptions(This:C1470.settings.apiMethod; This:C1470.headers; This:C1470.body)
	
	
Function _validateUsernameBody($settings : cs:C1710.requestSettings) : Object
	
	var $body : Object
	$body:=New object:C1471()
	
	$body.CompanyID:=$settings.CompanyID
	$body.Username:=$settings.Username
	$body.Password:=$settings.Password
	
	return $body
	
	
Function version()
	
	//Build version api request body
	This:C1470.body:=This:C1470._emptyBody()
	
	//Build values for request options
	This:C1470.options:=This:C1470._requestOptions(This:C1470.settings.apiMethod; This:C1470.headers; This:C1470.body)
	
	
Function onResponse($request : Object; $event : Object) : Object
	
	//My onResponse method, if you want to handle the request asynchronously
	var $array : Collection
	var $result : Object
	
	//Returned array of data objects
	If ($request.response.body.DataSetOut#Null:C1517)
		$array:=$request.response.body.DataSetOut[This:C1470.dataArrayName]
		$result.dataArray:=oapi_delArrayProperties($array; This:C1470.settings.delResultProperty)
	Else 
		$result.dataArray:=New collection:C1472
	End if 
	
	$result.errorMessage:=$request.response.body.ErrorMessage
	$result.statusText:=$request.response.statusText
	$result.statusCode:=$request.response.status
	$result.success:=$request.response.body.Success
	$result.terminated:=$request.terminated
	$result.response:=$request.response
	
	
	
Function onData($request : Object; $event : Object) : Object
	
	//My onResponse method, if you want to handle the request asynchronously
	var $array : Collection
	var $result : Object
	
	//Returned array of data objects
	If ($request.response.body.DataSetOut#Null:C1517)
		$array:=$request.response.body.DataSetOut[This:C1470.dataArrayName]
		$result.dataArray:=oapi_delArrayProperties($array; This:C1470.settings.delResultProperty)
	Else 
		$result.dataArray:=New collection:C1472
	End if 
	
	$result.errorMessage:=$request.response.body.ErrorMessage
	$result.statusText:=$request.response.statusText
	$result.statusCode:=$request.response.status
	$result.success:=$request.response.body.Success
	$result.terminated:=$request.terminated
	$result.response:=$request.response
	
	
Function onError($request : 4D:C1709.HTTPRequest; $event : Object)
	//My onError method, if you want to handle the request asynchronously
	var $response : Object
	
	//Returned array of data objects
	This:C1470.result.dataArray:=New collection:C1472
	This:C1470.result.errorMessage:=$request.response.body.ErrorMessage
	This:C1470.result.statusText:=$request.response.statusText
	This:C1470.result.statusCode:=$request.response.status
	This:C1470.result.success:=$request.response.body.Success
	This:C1470.result.terminated:=$request.terminated
	
	
Function addFieldValueToList($fieldName : Text; $fieldValue : Text)
	
	var $parmObject : Object
	
	//Build request header Parameter object
	$parmObject:=New object:C1471()
	$parmObject.Key:=$fieldName
	$parmObject.Value:=$fieldValue
	
	//Add new parameter to header parm collection
	This:C1470.settings.ListOfFieldValues.push($parmObject)
	
	//Clear local variables
	CLEAR VARIABLE:C89($parmObject)
	
	
Function errorRun() : Object
	
	var $result : Object
	var $wait : Real
	var $crlf; $lvl1; $lvl2 : Text
	$crlf:=Char:C90(Carriage return:K15:38)+Char:C90(Line feed:K15:40)
	$wait:=5
	$result:=New object:C1471()
	
	//Generate HTTP Request
	This:C1470.apiCall:=4D:C1709.HTTPRequest.new(This:C1470.settings.apiURL; This:C1470.options).wait($wait)
	$result:=This:C1470.apiCall.response.body
	$result.message:=""
	
	//Store error id
	$result.errorID:=This:C1470.settings.errorID
	
	//Parse Level One Text message
	$result.LevelOneText:=($result.LevelOneText="@&1@") ? Replace string:C233($result.LevelOneText; "&1"; This:C1470.settings.DataView) : $result.LevelOneText
	
	//Parse error message information
	$result.message:=($result.ErrorMessage#"") ? $result.ErrorMessage+$crlf : $result.message
	$lvl1:=($result.LevelOneText#"") ? $result.LevelOneText+$crlf : $lvl1
	$lvl2:=($result.LevelTwoText#"") ? $result.LevelTwoText+$crlf : $lvl2
	$result.message:=$result.message+$lvl1+$lvl2
	
	return $result
	
	
Function run() : Object
	
	var $result : Object
	var $wait : Real
	$result:=New object:C1471()
	$wait:=5
	
	//TRACE
	
	//Generate HTTP Request
	This:C1470.apiCall:=4D:C1709.HTTPRequest.new(This:C1470.settings.apiURL; This:C1470.options).wait($wait)
	$result:=This:C1470.apiCall.response.body
	
	//Define data property in result
	$result.data:=New collection:C1472()
	
	//Check for error message
	If (Bool:C1537($result.DataSetOut#Null:C1517))
		//
		//Return data collection
		$result.data:=$result.DataSetOut[This:C1470.options.arrayName]
		//
		//Remove DataSetOut object from api call
		OB REMOVE:C1226($result; This:C1470.settings.dataObjectName)
		//
	Else 
		//
		$result.data:=Null:C1517
		
		//Get error info if error message returned
		If ($result.ErrorMessage#"")
			This:C1470.settings.errorID:=oapi_ExtractErrorIDFromError($result.ErrorMessage)
			$result.errorInfo:=oapi_GetErrorInformation(This:C1470.settings)
		Else 
			This:C1470.settings.errorID:="-99"
			$result.ErrorMessage:="Failure without error ID.  $result.DataSetOut is Null="+String:C10($result.DataSetOut=Null:C1517)
		End if 
		
	End if 
	
	return $result
	
	
Function _emptyBody() : Object
	
	var $body : Object
	$body:=New object:C1471()
	
	return $body
	
	
Function _requestHeaders() : Object
	
	var $header : Object
	$header:=New object:C1471
	
	//Add api headers
	$header["X-API-Key"]:=This:C1470.settings.apiKey
	$header["Content-Type"]:=This:C1470.settings.apiContentType
	return $header
	
	CLEAR VARIABLE:C89($header)
	
	
Function _requestOptions($method : Text; $headers : Object; $body : Object) : Object
	
	var $options : Object
	$options:=New object:C1471()
	
	$options.method:=$method
	$options.headers:=$headers
	$options.body:=$body
	$options.delPropertyName:=This:C1470.settings.delResultProperty
	$options.result:=New object:C1471()
	
	//Set callback for response processing
	$options.onResponse:=Formula:C1597(oapi_onResponse($1; $2))
	
	return $options
	
	