*** Settings ***
# resources/keywords/checkout_keywords.robot
# Business-level checkout keywords.

Resource    cart_keywords.robot
Resource    ../../page_objects/checkout_page.robot

*** Keywords ***

Start Checkout With Products
    [Documentation]    Add products, open the cart and click Checkout
    [Arguments]    @{product_names}
    Add Products And Open Cart    @{product_names}
    Click Checkout Button
    Checkout Information Page Should Be Displayed


Submit Checkout Information
    [Documentation]    Fill the information form and continue to the overview
    [Arguments]    ${first_name}=${CHECKOUT_FIRST_NAME}
    ...            ${last_name}=${CHECKOUT_LAST_NAME}
    ...            ${postal_code}=${CHECKOUT_POSTAL_CODE}
    Enter Checkout Information    ${first_name}    ${last_name}    ${postal_code}
    Click Continue On Checkout
    Checkout Overview Page Should Be Displayed


Finish Order
    [Documentation]    Place the order from the overview page and verify it succeeded
    Click Finish
    Order Complete Page Should Be Displayed


Complete Checkout With Default Information
    [Documentation]    From step 1: fill the form with the default test data and place the order
    Submit Checkout Information
    Finish Order


Checkout Should Fail With Message
    [Documentation]    Submit the form with the given data and expect a validation error.
    ...    Reloads step 1 first so each data-driven row starts with an empty form.
    [Arguments]    ${first_name}    ${last_name}    ${postal_code}    ${expected_error}
    Go To    ${CHECKOUT_STEP_ONE_URL}
    Checkout Information Page Should Be Displayed
    Enter Checkout Information    ${first_name}    ${last_name}    ${postal_code}
    Click Continue On Checkout
    Checkout Error Should Contain    ${expected_error}
    Location Should Contain    /checkout-step-one.html
