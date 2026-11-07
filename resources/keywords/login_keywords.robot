*** Settings ***
# resources/keywords/login_keywords.robot
# Business-level login keywords.
#
# Layering used in this project:
#   tests/            -> WHAT is tested (readable scenarios)
#   resources/keywords -> business steps built from page objects   <- this file
#   page_objects/     -> HOW each page works (locators + clicks)
#   resources/common  -> generic browser / wait / logging helpers

Resource    ../../page_objects/login_page.robot

*** Keywords ***

User Is On Login Page
    [Documentation]    Open the browser on the login page and check it loaded
    Navigate To Login Page
    Login Page Should Be Displayed


User Is Logged In As Standard User
    [Documentation]    Open the browser and log in as standard_user
    User Is On Login Page
    Login With Valid User
    User Should Be Logged In


Login Should Fail With Message
    [Documentation]    Try to log in and expect an error message.
    ...    Reloads the login page first so every attempt starts from empty fields
    ...    (handy for data-driven tests that call this keyword many times).
    [Arguments]    ${username}    ${password}    ${expected_error}
    Go To    ${LOGIN_PAGE_URL}
    Wait For Login Page
    IF    $username    Enter Username    ${username}
    IF    $password    Enter Password    ${password}
    Click Login Button
    Error Message Should Be Displayed
    Error Message Should Contain Text    ${expected_error}
    Location Should Be    ${LOGIN_PAGE_URL}


Dismiss Login Error
    [Documentation]    Close the red error banner with its "X" button
    Click Element    css:[data-test='error-button']
    Wait Until Page Does Not Contain Element    ${ERROR_MESSAGE}


Protected Page Should Require Login
    [Documentation]    Open a page directly without logging in and expect to be sent back
    [Arguments]    ${url}
    Go To    ${url}
    Login Page Should Be Displayed
    Error Message Should Contain Text    ${ERROR_NOT_LOGGED_IN}
