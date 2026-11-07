*** Settings ***
# resources/variables.robot
# Global variables and constants for the test suite

*** Variables ***
# Application URLs
${BASE_URL}                    https://www.saucedemo.com
${LOGIN_PAGE_URL}             ${BASE_URL}/
${PRODUCTS_PAGE_URL}           ${BASE_URL}/inventory.html
${CART_PAGE_URL}               ${BASE_URL}/cart.html
${CHECKOUT_STEP_ONE_URL}       ${BASE_URL}/checkout-step-one.html
${CHECKOUT_STEP_TWO_URL}       ${BASE_URL}/checkout-step-two.html

# Browser Configuration
${BROWSER}                     chrome
${HEADLESS_MODE}              ${False}
${WINDOW_WIDTH}                1920
${WINDOW_HEIGHT}               1080

# Timeouts (in seconds)
${IMPLICIT_WAIT}               10
${EXPLICIT_WAIT}               15
${PAGE_LOAD_TIMEOUT}           30

# Test User Credentials
${VALID_USERNAME}              standard_user
${VALID_PASSWORD}              secret_sauce
${INVALID_USERNAME}            invalid_user
${INVALID_PASSWORD}            wrong_password
${LOCKED_OUT_USERNAME}         locked_out_user
${PROBLEM_USER}                problem_user
${PERFORMANCE_GLITCH_USER}     performance_glitch_user

# Test Data
${FIRST_PRODUCT_INDEX}         0
${CHECKOUT_FIRST_NAME}         John
${CHECKOUT_LAST_NAME}          Doe
${CHECKOUT_POSTAL_CODE}        12345

# Paths
${SCREENSHOT_DIR}              ${EXECDIR}/results/screenshots/
${REPORTS_DIR}                 ${EXECDIR}/results/reports/
${LOGS_DIR}                    ${EXECDIR}/results/logs/

# Expected Text/Messages
${ERROR_MESSAGE_USERNAME}      Username and password do not match any user in this service
${ERROR_MESSAGE_LOCKED}        Sorry, this user has been locked out.
${SUCCESS_LOGIN_INDICATOR}     Swag Labs
${CART_EMPTY_MESSAGE}          Your Cart is Empty
${ERROR_USERNAME_REQUIRED}     Username is required
${ERROR_PASSWORD_REQUIRED}     Password is required
${ERROR_NOT_LOGGED_IN}         when you are logged in
${ERROR_FIRST_NAME_REQUIRED}   First Name is required
${ERROR_LAST_NAME_REQUIRED}    Last Name is required
${ERROR_POSTAL_CODE_REQUIRED}  Postal Code is required
${ORDER_COMPLETE_HEADER}       Thank you for your order!

# Known products (name -> price) on the SauceDemo inventory page
${PRODUCT_BACKPACK}            Sauce Labs Backpack
${PRODUCT_BIKE_LIGHT}          Sauce Labs Bike Light
${PRODUCT_BOLT_TSHIRT}         Sauce Labs Bolt T-Shirt
${PRODUCT_FLEECE_JACKET}       Sauce Labs Fleece Jacket
${PRICE_BACKPACK}              29.99
${PRICE_BIKE_LIGHT}            9.99
${TOTAL_PRODUCT_COUNT}         6
${TAX_RATE}                    0.08

# Logging Levels
${LOG_LEVEL}                   INFO


*** Keywords ***
# Keyword for getting browser configuration
Get Browser Configuration
    [Documentation]    Returns browser configuration dictionary
    ${config}=    Create Dictionary
    ...    browser=${BROWSER}
    ...    headless=${HEADLESS_MODE}
    ...    window_width=${WINDOW_WIDTH}
    ...    window_height=${WINDOW_HEIGHT}
    RETURN    ${config}


Get Implicit Wait Time
    [Documentation]    Returns implicit wait time
    RETURN    ${IMPLICIT_WAIT}


Get Explicit Wait Time
    [Documentation]    Returns explicit wait time
    RETURN    ${EXPLICIT_WAIT}
