*** Settings ***
# page_objects/products_page.robot
# Products/Inventory page object and keywords

Resource    ../resources/common.robot

*** Variables ***
# Products Page Locators
${INVENTORY_CONTAINER}         class:inventory_container
${INVENTORY_ITEM}              class:inventory_item
${PRODUCT_NAME}                class:inventory_item_name
${PRODUCT_PRICE}               class:inventory_item_price
${PRODUCT_DESCRIPTION}         class:inventory_item_desc
${ADD_TO_CART_BUTTON}          css:button[data-test*='add-to-cart']
${REMOVE_FROM_CART_BUTTON}     css:button[data-test*='remove']
${SORT_DROPDOWN}               class:product_sort_container
${CART_ICON}                   id:shopping_cart_container
${CART_BADGE}                  class:shopping_cart_badge
${MENU_BUTTON}                 id:react-burger-menu-btn
${PAGE_TITLE}                  class:title


*** Keywords ***

# ============================================================================
# Product Browsing Keywords
# ============================================================================

Products Page Should Be Loaded
    [Documentation]    Verify products page is fully loaded
    Log Test Step    Verify Products Page is loaded
    Wait For Element To Be Visible    ${INVENTORY_CONTAINER}
    Wait For Page Load


Get Number Of Products
    [Documentation]    Get the count of products displayed on the page
    ${count}=    Get Element Count    ${INVENTORY_ITEM}
    RETURN    ${count}


Get All Product Names
    [Documentation]    Get list of all product names on the page (in display order)
    ${name_elements}=    Get WebElements    ${PRODUCT_NAME}
    ${product_names}=    Create List
    FOR    ${element}    IN    @{name_elements}
        ${name}=    Get Text    ${element}
        Append To List    ${product_names}    ${name}
    END
    ${count}=    Get Length    ${product_names}
    Log    Found ${count} products: ${product_names}
    RETURN    ${product_names}


Get All Product Prices
    [Documentation]    Get list of all product prices as NUMBERS (floats).
    ...    Comparing prices as strings sorts "15.99" before "7.99", which is wrong.
    ${price_elements}=    Get WebElements    ${PRODUCT_PRICE}
    ${prices}=    Create List
    FOR    ${element}    IN    @{price_elements}
        ${price_text}=    Get Text    ${element}
        ${price}=    Convert To Number    ${price_text.replace('$', '')}
        Append To List    ${prices}    ${price}
    END
    Log    Extracted prices: ${prices}
    RETURN    ${prices}


Verify Product Count Greater Than Zero
    [Documentation]    Verify at least one product is displayed
    ${count}=    Get Element Count    ${INVENTORY_ITEM}
    Should Be True    ${count} > 0    No products found on the page


Verify Product Details Display
    [Documentation]    Verify product details (name, price, description) are visible
    Log Test Step    Verifying product details display
    Verify Element Is Visible    ${PRODUCT_NAME}
    Verify Element Is Visible    ${PRODUCT_PRICE}
    Verify Element Is Visible    ${PRODUCT_DESCRIPTION}


# ============================================================================
# Product Selection & Cart Addition Keywords
# ============================================================================

Get Product Locator By Index
    [Documentation]    Return an XPath locator for the product card at a 0-based index
    [Arguments]    ${index}
    ${position}=    Evaluate    int(${index}) + 1    # XPath positions start at 1
    # NOTE: writing ${ITEM_XPATH}[${position}] would NOT work - Robot treats
    # ${var}[n] as "item n of the variable" (here: the n-th character).
    RETURN    xpath:(//div[@class='inventory_item'])[${position}]


Add Product To Cart By Index
    [Documentation]    Add product to cart by its index (0-based)
    [Arguments]    ${index}
    Log Test Step    Adding product at index ${index} to cart
    ${product}=    Get Product Locator By Index    ${index}
    Click Element    ${product}//button[contains(@data-test,'add-to-cart')]
    Log    Product at index ${index} added to cart


Add Product To Cart By Name
    [Documentation]    Add product to cart by its exact name
    [Arguments]    ${product_name}
    Log Test Step    Adding product '${product_name}' to cart
    ${button}=    Set Variable
    ...    xpath://div[@class='inventory_item'][.//div[contains(@class,'inventory_item_name')][normalize-space()="${product_name}"]]//button[contains(@data-test,'add-to-cart')]
    Click Element    ${button}
    Log    Product '${product_name}' added to cart


Add All Products To Cart
    [Documentation]    Add all visible products to cart
    Log Test Step    Adding all products to cart
    ${count}=    Get Element Count    ${INVENTORY_ITEM}
    FOR    ${index}    IN RANGE    0    ${count}
        Add Product To Cart By Index    ${index}
    END
    Log    All ${count} products added to cart


Add Multiple Products By Index
    [Documentation]    Add multiple products to cart by their indices
    [Arguments]    @{indices}
    FOR    ${index}    IN    @{indices}
        Add Product To Cart By Index    ${index}
    END


Remove Product From Cart By Index
    [Documentation]    Remove product from cart by its index
    [Arguments]    ${index}
    Log Test Step    Removing product at index ${index} from cart
    ${product}=    Get Product Locator By Index    ${index}
    Click Element    ${product}//button[contains(@data-test,'remove')]
    Log    Product at index ${index} removed from cart


# ============================================================================
# Sorting Keywords
# ============================================================================

Sort Products By Option
    [Documentation]    Sort products by specified option.
    ...    sort_option: 'az', 'za', 'lohi', 'hilo'
    ...    The dropdown is a real <select>, so use "Select From List By Value"
    ...    instead of clicking <option> elements.
    [Arguments]    ${sort_option}
    Log Test Step    Sorting products by: ${sort_option}
    Select From List By Value    ${SORT_DROPDOWN}    ${sort_option}
    Log    Products sorted by ${sort_option}


Sort Products A To Z
    [Documentation]    Sort products alphabetically (A to Z)
    Sort Products By Option    az


Sort Products Z To A
    [Documentation]    Sort products reverse alphabetically (Z to A)
    Sort Products By Option    za


Sort Products Price Low To High
    [Documentation]    Sort products by price (Low to High)
    Sort Products By Option    lohi


Sort Products Price High To Low
    [Documentation]    Sort products by price (High to Low)
    Sort Products By Option    hilo


Verify Products Sorted A To Z
    [Documentation]    Verify products are sorted alphabetically
    ${names}=    Get All Product Names
    ${sorted_names}=    Evaluate    sorted($names)
    Lists Should Be Equal    ${names}    ${sorted_names}    Products not sorted A-Z
    Log    Products verified as sorted A-Z


Verify Products Sorted Z To A
    [Documentation]    Verify products are sorted in reverse alphabetical order
    ${names}=    Get All Product Names
    ${sorted_names}=    Evaluate    sorted($names, reverse=True)
    Lists Should Be Equal    ${names}    ${sorted_names}    Products not sorted Z-A
    Log    Products verified as sorted Z-A


Verify Products Sorted Price Low To High
    [Documentation]    Verify products are sorted by price ascending
    ${prices}=    Get All Product Prices
    ${sorted_prices}=    Evaluate    sorted($prices)
    Lists Should Be Equal    ${prices}    ${sorted_prices}    Products not sorted by price (low-high)
    Log    Products verified as sorted by price (low to high)


Verify Products Sorted Price High To Low
    [Documentation]    Verify products are sorted by price descending
    ${prices}=    Get All Product Prices
    ${sorted_prices}=    Evaluate    sorted($prices, reverse=True)
    Lists Should Be Equal    ${prices}    ${sorted_prices}    Products not sorted by price (high-low)
    Log    Products verified as sorted by price (high to low)


# ============================================================================
# Cart Interaction Keywords
# ============================================================================

Get Cart Item Count
    [Documentation]    Get the number of items in the shopping cart badge (as an integer).
    ...    The badge is removed from the page when the cart is empty.
    ${badges}=    Get Element Count    ${CART_BADGE}
    IF    ${badges} == 0    RETURN    ${0}
    ${text}=    Get Text    ${CART_BADGE}
    ${count}=    Convert To Integer    ${text}
    RETURN    ${count}


Verify Cart Item Count
    [Documentation]    Verify cart contains expected number of items
    [Arguments]    ${expected_count}
    ${actual_count}=    Get Cart Item Count
    Should Be Equal As Integers    ${actual_count}    ${expected_count}    Cart item count mismatch


Go To Shopping Cart
    [Documentation]    Navigate to shopping cart page
    Log Test Step    Navigating to shopping cart
    Click Element    ${CART_ICON}
    Wait Until Location Contains    /cart
    Wait For Element To Be Visible    class:cart_list


# ============================================================================
# Helper Keywords
# ============================================================================

Verify Product Is In Cart
    [Documentation]    Verify product at index has a Remove button (is in cart)
    [Arguments]    ${index}
    ${product}=    Get Product Locator By Index    ${index}
    Page Should Contain Element    ${product}//button[contains(@data-test,'remove')]
    ...    message=Product at index ${index} is not in cart
