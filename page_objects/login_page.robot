*** Settings ***
# page_objects/login_page.robot
# Login page object and login-related keywords

Resource    ../resources/common.robot

*** Variables ***
# Login Page Locators
${LOGIN_CONTAINER}             id:login_button_container
${USERNAME_INPUT}              id:user-name
${PASSWORD_INPUT}              id:password
${LOGIN_BUTTON}                id:login-button
${ERROR_MESSAGE}               css:[data-test='error']
${INVENTORY_CONTAINER}         class:inventory_container
${PRODUCTS_PAGE_HEADER}        class:title

*** Keywords ***

# ============================================================================
# Login Page Actions
# ============================================================================

Navigate To Login Page
    [Documentation]    Navigate to the login page
    Open Application    ${BROWSER}    ${HEADLESS_MODE}
    Wait For Element To Be Visible    ${LOGIN_CONTAINER}
    Log Test Step    Navigated to Login Page


Enter Username
    [Documentation]    Enter username in the username field
    [Arguments]    ${username}
    Log Test Step    Entering username: ${username}
    Clear Field And Type    ${USERNAME_INPUT}    ${username}


Enter Password
    [Documentation]    Enter password in the password field
    [Arguments]    ${password}
    Log Test Step    Entering password
    Clear Field And Type    ${PASSWORD_INPUT}    ${password}


Click Login Button
    [Documentation]    Click the login button
    Log Test Step    Clicking Login button
    Click Element And Wait    ${LOGIN_BUTTON}


Login With Credentials
    [Documentation]    Perform complete login with given credentials
    ...    (Assumes the login page is already open - call "Navigate To Login Page" first.
    ...    Previously this opened a SECOND browser because the tests already navigate.)
    [Arguments]    ${username}    ${password}
    Enter Username    ${username}
    Enter Password    ${password}
    Click Login Button


Login With Valid User
    [Documentation]    Login with standard valid user account
    Log Test Step    Login with valid credentials
    Login With Credentials    ${VALID_USERNAME}    ${VALID_PASSWORD}
    Wait For Products Page


Login With Invalid Credentials
    [Documentation]    Attempt login with invalid username/password
    Log Test Step    Login with invalid credentials
    Login With Credentials    ${INVALID_USERNAME}    ${INVALID_PASSWORD}


Login With Locked Out User
    [Documentation]    Attempt login with locked out user account
    Log Test Step    Login with locked out user
    Login With Credentials    ${LOCKED_OUT_USERNAME}    ${VALID_PASSWORD}


# ============================================================================
# Login Page Verification
# ============================================================================

Login Page Should Be Displayed
    [Documentation]    Verify login page is displayed
    Log Test Step    Verify Login Page is displayed
    Wait For Element To Be Visible    ${LOGIN_CONTAINER}    error=Timeout waiting for login container


Products Page Should Be Displayed
    [Documentation]    Verify products/inventory page is displayed after login
    Log Test Step    Verify Products Page is displayed
    Wait For Element To Be Visible    ${INVENTORY_CONTAINER}    error=Timeout waiting for inventory
    Wait For Element To Be Visible    ${PRODUCTS_PAGE_HEADER}    error=Timeout waiting for page header


Error Message Should Be Displayed
    [Documentation]    Verify error message is displayed on login failure
    Log Test Step    Verify Error message is displayed
    Wait For Element To Be Visible    ${ERROR_MESSAGE}    error=Timeout waiting for error message


Error Message Should Contain Text
    [Documentation]    Verify error message contains specific text
    [Arguments]    ${expected_text}
    Log Test Step    Verify error message contains: ${expected_text}
    Verify Error Message    ${expected_text}    ${ERROR_MESSAGE}


Get Displayed Error Message
    [Documentation]    Get the error message displayed on login page
    ${message}=    Get Error Message    ${ERROR_MESSAGE}
    RETURN    ${message}


# ============================================================================
# Wait Keywords
# ============================================================================

Wait For Products Page
    [Documentation]    Wait for products page to load after successful login
    Wait Until Page Contains Element    ${INVENTORY_CONTAINER}    ${EXPLICIT_WAIT}
    Wait For Page Load


Wait For Login Page
    [Documentation]    Wait for login page to load
    Wait Until Page Contains Element    ${LOGIN_CONTAINER}    ${EXPLICIT_WAIT}


# ============================================================================
# Login State Keywords
# ============================================================================

User Should Be Logged In
    [Documentation]    Verify user is logged in (by checking URL and page elements)
    Verify Current URL Contains    /inventory
    Products Page Should Be Displayed


User Should Not Be Logged In
    [Documentation]    Verify user is not logged in
    Verify Current URL Contains    /
    Login Page Should Be Displayed


Logout User
    [Documentation]    Logout the current user
    Log Test Step    Logging out user
    # Click menu button
    Click Element    id:react-burger-menu-btn
    # Wait for the slide-out menu animation instead of a fixed sleep
    Wait Until Element Is Visible    id:logout_sidebar_link
    Click Element    id:logout_sidebar_link
    Wait For Login Page
    Log    User logged out successfully
