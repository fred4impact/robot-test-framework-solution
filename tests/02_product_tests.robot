*** Settings ***
# tests/02_product_tests.robot
Documentation     Products (inventory) page: listing, details, sorting, add/remove buttons.

Resource          ../config/settings.robot

Test Setup        User Is Logged In As Standard User
Test Teardown     Test Cleanup
Suite Teardown    Suite Cleanup


*** Test Cases ***

TC201: Inventory Shows All Products
    [Documentation]    The products page lists all 6 products
    [Tags]    products    smoke    high_priority
    Products Page Should Be Loaded
    Product Count Should Be    ${TOTAL_PRODUCT_COUNT}


TC202: Every Product Shows Name Price And Description
    [Documentation]    Each product card has a name, a price and a description
    [Tags]    products    regression
    Verify Product Details Display
    ${count}=    Get Number Of Products
    ${names}=    Get Element Count    ${PRODUCT_NAME}
    ${prices}=    Get Element Count    ${PRODUCT_PRICE}
    ${descriptions}=    Get Element Count    ${PRODUCT_DESCRIPTION}
    Should Be Equal As Integers    ${names}    ${count}
    Should Be Equal As Integers    ${prices}    ${count}
    Should Be Equal As Integers    ${descriptions}    ${count}


TC203: Default Sort Order Is Name A To Z
    [Documentation]    Products are alphabetical when the page first loads
    [Tags]    products    regression    sorting
    Verify Products Sorted A To Z


TC204: Products Can Be Sorted By Every Option
    [Documentation]    DATA-DRIVEN: one row per dropdown option
    [Tags]    products    regression    sorting    data_driven
    [Template]    Products Should Be Sortable By
    za
    lohi
    hilo
    az


TC205: Product Details Page Shows Correct Product
    [Documentation]    Clicking a product name opens its details page; Back returns to the list
    [Tags]    products    regression
    Open Product Details    ${PRODUCT_BACKPACK}
    Product Details Should Show    ${PRODUCT_BACKPACK}    ${PRICE_BACKPACK}
    Go Back To Products
    Product Count Should Be    ${TOTAL_PRODUCT_COUNT}


TC206: Add To Cart Button Toggles To Remove
    [Documentation]    Adding a product turns its button into "Remove" and updates the badge;
    ...    removing it reverses both
    [Tags]    products    smoke    cart
    Cart Badge Should Show    0
    Add Product To Cart By Index    0
    Verify Product Is In Cart    0
    Cart Badge Should Show    1
    Remove Product From Cart By Index    0
    Cart Badge Should Show    0
