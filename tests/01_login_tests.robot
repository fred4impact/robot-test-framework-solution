*** Settings ***
# tests/01_login_tests.robot
Documentation     Login page tests: valid login, invalid logins, logout and access control.
...
...               Teaching points in this file:
...               - Test Setup / Test Teardown give every test a fresh browser
...               - TC106 is DATA-DRIVEN with [Template]: one keyword, many data rows
...               - TC108 uses Given / When / Then (BDD-style) prefixes, which Robot ignores

Resource          ../config/settings.robot

Test Setup        User Is On Login Page
Test Teardown     Test Cleanup
Suite Teardown    Suite Cleanup


*** Test Cases ***

TC101: Login With Valid Credentials
    [Documentation]    standard_user can log in and lands on the products page
    [Tags]    login    smoke    high_priority
    Enter Username    ${VALID_USERNAME}
    Enter Password    ${VALID_PASSWORD}
    Click Login Button
    User Should Be Logged In
    Element Text Should Be    ${PRODUCTS_PAGE_HEADER}    Products


TC102: Login With Invalid Credentials Shows Error
    [Documentation]    Wrong username/password shows a clear error and stays on login page
    [Tags]    login    regression    negative
    Login With Invalid Credentials
    Error Message Should Be Displayed
    Error Message Should Contain Text    ${ERROR_MESSAGE_USERNAME}
    Location Should Be    ${LOGIN_PAGE_URL}


TC103: Locked Out User Cannot Login
    [Documentation]    locked_out_user gets the "locked out" error
    [Tags]    login    regression    negative
    Login With Locked Out User
    Error Message Should Contain Text    ${ERROR_MESSAGE_LOCKED}
    Location Should Be    ${LOGIN_PAGE_URL}


TC104: Error Message Can Be Dismissed
    [Documentation]    The "X" on the error banner hides the error
    [Tags]    login    regression
    Login With Invalid Credentials
    Error Message Should Be Displayed
    Dismiss Login Error


TC105: Logout Returns To Login Page
    [Documentation]    After logout the user is back on the login page
    [Tags]    login    smoke
    Login With Valid User
    User Should Be Logged In
    Logout User
    Login Page Should Be Displayed
    Location Should Be    ${LOGIN_PAGE_URL}


TC106: Invalid Login Combinations
    [Documentation]    DATA-DRIVEN: each row below calls "Login Should Fail With Message"
    ...    with: username | password | expected error.
    ...    ${EMPTY} means "leave the field blank".
    [Tags]    login    regression    negative    data_driven
    [Template]    Login Should Fail With Message
    # username                 password                expected error
    ${EMPTY}                   ${EMPTY}                ${ERROR_USERNAME_REQUIRED}
    ${EMPTY}                   ${VALID_PASSWORD}       ${ERROR_USERNAME_REQUIRED}
    ${VALID_USERNAME}          ${EMPTY}                ${ERROR_PASSWORD_REQUIRED}
    ${VALID_USERNAME}          ${INVALID_PASSWORD}     ${ERROR_MESSAGE_USERNAME}
    ${INVALID_USERNAME}        ${VALID_PASSWORD}       ${ERROR_MESSAGE_USERNAME}
    ${LOCKED_OUT_USERNAME}     ${VALID_PASSWORD}       ${ERROR_MESSAGE_LOCKED}


TC107: Products Page Requires Login
    [Documentation]    Opening /inventory.html directly without logging in is blocked
    [Tags]    login    regression    security
    Protected Page Should Require Login    ${PRODUCTS_PAGE_URL}


TC108: Logged Out User Cannot Go Back To Products
    [Documentation]    BDD style. Given/When/Then/And are just readable prefixes:
    ...    Robot strips them and runs the keyword that follows.
    [Tags]    login    regression    security
    Given Login With Valid User
    When Logout User
    Then Protected Page Should Require Login    ${PRODUCTS_PAGE_URL}
    And Login Page Should Be Displayed
