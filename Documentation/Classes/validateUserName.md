<!-- Type your summary here -->
# validateUserName Class Documentation

## Overview
The `validateUserName` class is a specialized API client for validating user credentials through the Odyssey API system. This class provides a secure interface to verify username and password combinations, making it essential for authentication workflows and user validation processes.

## Class Information
- **Namespace**: `cs.OdysseyAPI.ValidateUsername`
- **API Endpoint**: `/System/ValidateUsername`
- **Base URL**: `https://api.blinfo.com/metaltech/System/ValidateUsername`
- **HTTP Method**: POST
- **Authentication**: Requires username and password in request body

## Properties

### Core Properties
- `request` (cs.request) - The underlying request object that handles HTTP communication
- `settings` (Object) - Configuration settings object passed to the constructor

## Constructor

```4d
Class constructor($settings : Object)
    $settings.apiURL:="https://api.blinfo.com/metaltech/System/ValidateUsername"
    $settings.apiMethod:="POST"
    This.request:=cs.request.new($settings)
    This.request.validateUsername()
    This.settings:=$settings
```

The constructor automatically configures the API endpoint and HTTP method, creates a request object, and calls the validateUsername endpoint.

### Parameters
- `$settings` (Object) - A settings object, typically `cs.responseSettings.new()` or similar configuration object containing username and password

### Example Usage
```4d
var $settings : Object
var $validateAPI : cs.OdysseyAPI.ValidateUsername

// Create settings object with credentials
$settings:=cs.responseSettings.new()
$settings.Username:="user@example.com"
$settings.Password:="userPassword123"
$settings.CompanyID:="COMP001"

// Initialize validation API client
$validateAPI:=cs.OdysseyAPI.ValidateUsername.new($settings)
```

## Usage Examples

### Basic Username Validation
```4d
var $settings : Object
var $validateAPI : cs.OdysseyAPI.ValidateUsername
var $result : Object

// Initialize settings with user credentials
$settings:=cs.responseSettings.new()
$settings.Username:="john.doe@company.com"
$settings.Password:="SecurePassword123"
$settings.CompanyID:="ACME_CORP"

// Create validation API instance
$validateAPI:=cs.OdysseyAPI.ValidateUsername.new($settings)

// Execute the validation request
$result:=$validateAPI.request.run()

If (Bool($result.Success))
    ALERT("User credentials are valid!")
    // Proceed with user login
    proceedWithLogin($settings.Username)
Else 
    ALERT("Invalid credentials: "+String($result.ErrorMessage))
    // Handle authentication failure
    handleLoginFailure($settings.Username)
End if
```

### Login Function with Validation
```4d
// Comprehensive login function
Function authenticateUser($username : Text; $password : Text; $companyID : Text) : Object
    var $settings : Object
    var $validateAPI : cs.OdysseyAPI.ValidateUsername
    var $authResult : Object
    var $loginStatus : Object
    
    // Initialize authentication result object
    $loginStatus:=New object()
    $loginStatus.success:=False
    $loginStatus.timestamp:=String(Current date; ISO date GMT; Current time)
    $loginStatus.username:=$username
    $loginStatus.companyID:=$companyID
    
    Try
        // Set up validation request
        $settings:=cs.responseSettings.new()
        $settings.Username:=$username
        $settings.Password:=$password
        $settings.CompanyID:=$companyID
        
        // Validate credentials
        $validateAPI:=cs.OdysseyAPI.ValidateUsername.new($settings)
        $authResult:=$validateAPI.request.run()
        
        If (Bool($authResult.Success))
            $loginStatus.success:=True
            $loginStatus.message:="Authentication successful"
            $loginStatus.userID:=$authResult.UserID
            $loginStatus.permissions:=$authResult.Permissions
            
            // Log successful authentication
            logAuthenticationEvent($username; "SUCCESS"; "User authenticated successfully")
            
        Else 
            $loginStatus.message:="Authentication failed: "+String($authResult.ErrorMessage)
            $loginStatus.errorCode:=$authResult.statusCode
            
            // Log failed authentication
            logAuthenticationEvent($username; "FAILED"; $authResult.ErrorMessage)
        End if
        
    Catch
        $loginStatus.message:="Authentication error: "+Last errors[0].message
        $loginStatus.exception:=True
        
        // Log authentication exception
        logAuthenticationEvent($username; "ERROR"; Last errors[0].message)
    End try
    
    return $loginStatus
```

### Secure Login Form Handler
```4d
// Method to handle login form submission
Function handleLoginFormSubmission()
    var $username; $password; $companyID : Text
    var $authResult : Object
    var $maxAttempts : Integer
    var $currentAttempts : Integer
    
    // Get form values
    $username:=Form.username
    $password:=Form.password
    $companyID:=Form.companyID
    $maxAttempts:=3
    
    // Check for empty fields
    If ($username="") || ($password="") || ($companyID="")
        ALERT("Please fill in all required fields")
        return
    End if
    
    // Check login attempt count
    $currentAttempts:=getLoginAttemptCount($username)
    If ($currentAttempts>=$maxAttempts)
        ALERT("Account temporarily locked due to too many failed login attempts")
        return
    End if
    
    // Attempt authentication
    $authResult:=authenticateUser($username; $password; $companyID)
    
    If ($authResult.success)
        // Reset attempt counter
        resetLoginAttemptCount($username)
        
        // Store user session
        storeUserSession($authResult)
        
        // Navigate to main application
        ALERT("Login successful! Welcome "+$username)
        navigateToMainScreen()
        
    Else 
        // Increment attempt counter
        incrementLoginAttemptCount($username)
        
        // Show error message
        ALERT("Login failed: "+$authResult.message)
        
        // Clear password field for security
        Form.password:=""
    End if
```

### Batch User Validation
```4d
// Function to validate multiple users at once
Function validateMultipleUsers($userList : Collection) : Collection
    var $validationResults : Collection
    var $user : Object
    var $authResult : Object
    var $i : Integer
    
    $validationResults:=New collection()
    
    For ($i; 0; $userList.length-1)
        $user:=$userList[$i]
        
        // Validate each user
        $authResult:=authenticateUser($user.username; $user.password; $user.companyID)
        
        // Add result to collection
        $validationResults.push(New object(\
            "username"; $user.username; \
            "companyID"; $user.companyID; \
            "valid"; $authResult.success; \
            "message"; $authResult.message; \
            "timestamp"; $authResult.timestamp))
        
        // Add small delay to avoid overwhelming the API
        DELAY PROCESS(Current process; 100)  // 1 second delay
    End for
    
    return $validationResults
```

### Password Change Validation
```4d
// Function to validate current password before allowing change
Function validateCurrentPassword($username : Text; $currentPassword : Text; $companyID : Text) : Boolean
    var $settings : Object
    var $validateAPI : cs.OdysseyAPI.ValidateUsername
    var $result : Object
    
    // Set up validation request
    $settings:=cs.responseSettings.new()
    $settings.Username:=$username
    $settings.Password:=$currentPassword
    $settings.CompanyID:=$companyID
    
    // Validate current credentials
    $validateAPI:=cs.OdysseyAPI.ValidateUsername.new($settings)
    $result:=$validateAPI.request.run()
    
    If (Bool($result.Success))
        return True
    Else 
        ALERT("Current password is incorrect. Please try again.")
        return False
    End if
```

### Single Sign-On (SSO) Integration
```4d
// Function for SSO token validation
Function validateSSOToken($ssoToken : Text; $companyID : Text) : Object
    var $ssoResult : Object
    var $decodedCredentials : Object
    var $username; $password : Text
    
    $ssoResult:=New object()
    $ssoResult.success:=False
    
    Try
        // Decode SSO token to extract credentials
        $decodedCredentials:=decodeSSOToken($ssoToken)
        $username:=$decodedCredentials.username
        $password:=$decodedCredentials.password
        
        // Validate extracted credentials
        $ssoResult:=authenticateUser($username; $password; $companyID)
        
        If ($ssoResult.success)
            $ssoResult.ssoToken:=$ssoToken
            $ssoResult.authMethod:="SSO"
        End if
        
    Catch
        $ssoResult.message:="Invalid SSO token: "+Last errors[0].message
        $ssoResult.exception:=True
    End try
    
    return $ssoResult
```

### User Session Management
```4d
// Function to validate existing session
Function validateUserSession($sessionToken : Text) : Object
    var $sessionInfo : Object
    var $storedCredentials : Object
    var $validationResult : Object
    
    $sessionInfo:=New object()
    $sessionInfo.valid:=False
    
    // Retrieve stored session credentials
    $storedCredentials:=getStoredSessionCredentials($sessionToken)
    
    If ($storedCredentials#Null)
        // Re-validate credentials to ensure they're still active
        $validationResult:=authenticateUser(\
            $storedCredentials.username; \
            $storedCredentials.password; \
            $storedCredentials.companyID)
        
        If ($validationResult.success)
            $sessionInfo.valid:=True
            $sessionInfo.username:=$storedCredentials.username
            $sessionInfo.companyID:=$storedCredentials.companyID
            $sessionInfo.lastValidated:=String(Current date; ISO date GMT; Current time)
            
            // Update session timestamp
            updateSessionTimestamp($sessionToken)
        Else 
            // Credentials no longer valid, invalidate session
            invalidateSession($sessionToken)
            $sessionInfo.message:="Session expired - credentials no longer valid"
        End if
    Else 
        $sessionInfo.message:="Session not found or expired"
    End if
    
    return $sessionInfo
```

### API Health Check with Validation
```4d
// Function to test API connectivity using validation endpoint
Function testValidationAPIHealth() : Object
    var $settings : Object
    var $validateAPI : cs.OdysseyAPI.ValidateUsername
    var $testCredentials : Object
    var $healthStatus : Object
    var $result : Object
    
    $healthStatus:=New object()
    $healthStatus.endpoint:="/System/ValidateUsername"
    $healthStatus.timestamp:=String(Current date; ISO date GMT; Current time)
    
    // Use test credentials (these should be configured in your system)
    $testCredentials:=getTestCredentials()
    
    Try
        $settings:=cs.responseSettings.new()
        $settings.Username:=$testCredentials.username
        $settings.Password:=$testCredentials.password
        $settings.CompanyID:=$testCredentials.companyID
        
        $validateAPI:=cs.OdysseyAPI.ValidateUsername.new($settings)
        $result:=$validateAPI.request.run()
        
        $healthStatus.accessible:=True
        $healthStatus.responseTime:=$result.responseTime
        $healthStatus.statusCode:=$result.statusCode
        
        If (Bool($result.Success))
            $healthStatus.functional:=True
            $healthStatus.message:="Validation endpoint is working correctly"
        Else 
            $healthStatus.functional:=False
            $healthStatus.message:="Validation endpoint accessible but returned error: "+String($result.ErrorMessage)
        End if
        
    Catch
        $healthStatus.accessible:=False
        $healthStatus.functional:=False
        $healthStatus.message:="Unable to reach validation endpoint: "+Last errors[0].message
    End try
    
    return $healthStatus
```

## Integration Patterns

### Authentication Middleware
```4d
// Middleware function for route protection
Function requireAuthentication($request : Object) : Boolean
    var $sessionToken : Text
    var $sessionValidation : Object
    
    // Extract session token from request
    $sessionToken:=extractSessionToken($request)
    
    If ($sessionToken="")
        // No session token provided
        sendUnauthorizedResponse($request; "No authentication token provided")
        return False
    End if
    
    // Validate session
    $sessionValidation:=validateUserSession($sessionToken)
    
    If ($sessionValidation.valid)
        // Add user info to request context
        $request.user:=New object(\
            "username"; $sessionValidation.username; \
            "companyID"; $sessionValidation.companyID)
        return True
    Else 
        sendUnauthorizedResponse($request; "Invalid or expired session")
        return False
    End if
```

### Login Rate Limiting
```4d
// Function to implement login rate limiting
Function checkLoginRateLimit($username : Text; $ipAddress : Text) : Boolean
    var $userAttempts; $ipAttempts : Integer
    var $timeWindow : Integer
    var $maxAttemptsPerUser; $maxAttemptsPerIP : Integer
    
    $timeWindow:=300  // 5 minutes in seconds
    $maxAttemptsPerUser:=5
    $maxAttemptsPerIP:=20
    
    // Check attempts for this user
    $userAttempts:=getLoginAttemptsInWindow($username; $timeWindow)
    If ($userAttempts>=$maxAttemptsPerUser)
        logSecurityEvent("RATE_LIMIT_USER"; $username; $ipAddress)
        return False
    End if
    
    // Check attempts for this IP
    $ipAttempts:=getLoginAttemptsFromIP($ipAddress; $timeWindow)
    If ($ipAttempts>=$maxAttemptsPerIP)
        logSecurityEvent("RATE_LIMIT_IP"; $username; $ipAddress)
        return False
    End if
    
    return True
```

## Security Considerations

1. **Password Security**: Never log or store passwords in plain text
2. **Rate Limiting**: Implement rate limiting to prevent brute force attacks
3. **Session Management**: Properly manage user sessions and timeouts
4. **Audit Logging**: Log all authentication attempts for security monitoring
5. **Error Handling**: Don't reveal sensitive information in error messages

## Key Features

1. **Secure Authentication**: Validates user credentials through secure API endpoint
2. **Automatic Configuration**: Constructor automatically sets up the correct endpoint and HTTP method
3. **Error Handling**: Built on the robust `cs.request` class with comprehensive error handling
4. **Integration Ready**: Easy to integrate into login forms and authentication workflows
5. **Session Support**: Can be used to validate existing sessions and implement SSO

## Notes

- This class is specifically designed for the Odyssey API system
- The endpoint requires username, password, and company ID in the request body
- Ideal for login forms, session validation, and authentication middleware
- Should be used over secure connections (HTTPS) to protect credentials in transit
- The class automatically calls the validateUsername endpoint during construction
- Results are available through the `request.run()` method
- Consider implementing additional security measures like rate limiting and account lockout
