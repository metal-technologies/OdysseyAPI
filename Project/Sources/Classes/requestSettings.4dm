//Define data view api request settings object properties
property apiContentType : Text
property apiKey : Text
property apiMethod : Text
property apiURL : Text
property CompanyID : Text
property dataArrayName : Text
property dataObjectName : Text
property DataView : Text
property delResultProperty : Text
property TableName : Text
property ListOfFieldValues : Collection
property UniqueID : Real
property ProfileID : Text
property SourceFileData : Text
property DateFormat : Text
property DataList : Collection
property InterfaceID : Real
property ImportID : Real
property errorID : Real
property Username : Text
property Password : Text
property ParameterList : Collection
property errorURL : Text

Class constructor()
	
	This:C1470.apiContentType:=""
	This:C1470.apiKey:=""
	This:C1470.apiMethod:=""
	This:C1470.apiURL:=""
	This:C1470.CompanyID:=""
	This:C1470.dataArrayName:=""
	This:C1470.dataObjectName:=""
	This:C1470.DataView:=""
	This:C1470.delResultProperty:=""
	This:C1470.errorURL:=""
	This:C1470.TableName:=""
	This:C1470.ListOfFieldValues:=New collection:C1472()
	This:C1470.UniqueID:=0
	This:C1470.ProfileID:=""
	This:C1470.SourceFileData:=""
	This:C1470.DateFormat:=""
	This:C1470.DataList:=New collection:C1472()
	This:C1470.InterfaceID:=0
	This:C1470.ImportID:=0
	This:C1470.errorID:=Null:C1517
	This:C1470.Username:=""
	This:C1470.Password:=""
	This:C1470.ParameterList:=New collection:C1472()
	
	
	
	