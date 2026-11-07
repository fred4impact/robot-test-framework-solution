*** Settings ***
# tests/03_shopping_cart_tests.robot
Documentation     Shopping cart: empty cart, adding, removing, prices and navigation.

Resource          ../config/settings.robot

Test Setup        User Is Logged In As Standard User
Test Teardown     Test Cleanup
Suite Teardown    Suite Cleanup


*** Test Cases ***

TC301: New User Has An Empty Cart
    [Documentation]    A fresh session starts with no badge and no cart items
    [Tags]    cart    smoke
    Cart Badge Should Show    0
    Go To Shopping Cart
    Cart Page Should Be Displayed
    Cart Should Be Empty


TC302: Added Product Appears In Cart With Correct Price
    [Documentation]    The cart shows the product that was added, at the same price
    [Tags]    cart    smoke    high_priority
    Add Products And Open Cart    ${PRODUCT_BACKPACK}
    Cart Should Contain Exactly    ${PRODUCT_BACKPACK}
    ${price}=    Get Cart Item Price By Name    ${PRODUCT_BACKPACK}
    Should Be Equal As Numbers    ${price}    ${PRICE_BACKPACK}


TC303: Multiple Products Can Be Added
    [Documentation]    Three products added -> badge shows 3, cart lists all three, each quantity 1
    [Tags]    cart    regression
    Add Products And Open Cart    ${PRODUCT_BACKPACK}    ${PRODUCT_BIKE_LIGHT}    ${PRODUCT_BOLT_TSHIRT}
    Cart Badge Should Show    3
    Cart Should Contain Exactly    ${PRODUCT_BACKPACK}    ${PRODUCT_BIKE_LIGHT}    ${PRODUCT_BOLT_TSHIRT}
    Every Cart Item Should Have Quantity One


TC304: Product Can Be Removed From Cart Page
    [Documentation]    Removing one item on the cart page updates the list and the badge
    [Tags]    cart    regression
    Add Products And Open Cart    ${PRODUCT_BACKPACK}    ${PRODUCT_BIKE_LIGHT}
    Remove Product From Cart Page    ${PRODUCT_BACKPACK}
    Cart Should Not Contain Product    ${PRODUCT_BACKPACK}
    Cart Should Contain Exactly    ${PRODUCT_BIKE_LIGHT}
    Cart Badge Should Show    1


TC305: Continue Shopping Keeps Cart Contents
    [Documentation]    Going back to products and adding more keeps earlier items
    [Tags]    cart    regression
    Add Products And Open Cart    ${PRODUCT_BACKPACK}
    Click Continue Shopping
    Products Page Should Be Loaded
    Add Products And Open Cart    ${PRODUCT_FLEECE_JACKET}
    Cart Should Contain Exactly    ${PRODUCT_BACKPACK}    ${PRODUCT_FLEECE_JACKET}
    Cart Badge Should Show    2


TC306: Cart Contents Survive A Page Reload
    [Documentation]    The cart is kept by the browser, so a reload does not empty it
    [Tags]    cart    regression
    Add Products And Open Cart    ${PRODUCT_BIKE_LIGHT}
    Reload Current Page
    Cart Should Contain Exactly    ${PRODUCT_BIKE_LIGHT}
    Cart Badge Should Show    1
