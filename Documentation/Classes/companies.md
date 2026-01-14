<!-- Type your summary here -->
# companies Class Documentation

## Overview
The `companies` class is a specialized API client for retrieving available companies for authenticated users through the Odyssey API system. This class provides an interface to obtain a list of companies that a specific user/password combination has access to, making it essential for multi-tenant applications, company selection workflows, and user authorization processes.

## Class Information
- **Namespace**: `cs.OdysseyAPI.companies`
- **API Endpoint**: `/System/Login/Companies`
- **Base URL**: `https://api.blinfo.com/metaltech/Login/Companies`
- **HTTP Method**: POST
- **Authentication**: Requires username and password in request body

## Properties

### Core Properties
- `request` (cs.request) - The underlying request object that handles HTTP communication
- `settings` (Object) - Configuration settings object passed to the constructor

## Constructor

```4d
Class constructor($settings : Object)
    $settings.apiURL:="https://api.blinfo.com/metaltech/Login/Companies"
    $settings.apiMethod:="POST"
    This.request:=cs.request.new($settings)
    This.request.companies()
    This.settings:=$settings
```

The constructor automatically configures the API endpoint and HTTP method, creates a request object using the `requestClass`, and calls the companies endpoint.

### Parameters
- `$settings` (Object) - A settings object, typically `cs.responseSettings.new()` containing:
  - `Username` (Text) - User login credentials
  - `Password` (Text) - User password

### Example Usage
```4d
var $settings : Object
var $companiesAPI : cs.OdysseyAPI.companies

// Create settings object with user credentials
$settings:=cs.responseSettings.new()
$settings.Username:="dweyrick@company.com"
$settings.Password:="SecurePassword123"

// Initialize companies API client
$companiesAPI:=cs.OdysseyAPI.companies.new($settings)
```

## Usage Examples

### Basic Company List Retrieval
```4d
var $settings : Object
var $companiesAPI : cs.OdysseyAPI.companies
var $result : Object

// Initialize settings with user credentials
$settings:=cs.responseSettings.new()
$settings.Username:="dweyrick@company.com"
$settings.Password:="MySecurePassword"

// Create companies API instance
$companiesAPI:=cs.OdysseyAPI.companies.new($settings)

// Execute the request
$result:=$companiesAPI.request.run()

If (Bool($result.Success))
    If ($result.data.length>0)
        ALERT("Found "+String($result.data.length)+" available companies")
        
        // Display available companies
        For each (var $company; $result.data)
            ALERT("Company: "+String($company.CompanyName)+" (ID: "+String($company.CompanyID)+")")
        End for each
    Else 
        ALERT("No companies available for this user")
    End if
Else 
    ALERT("Failed to retrieve companies: "+String($result.ErrorMessage))
End if
```

### User Company Access Function
```4d
// Function to get companies available to a user
Function getUserCompanies($username : Text; $password : Text) : Object
    var $settings : Object
    var $companiesAPI : cs.OdysseyAPI.companies
    var $result : Object
    var $companyAccess : Object
    
    // Initialize company access result
    $companyAccess:=New object()
    $companyAccess.success:=False
    $companyAccess.timestamp:=String(Current date; ISO date GMT; Current time)
    $companyAccess.username:=$username
    $companyAccess.companies:=New collection()
    
    Try
        // Validate input parameters
        If ($username="") || ($password="")
            $companyAccess.message:="Username and password are required"
            return $companyAccess
        End if
        
        // Set up companies request
        $settings:=cs.responseSettings.new()
        $settings.Username:=$username
        $settings.Password:=$password
        
        // Retrieve companies
        $companiesAPI:=cs.OdysseyAPI.companies.new($settings)
        $result:=$companiesAPI.request.run()
        
        If (Bool($result.Success))
            $companyAccess.success:=True
            $companyAccess.companies:=$result.data
            $companyAccess.companyCount:=$result.data.length
            $companyAccess.message:="Companies retrieved successfully"
            
            // Extract company IDs for easy access
            var $companyIDs : Collection
            $companyIDs:=New collection()
            For each (var $company; $result.data)
                $companyIDs.push($company.CompanyID)
            End for each
            $companyAccess.companyIDs:=$companyIDs
            
            // Log successful company retrieval
            logCompanyAccess("SUCCESS"; $username; $result.data.length)
            
        Else 
            $companyAccess.message:="Failed to retrieve companies: "+String($result.ErrorMessage)
            $companyAccess.errorCode:=$result.statusCode
            
            // Log failed company retrieval
            logCompanyAccess("FAILED"; $username; $result.ErrorMessage)
        End if
        
    Catch
        $companyAccess.message:="Company retrieval error: "+Last errors[0].message
        $companyAccess.exception:=True
        
        // Log company retrieval exception
        logCompanyAccess("ERROR"; $username; Last errors[0].message)
    End try
    
    return $companyAccess
```

### Company Selection Workflow
```4d
// Function to handle company selection during login
Function handleCompanySelection($username : Text; $password : Text) : Object
    var $companyAccess : Object
    var $selectedCompany : Object
    var $selectionResult : Object
    
    $selectionResult:=New object()
    $selectionResult.success:=False
    $selectionResult.companySelected:=False
    
    Try
        // Get available companies for user
        $companyAccess:=getUserCompanies($username; $password)
        
        If ($companyAccess.success)
            Case of 
                : ($companyAccess.companyCount=0)
                    $selectionResult.message:="No companies available for this user"
                    
                : ($companyAccess.companyCount=1)
                    // Auto-select single company
                    $selectedCompany:=$companyAccess.companies[0]
                    $selectionResult.success:=True
                    $selectionResult.companySelected:=True
                    $selectionResult.selectedCompany:=$selectedCompany
                    $selectionResult.autoSelected:=True
                    $selectionResult.message:="Auto-selected company: "+String($selectedCompany.CompanyName)
                    
                Else 
                    // Present company selection to user
                    $selectedCompany:=presentCompanySelectionDialog($companyAccess.companies)
                    
                    If ($selectedCompany#Null)
                        $selectionResult.success:=True
                        $selectionResult.companySelected:=True
                        $selectionResult.selectedCompany:=$selectedCompany
                        $selectionResult.autoSelected:=False
                        $selectionResult.message:="User selected company: "+String($selectedCompany.CompanyName)
                    Else 
                        $selectionResult.message:="No company selected by user"
                    End if
            End case
            
            $selectionResult.availableCompanies:=$companyAccess.companies
            
        Else 
            $selectionResult.message:=$companyAccess.message
        End if
        
    Catch
        $selectionResult.message:="Company selection error: "+Last errors[0].message
        $selectionResult.exception:=True
    End try
    
    return $selectionResult
```

### Login with Company Selection Integration
```4d
// Function to integrate company selection with login process
Function performLoginWithCompanySelection($username : Text; $password : Text) : Object
    var $loginResult : Object
    var $companySelection : Object
    var $finalLogin : Object
    
    $loginResult:=New object()
    $loginResult.success:=False
    $loginResult.timestamp:=String(Current date; ISO date GMT; Current time)
    $loginResult.username:=$username
    
    Try
        // Step 1: Get available companies
        $companySelection:=handleCompanySelection($username; $password)
        
        If ($companySelection.success) && ($companySelection.companySelected)
            // Step 2: Perform actual login with selected company
            $finalLogin:=performCompanyLogin(\
                $username; \
                $password; \
                $companySelection.selectedCompany.CompanyID)
            
            If ($finalLogin.success)
                $loginResult.success:=True
                $loginResult.message:="Login successful"
                $loginResult.sessionToken:=$finalLogin.sessionToken
                $loginResult.userID:=$finalLogin.userID
                $loginResult.selectedCompany:=$companySelection.selectedCompany
                $loginResult.availableCompanies:=$companySelection.availableCompanies
                $loginResult.autoSelectedCompany:=$companySelection.autoSelected
                
                // Store user session with company context
                storeUserSessionWithCompany($loginResult)
                
            Else 
                $loginResult.message:="Login failed: "+$finalLogin.message
            End if
        Else 
            $loginResult.message:="Company selection failed: "+$companySelection.message
            $loginResult.availableCompanies:=$companySelection.availableCompanies
        End if
        
    Catch
        $loginResult.message:="Login with company selection error: "+Last errors[0].message
        $loginResult.exception:=True
    End try
    
    return $loginResult
```

### Company Access Validation
```4d
// Function to validate user access to specific company
Function validateCompanyAccess($username : Text; $password : Text; $companyID : Text) : Object
    var $validationResult : Object
    var $companyAccess : Object
    var $hasAccess : Boolean
    
    $validationResult:=New object()
    $validationResult.hasAccess:=False
    $validationResult.username:=$username
    $validationResult.companyID:=$companyID
    
    Try
        // Get user's available companies
        $companyAccess:=getUserCompanies($username; $password)
        
        If ($companyAccess.success)
            // Check if requested company is in the list
            $hasAccess:=False
            For each (var $company; $companyAccess.companies)
                If ($company.CompanyID=$companyID)
                    $hasAccess:=True
                    $validationResult.companyInfo:=$company
                    break
                End if
            End for each
            
            $validationResult.hasAccess:=$hasAccess
            $validationResult.availableCompanies:=$companyAccess.companies
            
            If ($hasAccess)
                $validationResult.message:="User has access to company: "+$companyID
            Else 
                $validationResult.message:="User does not have access to company: "+$companyID
            End if
            
        Else 
            $validationResult.message:="Could not retrieve companies: "+$companyAccess.message
        End if
        
    Catch
        $validationResult.message:="Company access validation error: "+Last errors[0].message
        $validationResult.exception:=True
    End try
    
    return $validationResult
```

### User Profile with Company Access
```4d
// Function to create user profile with company information
Function createUserProfileWithCompanies($username : Text; $password : Text) : Object
    var $userProfile : Object
    var $companyAccess : Object
    var $userInfo : Object
    
    $userProfile:=New object()
    $userProfile.success:=False
    $userProfile.username:=$username
    $userProfile.createdAt:=String(Current date; ISO date GMT; Current time)
    
    Try
        // Get basic user information
        $userInfo:=getUserBasicInfo($username)
        
        // Get company access information
        $companyAccess:=getUserCompanies($username; $password)
        
        If ($companyAccess.success)
            $userProfile.success:=True
            $userProfile.userInfo:=$userInfo
            $userProfile.companyAccess:=$companyAccess
            
            // Build user capabilities based on company access
            $userProfile.capabilities:=New object()
            $userProfile.capabilities.multiCompanyAccess:=($companyAccess.companyCount>1)
            $userProfile.capabilities.companyCount:=$companyAccess.companyCount
            $userProfile.capabilities.primaryCompany:=getPrimaryCompany($companyAccess.companies)
            
            // Generate user permissions summary
            $userProfile.permissions:=generateUserPermissionsSummary($username; $companyAccess.companies)
            
            $userProfile.message:="User profile created successfully"
            
            // Cache user profile
            cacheUserProfile($userProfile)
            
        Else 
            $userProfile.message:="Could not retrieve company access: "+$companyAccess.message
        End if
        
    Catch
        $userProfile.message:="User profile creation error: "+Last errors[0].message
        $userProfile.exception:=True
    End try
    
    return $userProfile
```

### Company Switching Function
```4d
// Function to switch between companies for authenticated user
Function switchUserCompany($sessionToken : Text; $newCompanyID : Text) : Object
    var $switchResult : Object
    var $currentSession : Object
    var $companyValidation : Object
    var $newSession : Object
    
    $switchResult:=New object()
    $switchResult.success:=False
    $switchResult.newCompanyID:=$newCompanyID
    $switchResult.timestamp:=String(Current date; ISO date GMT; Current time)
    
    Try
        // Get current session information
        $currentSession:=getSessionInfo($sessionToken)
        
        If ($currentSession=Null)
            $switchResult.message:="Invalid or expired session token"
            return $switchResult
        End if
        
        // Validate user access to new company
        $companyValidation:=validateCompanyAccess(\
            $currentSession.username; \
            $currentSession.password; \
            $newCompanyID)
        
        If ($companyValidation.hasAccess)
            // Create new session with different company
            $newSession:=createCompanySession(\
                $currentSession.username; \
                $newCompanyID; \
                $companyValidation.companyInfo)
            
            If ($newSession.success)
                $switchResult.success:=True
                $switchResult.newSessionToken:=$newSession.sessionToken
                $switchResult.previousCompanyID:=$currentSession.companyID
                $switchResult.newCompanyInfo:=$companyValidation.companyInfo
                $switchResult.message:="Successfully switched to company: "+String($companyValidation.companyInfo.CompanyName)
                
                // Invalidate old session
                invalidateSession($sessionToken)
                
                // Log company switch
                logCompanySwitch($currentSession.username; $currentSession.companyID; $newCompanyID)
                
            Else 
                $switchResult.message:="Failed to create new company session: "+$newSession.message
            End if
        Else 
            $switchResult.message:="User does not have access to company: "+$newCompanyID
        End if
        
    Catch
        $switchResult.message:="Company switch error: "+Last errors[0].message
        $switchResult.exception:=True
    End try
    
    return $switchResult
```

### Batch Company Access Check
```4d
// Function to check company access for multiple users
Function batchCheckCompanyAccess($userCredentials : Collection; $targetCompanyID : Text) : Collection
    var $batchResults : Collection
    var $userCreds : Object
    var $accessResult : Object
    var $i : Integer
    
    $batchResults:=New collection()
    
    For ($i; 0; $userCredentials.length-1)
        $userCreds:=$userCredentials[$i]
        
        Try
            // Check company access for each user
            $accessResult:=validateCompanyAccess(\
                $userCreds.username; \
                $userCreds.password; \
                $targetCompanyID)
            
            // Add batch context
            $accessResult.batchIndex:=$i
            $accessResult.requestID:=$userCreds.requestID
            
            $batchResults.push($accessResult)
            
        Catch
            // Add error entry for failed check
            $batchResults.push(New object(\
                "hasAccess"; False; \
                "batchIndex"; $i; \
                "requestID"; $userCreds.requestID; \
                "username"; $userCreds.username; \
                "companyID"; $targetCompanyID; \
                "message"; "Exception during access check: "+Last errors[0].message; \
                "exception"; True))
        End try
        
        // Add small delay to avoid overwhelming the API
        DELAY PROCESS(Current process; 100)  // 1 second delay
    End for
    
    return $batchResults
```

## Integration Patterns

### Single Sign-On (SSO) Integration
```4d
// Function to integrate company selection with SSO
Function handleSSOCompanySelection($ssoToken : Text) : Object
    var $ssoResult : Object
    var $decodedToken : Object
    var $companySelection : Object
    
    $ssoResult:=New object()
    $ssoResult.success:=False
    $ssoResult.authMethod:="SSO"
    
    Try
        // Decode SSO token to get user credentials
        $decodedToken:=decodeSSOToken($ssoToken)
        
        If ($decodedToken.valid)
            // Get companies for SSO user
            $companySelection:=handleCompanySelection(\
                $decodedToken.username; \
                $decodedToken.password)
            
            If ($companySelection.success)
                $ssoResult.success:=True
                $ssoResult.username:=$decodedToken.username
                $ssoResult.companySelection:=$companySelection
                $ssoResult.ssoToken:=$ssoToken
                
                If ($companySelection.companySelected)
                    $ssoResult.selectedCompany:=$companySelection.selectedCompany
                    $ssoResult.requiresSelection:=False
                Else 
                    $ssoResult.requiresSelection:=True
                    $ssoResult.availableCompanies:=$companySelection.availableCompanies
                End if
                
            Else 
                $ssoResult.message:="SSO company selection failed: "+$companySelection.message
            End if
        Else 
            $ssoResult.message:="Invalid SSO token"
        End if
        
    Catch
        $ssoResult.message:="SSO company selection error: "+Last errors[0].message
        $ssoResult.exception:=True
    End try
    
    return $ssoResult
```

### Multi-Tenant Application Integration
```4d
// Function to integrate with multi-tenant applications
Function setupMultiTenantSession($username : Text; $password : Text; $applicationConfig : Object) : Object
    var $tenantSetup : Object
    var $companyAccess : Object
    var $tenantMappings : Object
    var $company : Object
    
    $tenantSetup:=New object()
    $tenantSetup.success:=False
    $tenantSetup.username:=$username
    $tenantSetup.applicationName:=$applicationConfig.name
    
    Try
        // Get user's company access
        $companyAccess:=getUserCompanies($username; $password)
        
        If ($companyAccess.success)
            // Map companies to application tenants
            $tenantMappings:=New object()
            
            For each ($company; $companyAccess.companies)
                // Create tenant configuration for each company
                var $tenantConfig : Object
                $tenantConfig:=New object()
                $tenantConfig.companyID:=$company.CompanyID
                $tenantConfig.companyName:=$company.CompanyName
                $tenantConfig.tenantID:=generateTenantID($company.CompanyID; $applicationConfig.name)
                $tenantConfig.databaseSchema:=mapCompanyToSchema($company.CompanyID)
                $tenantConfig.permissions:=getUserPermissionsForCompany($username; $company.CompanyID)
                
                $tenantMappings[$company.CompanyID]:=$tenantConfig
            End for each
            
            $tenantSetup.success:=True
            $tenantSetup.tenantMappings:=$tenantMappings
            $tenantSetup.defaultTenant:=getDefaultTenant($tenantMappings)
            $tenantSetup.message:="Multi-tenant setup completed successfully"
            
            // Store tenant configuration
            storeTenantConfiguration($username; $tenantSetup)
            
        Else 
            $tenantSetup.message:="Could not retrieve company access: "+$companyAccess.message
        End if
        
    Catch
        $tenantSetup.message:="Multi-tenant setup error: "+Last errors[0].message
        $tenantSetup.exception:=True
    End try
    
    return $tenantSetup
```

## Security Considerations

1. **Credential Protection**: Never log or store passwords in plain text
2. **Session Management**: Implement secure session tokens when switching companies
3. **Access Control**: Always validate company access before allowing operations
4. **Audit Logging**: Log company access attempts and company switches
5. **Rate Limiting**: Implement rate limiting to prevent brute force attacks
6. **Input Validation**: Validate all input parameters before API calls

## Key Features

1. **Company Discovery**: Retrieve all companies available to authenticated users
2. **Access Validation**: Verify user access to specific companies
3. **Company Selection**: Support for manual and automatic company selection
4. **Session Management**: Handle company-specific user sessions
5. **Multi-Tenant Support**: Integration with multi-tenant applications
6. **SSO Integration**: Support for Single Sign-On workflows with company selection
7. **Batch Operations**: Check company access for multiple users
8. **Company Switching**: Allow users to switch between accessible companies

## Notes

- This class is specifically designed for the Odyssey API system
- The endpoint requires Username and Password in the request body
- Uses the `requestClass` for HTTP communication and error handling
- Essential for multi-tenant applications where users have access to multiple companies
- The class automatically calls the companies endpoint during construction
- Results are available through the `request.run()` method
- Company selection should be integrated into the login workflow for multi-company users
- Always implement proper error handling and user feedback for company selection
- Consider caching company lists for improved performance in frequently accessed scenarios
- Implement proper session management when users switch between companies
