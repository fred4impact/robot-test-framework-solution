*** Settings ***
# page_objects/checkout_page.robot
# Checkout flow - three pages:
#   Step 1  /checkout-step-one.html   "Your Information" form
#   Step 2  /checkout-step-two.html   "Overview" with prices and totals
#   Done    /checkout-complete.html   "Thank you for your order!"

Resource    ../resources/common.robot

*** Variables ***
# Step 1 - Information form
${FIRST_NAME_INPUT}            id:first-name
${LAST_NAME_INPUT}             id:last-name
${POSTAL_CODE_INPUT}           id:postal-code
${CONTINUE_BUTTON}             id:continue
${CHECKOUT_CANCEL_BUTTON}      id:cancel
${CHECKOUT_ERROR}              css:[data-test='error']

# Step 2 - Overview
${OVERVIEW_ITEM}               class:cart_item
${OVERVIEW_ITEM_PRICE}         css:.cart_item .inventory_item_price
${SUBTOTAL_LABEL}              class:summary_subtotal_label
${TAX_LABEL}                   class:summary_tax_label
${TOTAL_LABEL}                 class:summary_total_label
${FINISH_BUTTON}               id:finish

# Complete page
${COMPLETE_HEADER}             class:complete-header
${BACK_HOME_BUTTON}            id:back-to-products

*** Keywords ***

# ============================================================================
# Step 1 - Your Information
# ============================================================================

Checkout Information Page Should Be Displayed
    [Documentation]    Verify the checkout information form is open
    Wait Until Location Contains    /checkout-step-one.html
    Wait For Element To Be Visible    ${FIRST_NAME_INPUT}


Enter Checkout Information
    [Documentation]    Fill in the checkout form. Pass ${EMPTY} to leave a field blank.
    [Arguments]    ${first_name}    ${last_name}    ${postal_code}
    Log Test Step    Entering checkout info: '${first_name}' '${last_name}' '${postal_code}'
    # The URL changes before React renders the form - wait for the field itself
    Wait For Element To Be Visible    ${FIRST_NAME_INPUT}
    Input Text    ${FIRST_NAME_INPUT}    ${first_name}
    Input Text    ${LAST_NAME_INPUT}    ${last_name}
    Input Text    ${POSTAL_CODE_INPUT}    ${postal_code}


Click Continue On Checkout
    [Documentation]    Submit the information form
    Click Element    ${CONTINUE_BUTTON}


Click Cancel On Checkout
    [Documentation]    Click Cancel (step 1 -> cart, step 2 -> products)
    Click Element    ${CHECKOUT_CANCEL_BUTTON}


Checkout Error Should Contain
    [Documentation]    Verify the checkout form shows a validation error
    [Arguments]    ${expected_text}
    Verify Error Message    ${expected_text}    ${CHECKOUT_ERROR}


# ============================================================================
# Step 2 - Overview
# ============================================================================

Checkout Overview Page Should Be Displayed
    [Documentation]    Verify the order overview page is open
    Wait Until Location Contains    /checkout-step-two.html
    Wait For Element To Be Visible    ${TOTAL_LABEL}


Get Amount From Label
    [Documentation]    Turn a label like "Item total: $29.99" into the number 29.99
    [Arguments]    ${locator}
    ${text}=    Get Text    ${locator}
    ${amount}=    Evaluate    float($text.split('$')[-1])
    RETURN    ${amount}


Get Overview Item Prices
    [Documentation]    Return the prices of all items on the overview page
    ${elements}=    Get WebElements    ${OVERVIEW_ITEM_PRICE}
    ${prices}=    Create List
    FOR    ${element}    IN    @{elements}
        ${text}=    Get Text    ${element}
        ${price}=    Convert To Number    ${text.replace('$', '')}
        Append To List    ${prices}    ${price}
    END
    RETURN    ${prices}


Order Totals Should Be Correct
    [Documentation]    Check the maths on the overview page:
    ...    item total = sum of item prices, tax = 8% of item total,
    ...    total = item total + tax
    ${prices}=      Get Overview Item Prices
    ${subtotal}=    Get Amount From Label    ${SUBTOTAL_LABEL}
    ${tax}=         Get Amount From Label    ${TAX_LABEL}
    ${total}=       Get Amount From Label    ${TOTAL_LABEL}
    Log    Prices: ${prices} | Item total: ${subtotal} | Tax: ${tax} | Total: ${total}

    ${expected_subtotal}=    Evaluate    round(sum($prices), 2)
    ${expected_tax}=         Evaluate    round($subtotal * ${TAX_RATE}, 2)
    ${expected_total}=       Evaluate    round($subtotal + $tax, 2)

    Should Be Equal As Numbers    ${subtotal}    ${expected_subtotal}    precision=2    msg=Item total is wrong
    Should Be Equal As Numbers    ${tax}         ${expected_tax}         precision=2    msg=Tax is wrong
    Should Be Equal As Numbers    ${total}       ${expected_total}       precision=2    msg=Total is wrong


Click Finish
    [Documentation]    Place the order
    Click Element    ${FINISH_BUTTON}


# ============================================================================
# Complete
# ============================================================================

Order Complete Page Should Be Displayed
    [Documentation]    Verify the order confirmation page
    Wait Until Location Contains    /checkout-complete.html
    Wait For Element To Be Visible    ${COMPLETE_HEADER}
    Element Text Should Be    ${COMPLETE_HEADER}    ${ORDER_COMPLETE_HEADER}


Click Back Home
    [Documentation]    Return to products after placing an order
    Click Element    ${BACK_HOME_BUTTON}
    Wait Until Location Contains    /inventory.html
