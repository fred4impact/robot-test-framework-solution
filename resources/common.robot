*** Settings ***
# resources/common.robot
# Common keywords used across all test suites
#
# NOTE: variables.robot must be imported BEFORE SeleniumLibrary, because the
# library import uses ${IMPLICIT_WAIT} / ${EXPLICIT_WAIT} from that file.

Resource   variables.robot
Library    SeleniumLibrary    timeout=${EXPLICIT_WAIT}    implicit_wait=0
Library    Collections
Library    String
Library    DateTime
Library    OperatingSystem

*** Keywords ***

# ============================================================================
# Browser Setup & Teardown
# ============================================================================

Open Application
    [Documentation]    Open the Swag Labs application in the specified browser
    [Arguments]    ${browser}=${BROWSER}    ${headless}=${HEADLESS_MODE}

    Log    Opening ${browser} browser (Headless: ${headless})

    IF    '${browser}' == 'chrome'
        ${options}=    Evaluate    selenium.webdriver.ChromeOptions()    modules=selenium.webdriver
        IF    ${headless}
            Call Method    ${options}    add_argument    --headless\=new
        END
        Call Method    ${options}    add_argument    --disable-blink-features\=AutomationControlled
        # Stop Chrome's "change your password" / save-password popups (SauceDemo uses a leaked demo password)
        ${prefs}=    Create Dictionary
        ...    credentials_enable_service=${False}
        ...    profile.password_manager_enabled=${False}
        ...    profile.password_manager_leak_detection=${False}
        Call Method    ${options}    add_experimental_option    prefs    ${prefs}
        Open Browser    ${BASE_URL}    ${browser}    options=${options}
    ELSE IF    '${browser}' == 'firefox'
        ${options}=    Evaluate    selenium.webdriver.FirefoxOptions()    modules=selenium.webdriver
        IF    ${headless}
            Call Method    ${options}    add_argument    --headless
        END
        Open Browser    ${BASE_URL}    ${browser}    options=${options}
    ELSE
        Open Browser    ${BASE_URL}    ${browser}
    END

    Set Window Size    ${WINDOW_WIDTH}    ${WINDOW_HEIGHT}
    Wait For Page Load
    Log    Application opened successfully


Close Application
    [Documentation]    Close the browser and clean up
    Log    Closing application
    Close All Browsers


Reload Current Page
    [Documentation]    Reload the current page
    ...    (Renamed: a user keyword called "Reload Page" would call itself forever
    ...    instead of SeleniumLibrary's "Reload Page".)
    Log    Reloading page
    SeleniumLibrary.Reload Page
    Wait For Page Load


# ============================================================================
# Wait & Visibility Keywords
# ============================================================================

Wait For Page Load
    [Documentation]    Wait for page to load completely
    Wait For Condition    return document.readyState == 'complete'    ${EXPLICIT_WAIT}


Wait For Element To Be Visible
    [Documentation]    Wait for element to become visible
    [Arguments]    ${locator}    ${timeout}=${EXPLICIT_WAIT}    ${error}=${None}
    Wait Until Element Is Visible    ${locator}    ${timeout}    ${error}


Wait For Element To Be Hidden
    [Documentation]    Wait for element to become invisible
    [Arguments]    ${locator}    ${timeout}=${EXPLICIT_WAIT}
    Wait Until Element Is Not Visible    ${locator}    ${timeout}


Wait For Element To Exist
    [Documentation]    Wait for element to exist in DOM
    [Arguments]    ${locator}    ${timeout}=${EXPLICIT_WAIT}
    Wait Until Page Contains Element    ${locator}    ${timeout}


# ============================================================================
# Element Interaction Keywords
# ============================================================================

Click Element And Wait
    [Documentation]    Click an element and wait for page load
    [Arguments]    ${locator}
    Log    Clicking element: ${locator}
    Click Element    ${locator}
    Wait For Page Load


Type Text Slowly
    [Documentation]    Type text with character-by-character delay
    [Arguments]    ${locator}    ${text}    ${delay}=0.05
    Log    Typing text: ${text}
    Clear Element Text    ${locator}
    ${chars}=    Split String To Characters    ${text}
    FOR    ${char}    IN    @{chars}
        Press Keys    ${locator}    ${char}
        Sleep    ${delay}
    END


Clear Field And Type
    [Documentation]    Clear a field and type new text
    [Arguments]    ${locator}    ${text}
    Log    Clearing field and typing: ${text}
    Clear Element Text    ${locator}
    Input Text    ${locator}    ${text}


Scroll To Element
    [Documentation]    Scroll to element and make it visible
    [Arguments]    ${locator}
    Log    Scrolling to element: ${locator}
    Scroll Element Into View    ${locator}


# ============================================================================
# Verification Keywords
# (Renamed from "Element Should Be Visible" / "Element Should Not Be Visible":
#  user keywords with the same name as a library keyword hide the library one,
#  and the "Not Visible" version called itself in an endless loop.)
# ============================================================================

Verify Element Is Visible
    [Documentation]    Verify element is visible
    [Arguments]    ${locator}    ${message}=${EMPTY}
    Wait For Element To Be Visible    ${locator}
    IF    '${message}' != ''    Log    ${message}


Verify Element Is Not Visible
    [Documentation]    Verify element is not visible
    [Arguments]    ${locator}    ${message}=${EMPTY}
    SeleniumLibrary.Element Should Not Be Visible    ${locator}
    IF    '${message}' != ''    Log    ${message}


Element Text Should Contain
    [Documentation]    Verify element text contains expected value
    [Arguments]    ${locator}    ${expected_text}    ${message}=${None}
    ${actual_text}=    Get Text    ${locator}
    Should Contain    ${actual_text}    ${expected_text}    msg=${message}


Verify Page Title
    [Documentation]    Verify current page title
    [Arguments]    ${expected_title}
    Title Should Be    ${expected_title}


Verify Current URL Contains
    [Documentation]    Verify current URL contains expected text
    [Arguments]    ${expected_url_part}
    Location Should Contain    ${expected_url_part}


# ============================================================================
# Screenshot & Logging Keywords
# ============================================================================

Take Screenshot With Name
    [Documentation]    Take a screenshot with a descriptive name
    [Arguments]    ${name}
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    Capture Page Screenshot    ${SCREENSHOT_DIR}${name}_${timestamp}.png
    Log    Screenshot saved: ${name}_${timestamp}.png


Log Test Step
    [Documentation]    Log a test step with formatting
    [Arguments]    ${step_description}
    ${line}=    Evaluate    '=' * 70
    Log    ${line}    console=True
    Log    STEP: ${step_description}    console=True


Log Test Information
    [Documentation]    Log useful test information
    [Arguments]    ${info_label}    ${info_value}
    Log    ${info_label}: ${info_value}


# ============================================================================
# Error Handling Keywords
# ============================================================================

Handle Test Failure
    [Documentation]    Handle test failure - take screenshot and log details
    [Arguments]    ${error_message}=${EMPTY}
    Log    Test failed!    level=ERROR
    IF    '${error_message}' != ''    Log    Error: ${error_message}    level=ERROR
    Take Screenshot With Name    FAILURE


Get Error Message
    [Documentation]    Get error message from page
    [Arguments]    ${error_locator}
    Wait For Element To Be Visible    ${error_locator}
    ${error_text}=    Get Text    ${error_locator}
    Log    Error message: ${error_text}
    RETURN    ${error_text}


# ============================================================================
# Assertion Helper Keywords
# ============================================================================

Verify Success Message
    [Documentation]    Verify success message is displayed
    [Arguments]    ${expected_message}    ${message_locator}
    Wait For Element To Be Visible    ${message_locator}
    Element Text Should Contain    ${message_locator}    ${expected_message}    Success message verified


Verify Error Message
    [Documentation]    Verify error message is displayed
    [Arguments]    ${expected_error}    ${error_locator}
    ${actual_error}=    Get Error Message    ${error_locator}
    Should Contain    ${actual_error}    ${expected_error}    Error message not as expected
