*** Settings ***
# resources/keywords/product_keywords.robot
# Business-level keywords for the products (inventory) page.

Resource    ../../page_objects/products_page.robot

*** Variables ***
# Product details page (/inventory-item.html?id=N)
${PRODUCT_DETAILS_NAME}        class:inventory_details_name
${PRODUCT_DETAILS_PRICE}       class:inventory_details_price
${PRODUCT_DETAILS_DESC}        class:inventory_details_desc
${BACK_TO_PRODUCTS_BUTTON}     id:back-to-products

*** Keywords ***

Product Count Should Be
    [Documentation]    Verify how many products are shown on the inventory page
    [Arguments]    ${expected_count}
    ${count}=    Get Number Of Products
    Should Be Equal As Integers    ${count}    ${expected_count}


Products Should Be Sortable By
    [Documentation]    Sort with the dropdown and verify the order.
    ...    Used as a [Template] in 02_product_tests.robot.
    ...    sort_option: az | za | lohi | hilo
    [Arguments]    ${sort_option}
    Sort Products By Option    ${sort_option}
    IF    '${sort_option}' == 'az'
        Verify Products Sorted A To Z
    ELSE IF    '${sort_option}' == 'za'
        Verify Products Sorted Z To A
    ELSE IF    '${sort_option}' == 'lohi'
        Verify Products Sorted Price Low To High
    ELSE IF    '${sort_option}' == 'hilo'
        Verify Products Sorted Price High To Low
    ELSE
        Fail    Unknown sort option: ${sort_option}
    END


Open Product Details
    [Documentation]    Click a product name to open its details page
    [Arguments]    ${product_name}
    Log Test Step    Opening details for '${product_name}'
    Click Element    xpath://div[contains(@class,'inventory_item_name')][normalize-space()="${product_name}"]
    Wait Until Location Contains    /inventory-item.html


Product Details Should Show
    [Documentation]    Verify the details page shows the right product and price
    [Arguments]    ${product_name}    ${price}
    Wait For Element To Be Visible    ${PRODUCT_DETAILS_NAME}
    Element Text Should Be    ${PRODUCT_DETAILS_NAME}    ${product_name}
    Element Text Should Be    ${PRODUCT_DETAILS_PRICE}    $${price}
    Element Should Be Visible    ${PRODUCT_DETAILS_DESC}


Go Back To Products
    [Documentation]    Leave the details page with the "Back to products" button
    Click Element    ${BACK_TO_PRODUCTS_BUTTON}
    Products Page Should Be Loaded
