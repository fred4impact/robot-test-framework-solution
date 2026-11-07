*** Settings ***
# resources/keywords/cart_keywords.robot
# Business-level cart keywords (they combine products page + cart page).

Resource    ../../page_objects/products_page.robot
Resource    ../../page_objects/cart_page.robot

*** Keywords ***

Add Products To Cart
    [Documentation]    Add one or more products by name from the products page
    [Arguments]    @{product_names}
    FOR    ${name}    IN    @{product_names}
        Add Product To Cart By Name    ${name}
    END


Add Products And Open Cart
    [Documentation]    Add products by name, then open the cart page
    [Arguments]    @{product_names}
    Add Products To Cart    @{product_names}
    Go To Shopping Cart
    Cart Page Should Be Displayed


Cart Should Contain Exactly
    [Documentation]    Verify the cart holds exactly these products (order ignored)
    [Arguments]    @{expected_names}
    ${actual_names}=    Get Cart Item Names
    ${expected_count}=    Get Length    ${expected_names}
    Length Should Be    ${actual_names}    ${expected_count}
    ...    msg=Expected ${expected_count} items, cart has: ${actual_names}
    FOR    ${name}    IN    @{expected_names}
        Cart Should Contain Product    ${name}
    END


Cart Badge Should Show
    [Documentation]    Verify the number on the cart icon (0 = no badge shown)
    [Arguments]    ${expected_count}
    Verify Cart Item Count    ${expected_count}
