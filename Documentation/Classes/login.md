<!-- Type your summary here -->
# login Class Documentation

## Overview
The `login` class is a specialized API client for user authentication through the Odyssey API system. This class provides a secure interface to authenticate users and establish sessions within specified companies, making it the foundation for secure access to company-specific resources and operations.

## Class Information
- **Namespace**: `cs.OdysseyAPI.Login`
- **API Endpoint**: `/System/Login`
- **Base URL**: `https://api.blinfo.com/metaltech/Login`
- **HTTP Method**: POST
- **Authentication**: Requires username, password, and company ID in request body

## Properties

### Core Properties
- `request` (cs.request) - The underlying request object that handles HTTP communication
- `settings` (Object) - Configuration settings object passed to the constructor

## Constructor

```4d
Class constructor($settings : Object)
    $settings.apiURL:="https://api.blinfo.com/metaltech/Login"
    $settings.apiMethod:="POST"
    This.request:=cs.request.new($settings)
    This.request.login()
    This.settings:=$settings
```

The constructor automatically configures the API endpoint and HTTP method, creates a request object, and calls the login endpoint.

### Parameters
- `$settings` (Object) - A settings object, typically `cs.responseSettings.new()` containing:
  - `Username` (Text) - User login credentials
  - `Password` (Text) - User password
  - `CompanyID` (Text) - Company identifier for multi-tenant access

### Example Usage
```4d
var $settings : Object
var $loginAPI : cs.OdysseyAPI.Login

// Create settings object with login credentials
$settings:=cs.responseSettings.new()
$settings.Username:="dweyrick@company.com"
$settings.Password:="SecurePassword123"
$settings.CompanyID:="ACME_CORP"

// Initialize login API client
$loginAPI:=cs.OdysseyAPI.Login.new($settings)
```

## Usage Examples

### Basic User Login
```4d
var $settings : Object
var $loginAPI : cs.OdysseyAPI.Login
var $result : Object

// Initialize settings with user credentials
$settings:=cs.responseSettings.new()
$settings.Username:="dweyrick@company.com"
$settings.Password:="MySecurePassword"
$settings.CompanyID:="COMP001"

// Create login API instance
$loginAPI:=cs.OdysseyAPI.Login.new($settings)

// Execute the login request
$result:=$loginAPI.request.run()

If (Bool($result.Success))
    ALERT("Login successful! Welcome "+$settings.Username)
    
    // Store session information
    storeUserSession($result.SessionToken; $settings.Username; $settings.CompanyID)
    
    // Navigate to main application
    navigateToMainDashboard()
    
Else 
    ALERT("Login failed: "+String($result.ErrorMessage))
    
    // Handle login failure
    handleLoginFailure($settings.Username; $result.ErrorMessage)
End if
```

### Comprehensive Login Function
```4d
// Function to handle complete login process
Function performUserLogin($username : Text; $password : Text; $companyID : Text) : Object
    var $settings : Object
    var $loginAPI : cs.OdysseyAPI.Login
    var $loginResult : Object
    var $loginStatus : Object
    
    // Initialize login status object
    $loginStatus:=New object()
    $loginStatus.success:=False
    $loginStatus.timestamp:=String(Current date; ISO date GMT; Current time)
    $loginStatus.username:=$username
    $loginStatus.companyID:=$companyID
    $loginStatus.sessionToken:=""
    
    Try
        // Validate input parameters
        If ($username="") || ($password="") || ($companyID="")
            $loginStatus.message:="Username, password, and company ID are required"
            return $loginStatus
        End if
        
        // Check for account lockout
        If (isAccountLocked($username))
            $loginStatus.message:="Account is temporarily locked due to failed login attempts"
            $loginStatus.accountLocked:=True
            return $loginStatus
        End if
        
        // Set up login request
        $settings:=cs.responseSettings.new()
        $settings.Username:=$username
        $settings.Password:=$password
        $settings.CompanyID:=$companyID
        
        // Attempt login
        $loginAPI:=cs.OdysseyAPI.Login.new($settings)
        $loginResult:=$loginAPI.request.run()
        
        If (Bool($loginResult.Success))
            $loginStatus.success:=True
            $loginStatus.message:="Login successful"
            $loginStatus.sessionToken:=$loginResult.SessionToken
            $loginStatus.userID:=$loginResult.UserID
            $loginStatus.permissions:=$loginResult.Permissions
            $loginStatus.sessionExpiry:=$loginResult.SessionExpiry
            
            // Reset failed login attempts
            resetFailedLoginAttempts($username)
            
            // Log successful login
            logLoginEvent($username; $companyID; "SUCCESS"; "User logged in successfully")
            
            // Store session information
            createUserSession($loginStatus)
            
        Else 
            $loginStatus.message:="Login failed: "+String($loginResult.ErrorMessage)
            $loginStatus.errorCode:=$loginResult.statusCode
            
            // Increment failed login attempts
            incrementFailedLoginAttempts($username)
            
            // Log failed login
            logLoginEvent($username; $companyID; "FAILED"; $loginResult.ErrorMessage)
            
            // Check if account should be locked
            checkAndLockAccount($username)
        End if
        
    Catch
        $loginStatus.message:="Login error: "+Last errors[0].message
        $loginStatus.exception:=True
        
        // Log login exception
        logLoginEvent($username; $companyID; "ERROR"; Last errors[0].message)
    End try
    
    return $loginStatus
```

### Login Form Handler
```4d
// Method to handle login form submission
Function handleLoginForm()
    var $username; $password; $companyID : Text
    var $loginResult : Object
    var $rememberMe : Boolean
    
    // Get form values
    $username:=Form.username
    $password:=Form.password
    $companyID:=Form.companyID
    $rememberMe:=Form.rememberMe
    
    // Validate form inputs
    If ($username="")
        ALERT("Please enter your username")
        GOTO OBJECT(Form.username)
        return
    End if
    
    If ($password="")
        ALERT("Please enter your password")
        GOTO OBJECT(Form.password)
        return
    End if
    
    If ($companyID="")
        ALERT("Please select a company")
        GOTO OBJECT(Form.companyID)
        return
    End if
    
    // Show loading indicator
    Form.loginInProgress:=True
    OBJECT SET ENABLED(Form.loginButton; False)
    
    // Attempt login
    $loginResult:=performUserLogin($username; $password; $companyID)
    
    If ($loginResult.success)
        // Handle remember me option
        If ($rememberMe)
            storeRememberedCredentials($username; $companyID)
        End if
        
        // Store user preferences
        storeUserPreferences($loginResult.userID; Form.language; Form.theme)
        
        // Close login form and open main application
        CANCEL
        openMainApplication($loginResult)
        
    Else 
        // Show error message
        ALERT($loginResult.message)
        
        // Clear password field for security
        Form.password:=""
        GOTO OBJECT(Form.password)
        
        // Handle account lockout
        If ($loginResult.accountLocked)
            showAccountLockoutDialog($username)
        End if
    End if
    
    // Hide loading indicator
    Form.loginInProgress:=False
    OBJECT SET ENABLED(Form.loginButton; True)
```

### Single Sign-On Integration
```4d
// Function to handle SSO login process
Function performSSOLogin($ssoToken : Text; $companyID : Text) : Object
    var $ssoCredentials : Object
    var $loginResult : Object
    var $ssoStatus : Object
    
    $ssoStatus:=New object()
    $ssoStatus.success:=False
    $ssoStatus.authMethod:="SSO"
    
    Try
        // Validate and decode SSO token
        $ssoCredentials:=validateAndDecodeSSOToken($ssoToken)
        
        If ($ssoCredentials.valid)
            // Use decoded credentials for login
            $loginResult:=performUserLogin(\
                $ssoCredentials.username; \
                $ssoCredentials.password; \
                $companyID)
            
            If ($loginResult.success)
                $ssoStatus.success:=True
                $ssoStatus.message:="SSO login successful"
                $ssoStatus.sessionToken:=$loginResult.sessionToken
                $ssoStatus.userID:=$loginResult.userID
                $ssoStatus.ssoToken:=$ssoToken
                
                // Log SSO login
                logLoginEvent($ssoCredentials.username; $companyID; "SSO_SUCCESS"; "SSO login successful")
                
            Else 
                $ssoStatus.message:="SSO login failed: "+$loginResult.message
                logLoginEvent($ssoCredentials.username; $companyID; "SSO_FAILED"; $loginResult.message)
            End if
            
        Else 
            $ssoStatus.message:="Invalid SSO token"
            logLoginEvent("UNKNOWN"; $companyID; "SSO_INVALID_TOKEN"; "Invalid SSO token provided")
        End if
        
    Catch
        $ssoStatus.message:="SSO login error: "+Last errors[0].message
        $ssoStatus.exception:=True
    End try
    
    return $ssoStatus
```

### Multi-Company Login
```4d
// Function to handle login across multiple companies
Function performMultiCompanyLogin($username : Text; $password : Text; $companyList : Collection) : Object
    var $multiLoginResult : Object
    var $company : Object
    var $loginAttempt : Object
    var $successfulLogins : Collection
    var $failedLogins : Collection
    var $i : Integer
    
    $multiLoginResult:=New object()
    $successfulLogins:=New collection()
    $failedLogins:=New collection()
    
    For ($i; 0; $companyList.length-1)
        $company:=$companyList[$i]
        
        // Attempt login for each company
        $loginAttempt:=performUserLogin($username; $password; $company.CompanyID)
        
        If ($loginAttempt.success)
            $loginAttempt.companyName:=$company.Name
            $successfulLogins.push($loginAttempt)
        Else 
            $loginAttempt.companyID:=$company.CompanyID
            $loginAttempt.companyName:=$company.Name
            $failedLogins.push($loginAttempt)
        End if
        
        // Add delay between attempts
        DELAY PROCESS(Current process; 100)  // 1 second delay
    End for
    
    $multiLoginResult.totalAttempts:=$companyList.length
    $multiLoginResult.successfulLogins:=$successfulLogins
    $multiLoginResult.failedLogins:=$failedLogins
    $multiLoginResult.successCount:=$successfulLogins.length
    $multiLoginResult.failureCount:=$failedLogins.length
    
    return $multiLoginResult
```

### Session Renewal
```4d
// Function to renew existing session
Function renewUserSession($sessionToken : Text; $username : Text; $companyID : Text) : Object
    var $renewalResult : Object
    var $currentSession : Object
    var $newLogin : Object
    
    $renewalResult:=New object()
    $renewalResult.renewed:=False
    
    // Get current session information
    $currentSession:=getSessionInfo($sessionToken)
    
    If ($currentSession#Null)
        // Check if session is still valid but expiring soon
        If (isSessionExpiringSoon($currentSession))
            // Attempt to renew by performing a fresh login
            $newLogin:=performUserLogin($username; $currentSession.password; $companyID)
            
            If ($newLogin.success)
                // Update session with new token
                updateSession($sessionToken; $newLogin.sessionToken; $newLogin.sessionExpiry)
                
                $renewalResult.renewed:=True
                $renewalResult.newSessionToken:=$newLogin.sessionToken
                $renewalResult.newExpiry:=$newLogin.sessionExpiry
                $renewalResult.message:="Session renewed successfully"
                
                logSessionEvent($username; $companyID; "SESSION_RENEWED"; "Session automatically renewed")
            Else 
                $renewalResult.message:="Session renewal failed: "+$newLogin.message
                logSessionEvent($username; $companyID; "RENEWAL_FAILED"; $newLogin.message)
            End if
        Else 
            $renewalResult.message:="Session does not require renewal"
        End if
    Else 
        $renewalResult.message:="Session not found"
    End if
    
    return $renewalResult
```

### Automated Login for Services
```4d
// Function for service account login
Function performServiceLogin($serviceAccount : Text; $serviceKey : Text; $companyID : Text) : Object
    var $serviceLogin : Object
    var $settings : Object
    var $loginAPI : cs.OdysseyAPI.Login
    var $result : Object
    
    $serviceLogin:=New object()
    $serviceLogin.success:=False
    $serviceLogin.serviceAccount:=$serviceAccount
    $serviceLogin.timestamp:=String(Current date; ISO date GMT; Current time)
    
    Try
        // Set up service login request
        $settings:=cs.responseSettings.new()
        $settings.Username:=$serviceAccount
        $settings.Password:=$serviceKey
        $settings.CompanyID:=$companyID
        
        // Attempt service login
        $loginAPI:=cs.OdysseyAPI.Login.new($settings)
        $result:=$loginAPI.request.run()
        
        If (Bool($result.Success))
            $serviceLogin.success:=True
            $serviceLogin.sessionToken:=$result.SessionToken
            $serviceLogin.message:="Service login successful"
            
            // Store service session
            storeServiceSession($serviceAccount; $companyID; $result.SessionToken)
            
            // Log service login
            logServiceLogin($serviceAccount; $companyID; "SUCCESS")
            
        Else 
            $serviceLogin.message:="Service login failed: "+String($result.ErrorMessage)
            logServiceLogin($serviceAccount; $companyID; "FAILED"; $result.ErrorMessage)
        End if
        
    Catch
        $serviceLogin.message:="Service login error: "+Last errors[0].message
        $serviceLogin.exception:=True
        logServiceLogin($serviceAccount; $companyID; "ERROR"; Last errors[0].message)
    End try
    
    return $serviceLogin
```

### Login Analytics and Monitoring
```4d
// Function to track login patterns and analytics
Function trackLoginAnalytics($loginResult : Object)
    var $analytics : Object
    var $loginTime : Text
    var $deviceInfo : Object
    
    $analytics:=New object()
    $analytics.timestamp:=String(Current date; ISO date GMT; Current time)
    $analytics.username:=$loginResult.username
    $analytics.companyID:=$loginResult.companyID
    $analytics.success:=$loginResult.success
    $analytics.sessionToken:=$loginResult.sessionToken
    
    // Capture device and browser information
    $deviceInfo:=getDeviceInfo()
    $analytics.device:=$deviceInfo
    
    // Calculate login duration (if tracking form display time)
    $analytics.loginDuration:=calculateLoginDuration()
    
    // Track login location (if available)
    $analytics.location:=getUserLocation()
    
    // Store analytics data
    storeLoginAnalytics($analytics)
    
    // Update user login statistics
    updateUserLoginStats($loginResult.username; $loginResult.success)
    
    // Check for suspicious login patterns
    If (detectSuspiciousLogin($analytics))
        flagSuspiciousActivity($loginResult.username; $analytics)
    End if
```

## Integration Patterns

### Authentication Middleware
```4d
// Middleware for protecting application routes
Function requireLogin($request : Object) : Boolean
    var $sessionToken : Text
    var $sessionValid : Boolean
    
    // Extract session token from request
    $sessionToken:=extractSessionFromRequest($request)
    
    If ($sessionToken="")
        redirectToLogin($request; "No active session")
        return False
    End if
    
    // Validate session
    $sessionValid:=validateSession($sessionToken)
    
    If ($sessionValid)
        // Attach user context to request
        $request.user:=getSessionUser($sessionToken)
        return True
    Else 
        redirectToLogin($request; "Session expired")
        return False
    End if
```

### Application Startup Login
```4d
// Function to handle application startup authentication
Function handleStartupAuthentication() : Boolean
    var $savedSession : Object
    var $autoLogin : Boolean
    var $loginResult : Object
    
    // Check for saved session
    $savedSession:=getSavedSession()
    
    If ($savedSession#Null)
        // Validate saved session
        If (validateSession($savedSession.sessionToken))
            // Session still valid, use it
            setCurrentUser($savedSession)
            return True
        Else 
            // Session expired, clear it
            clearSavedSession()
        End if
    End if
    
    // Check for auto-login credentials
    $autoLogin:=getAutoLoginPreference()
    
    If ($autoLogin)
        var $credentials : Object
        $credentials:=getStoredCredentials()
        
        If ($credentials#Null)
            // Attempt auto-login
            $loginResult:=performUserLogin(\
                $credentials.username; \
                $credentials.password; \
                $credentials.companyID)
            
            If ($loginResult.success)
                setCurrentUser($loginResult)
                return True
            End if
        End if
    End if
    
    // Show login form
    showLoginForm()
    return False
```

## Security Considerations

1. **Password Security**: Never store passwords in plain text or log them
2. **Session Management**: Implement secure session tokens with appropriate expiry
3. **Account Lockout**: Implement account lockout after failed login attempts
4. **Audit Logging**: Log all login attempts for security monitoring
5. **Rate Limiting**: Implement rate limiting to prevent brute force attacks
6. **Multi-Factor Authentication**: Consider implementing MFA for enhanced security
7. **Session Timeout**: Implement automatic session timeout for inactive users

## Key Features

1. **Secure Authentication**: Validates user credentials through secure API endpoint
2. **Company-Specific Access**: Supports multi-tenant architecture with company-specific logins
3. **Session Management**: Provides session tokens for maintaining authenticated state
4. **Error Handling**: Comprehensive error reporting for failed authentication attempts
5. **Integration Ready**: Easy integration with login forms and authentication workflows
6. **Service Account Support**: Can be used for automated service authentication

## Notes

- This class is specifically designed for the Odyssey API system
- The endpoint requires username, password, and company ID in the request body
- Returns session tokens and user information upon successful authentication
- Should be used over secure connections (HTTPS) to protect credentials in transit
- The class automatically calls the login endpoint during construction
- Results are available through the `request.run()` method
- Consider implementing additional security measures like MFA and session monitoring
- Session tokens should be stored securely and have appropriate expiry times
