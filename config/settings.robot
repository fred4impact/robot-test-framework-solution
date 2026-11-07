*** Settings ***
# config/settings.robot
# ONE import for test suites. A test file only needs:
#
#     Resource    ../config/settings.robot
#
# and gets every library, variable, page object and business keyword.
Documentation     Shared imports and suite/test lifecycle keywords.

Resource    ../resources/common.robot
Resource    ../resources/variables.robot
Resource    ../resources/keywords/login_keywords.robot
Resource    ../resources/keywords/product_keywords.robot
Resource    ../resources/keywords/cart_keywords.robot
Resource    ../resources/keywords/checkout_keywords.robot

*** Keywords ***

Test Cleanup
    [Documentation]    Standard Test Teardown: screenshot on failure, then close the browser.
    ...    Teardowns keep running even if one step fails, so the browser always closes.
    # Test names contain ':' and spaces - make a filename-safe version
    ${safe_name}=    Evaluate    re.sub(r'[^A-Za-z0-9_-]+', '_', $TEST_NAME)    modules=re
    Run Keyword If Test Failed    Take Screenshot With Name    FAILED_${safe_name}
    Close Application


Suite Cleanup
    [Documentation]    Standard Suite Teardown: make sure no browser is left open
    Close Application
