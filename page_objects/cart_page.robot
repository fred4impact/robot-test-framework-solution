*** Settings ***
# page_objects/cart_page.robot
# Shopping cart page (/cart.html) - locators and low-level page actions.
#
# Page Object rule of thumb: this file knows HOW the page is built
# (locators, clicks). It does not know about test scenarios.

Resource    ../resources/common.robot

*** Variables ***
# Cart Page Locators
${CART_LIST}                   class:cart_list
${CART_ITEM}                   class:cart_item
${CART_ITEM_NAME}              css:.cart_item .inventory_item_name
${CART_ITEM_PRICE}             css:.cart_item .inventory_item_price
${CART_ITEM_QUANTITY}          css:.cart_item .cart_quantity
${CONTINUE_SHOPPING_BUTTON}    id:continue-shopping
${CHECKOUT_BUTTON}             id:checkout
${CART_PAGE_TITLE}             class:title

*** Keywords ***

# ============================================================================
# Cart Page Verification
# ============================================================================

Cart Page Should Be Displayed
    [Documentation]    Verify the shopping cart page is open
    Wait Until Location Contains    /cart.html
    Wait For Element To Be Visible    ${CART_LIST}
    Element Text Should Be    ${CART_PAGE_TITLE}    Your Cart


Get Number Of Items On Cart Page
    [Documentation]    Count the item rows listed on the cart page
    ...    (Different from "Get Cart Item Count", which reads the header badge.)
    ${count}=    Get Element Count    ${CART_ITEM}
    RETURN    ${count}


Get Cart Item Names
    [Documentation]    Return the names of all items in the cart, in display order
    ${elements}=    Get WebElements    ${CART_ITEM_NAME}
    ${names}=    Create List
    FOR    ${element}    IN    @{elements}
        ${name}=    Get Text    ${element}
        Append To List    ${names}    ${name}
    END
    RETURN    ${names}


Get Cart Item Prices
    [Documentation]    Return the prices of all items in the cart as numbers
    ${elements}=    Get WebElements    ${CART_ITEM_PRICE}
    ${prices}=    Create List
    FOR    ${element}    IN    @{elements}
        ${text}=    Get Text    ${element}
        ${price}=    Convert To Number    ${text.replace('$', '')}
        Append To List    ${prices}    ${price}
    END
    RETURN    ${prices}


Get Cart Item Price By Name
    [Documentation]    Return the price (number) of one item in the cart
    [Arguments]    ${product_name}
    ${text}=    Get Text
    ...    xpath://div[@class='cart_item'][.//div[contains(@class,'inventory_item_name')][normalize-space()="${product_name}"]]//div[contains(@class,'inventory_item_price')]
    ${price}=    Convert To Number    ${text.replace('$', '')}
    RETURN    ${price}


Cart Should Contain Product
    [Documentation]    Verify a product is listed in the cart
    [Arguments]    ${product_name}
    ${names}=    Get Cart Item Names
    List Should Contain Value    ${names}    ${product_name}
    ...    msg=Expected '${product_name}' in cart, but cart has: ${names}


Cart Should Not Contain Product
    [Documentation]    Verify a product is NOT listed in the cart
    [Arguments]    ${product_name}
    ${names}=    Get Cart Item Names
    List Should Not Contain Value    ${names}    ${product_name}
    ...    msg=Did not expect '${product_name}' in cart


Cart Should Be Empty
    [Documentation]    Verify there are no items in the cart
    ${count}=    Get Number Of Items On Cart Page
    Should Be Equal As Integers    ${count}    0    Cart is not empty


Every Cart Item Should Have Quantity One
    [Documentation]    SauceDemo always adds quantity 1 per product
    ${elements}=    Get WebElements    ${CART_ITEM_QUANTITY}
    FOR    ${element}    IN    @{elements}
        Element Text Should Be    ${element}    1
    END


# ============================================================================
# Cart Page Actions
# ============================================================================

Remove Product From Cart Page
    [Documentation]    Click "Remove" for a product on the cart page
    [Arguments]    ${product_name}
    Log Test Step    Removing '${product_name}' from cart page
    Click Element
    ...    xpath://div[@class='cart_item'][.//div[contains(@class,'inventory_item_name')][normalize-space()="${product_name}"]]//button[contains(@data-test,'remove')]


Click Continue Shopping
    [Documentation]    Return from the cart to the products page
    Click Element    ${CONTINUE_SHOPPING_BUTTON}
    Wait Until Location Contains    /inventory.html
    Wait For Element To Be Visible    class:inventory_list


Click Checkout Button
    [Documentation]    Start checkout from the cart page
    Click Element    ${CHECKOUT_BUTTON}
    Wait Until Location Contains    /checkout-step-one.html
    Wait For Element To Be Visible    id:first-name
