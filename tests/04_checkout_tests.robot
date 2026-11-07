*** Settings ***
# tests/04_checkout_tests.robot
Documentation     Checkout flow: information form validation, totals, cancel and order completion.

Resource          ../config/settings.robot

Test Setup        Start Checkout With One Product
Test Teardown     Test Cleanup
Suite Teardown    Suite Cleanup


*** Test Cases ***

TC401: Complete Checkout With One Product
    [Documentation]    Happy path: fill info, review, finish -> confirmation and empty cart
    [Tags]    checkout    smoke    high_priority
    Complete Checkout With Default Information
    Cart Badge Should Show    0


TC402: Order Overview Shows Correct Totals
    [Documentation]    Item total, 8% tax and grand total add up for two products
    [Tags]    checkout    regression    high_priority
    Click Cancel On Checkout                       # back to cart (setup put 1 item in)
    Click Continue Shopping
    Add Products To Cart    ${PRODUCT_BIKE_LIGHT}
    Go To Shopping Cart
    Click Checkout Button
    Submit Checkout Information
    ${count}=    Get Element Count    ${OVERVIEW_ITEM}
    Should Be Equal As Integers    ${count}    2
    Order Totals Should Be Correct


TC403: Checkout Form Requires All Fields
    [Documentation]    DATA-DRIVEN: leaving any field empty shows the matching error
    [Tags]    checkout    regression    negative    data_driven
    [Template]    Checkout Should Fail With Message
    # first name               last name                postal code                 expected error
    ${EMPTY}                   ${CHECKOUT_LAST_NAME}    ${CHECKOUT_POSTAL_CODE}     ${ERROR_FIRST_NAME_REQUIRED}
    ${CHECKOUT_FIRST_NAME}     ${EMPTY}                 ${CHECKOUT_POSTAL_CODE}     ${ERROR_LAST_NAME_REQUIRED}
    ${CHECKOUT_FIRST_NAME}     ${CHECKOUT_LAST_NAME}    ${EMPTY}                    ${ERROR_POSTAL_CODE_REQUIRED}
    ${EMPTY}                   ${EMPTY}                 ${EMPTY}                    ${ERROR_FIRST_NAME_REQUIRED}


TC404: Cancel On Information Page Returns To Cart
    [Documentation]    Cancel on step 1 goes back to the cart with items untouched
    [Tags]    checkout    regression
    Click Cancel On Checkout
    Cart Page Should Be Displayed
    Cart Should Contain Exactly    ${PRODUCT_BACKPACK}


TC405: Cancel On Overview Returns To Products And Keeps Cart
    [Documentation]    Cancel on step 2 goes to the products page; nothing is ordered
    [Tags]    checkout    regression
    Submit Checkout Information
    Click Cancel On Checkout
    Products Page Should Be Loaded
    Cart Badge Should Show    1


TC406: Back Home After Order Shows Products With Empty Cart
    [Documentation]    After finishing, "Back Home" returns to products and the cart is empty
    [Tags]    checkout    regression
    Complete Checkout With Default Information
    Click Back Home
    Products Page Should Be Loaded
    Cart Badge Should Show    0


*** Keywords ***

Start Checkout With One Product
    [Documentation]    Test Setup: log in, add the backpack and open checkout step 1
    User Is Logged In As Standard User
    Start Checkout With Products    ${PRODUCT_BACKPACK}
