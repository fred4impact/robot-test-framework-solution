*** Settings ***
# tests/05_end_to_end_tests.robot
# End-to-end test cases covering complete user workflows

Resource    ../page_objects/login_page.robot
Resource    ../page_objects/products_page.robot
Resource    ../resources/common.robot

Suite Setup       Log Suite Start
Test Teardown     Run Keywords    Run Keyword If Test Failed    Handle Test Failure    AND    Close Application
Suite Teardown    Close Application

Documentation    
...    End-to-end tests cover complete user workflows from login through checkout.
...    These tests verify the entire application flow and user experience.


*** Test Cases ***

TC501: Complete Shopping Journey - Single Product
    [Documentation]    
    ...    Test complete user journey:
    ...    1. Login with valid credentials
    ...    2. Browse products
    ...    3. Add single product to cart
    ...    4. Verify cart contents
    [Tags]    e2e    smoke    high_priority
    
    # Step 1: Navigate and Login
    Log Test Step    Step 1: User Login
    Navigate To Login Page
    Login With Valid User
    Products Page Should Be Displayed
    
    # Step 2: Browse Products
    Log Test Step    Step 2: Browse Products
    Verify Product Count Greater Than Zero
    ${initial_count}=    Get WebElements    class:inventory_item
    ${product_count}=    Get Length    ${initial_count}
    Log    Found ${product_count} products
    
    # Step 3: Add Product to Cart
    Log Test Step    Step 3: Add Product to Cart
    ${product_names}=    Get All Product Names
    ${first_product}=    Get From List    ${product_names}    0
    Log    Adding product: ${first_product}
    Add Product To Cart By Index    0
    
    # Step 4: Verify Cart
    Log Test Step    Step 4: Verify Cart Contents
    ${cart_count}=    Get Cart Item Count
    Should Be Equal As Integers    ${cart_count}    1
    Go To Shopping Cart
    
    # Final Verification
    Log Test Step    Test Completed: Single Product Added to Cart
    Take Screenshot With Name    e2e_single_product_complete


TC502: Complete Shopping Journey - Multiple Products
    [Documentation]    
    ...    Test user journey with multiple products:
    ...    1. Login
    ...    2. Sort products
    ...    3. Add multiple products (3 items)
    ...    4. Remove one product
    ...    5. Verify final cart state
    [Tags]    e2e    regression    high_priority
    
    # Setup
    Log Test Step    Step 1: Login
    Navigate To Login Page
    Login With Valid User
    
    # Sort products
    Log Test Step    Step 2: Sort Products Price Low to High
    Sort Products Price Low To High
    Verify Products Sorted Price Low To High
    
    # Add multiple products
    Log Test Step    Step 3: Add Multiple Products
    Add Product To Cart By Index    0
    Sleep    0.3
    Add Product To Cart By Index    1
    Sleep    0.3
    Add Product To Cart By Index    2
    ${cart_count}=    Get Cart Item Count
    Should Be Equal As Integers    ${cart_count}    3
    Log    Successfully added 3 products
    
    # Remove one product
    Log Test Step    Step 4: Remove One Product
    Remove Product From Cart By Index    1
    ${updated_count}=    Get Cart Item Count
    Should Be Equal As Integers    ${updated_count}    2
    Log    Product removed, cart now has ${updated_count} items
    
    # Navigate to cart
    Log Test Step    Step 5: View Cart
    Go To Shopping Cart
    Verify Current URL Contains    /cart
    
    # Final verification
    Log Test Step    Test Completed: Multiple Products Journey
    Take Screenshot With Name    e2e_multiple_products_complete


TC503: Browse All Products With Sorting
    [Documentation]    
    ...    Test comprehensive product browsing:
    ...    1. Login
    ...    2. Test all sorting options
    ...    3. Add products after each sort
    ...    4. Verify cart functionality
    [Tags]    e2e    regression    medium_priority
    
    Log Test Step    Step 1: Login and Navigate
    Navigate To Login Page
    Login With Valid User
    Products Page Should Be Loaded
    
    # Test A to Z sorting
    Log Test Step    Step 2: Test A to Z Sorting
    Sort Products A To Z
    Verify Products Sorted A To Z
    Add Product To Cart By Index    0
    
    # Test Z to A sorting
    Log Test Step    Step 3: Test Z to A Sorting
    Sort Products Z To A
    Verify Products Sorted Z To A
    Add Product To Cart By Index    0
    
    # Test Price Low to High
    Log Test Step    Step 4: Test Price Low to High
    Sort Products Price Low To High
    Verify Products Sorted Price Low To High
    Add Product To Cart By Index    0
    
    # Test Price High to Low
    Log Test Step    Step 5: Test Price High to Low
    Sort Products Price High To Low
    Verify Products Sorted Price High To Low
    Add Product To Cart By Index    0
    
    # Verify cart has items
    Log Test Step    Step 6: Verify Cart
    ${final_count}=    Get Cart Item Count
    Should Be True    ${final_count} > 0
    Log    Cart contains ${final_count} items
    
    # Final check
    Log Test Step    Test Completed: Sorting Test Journey
    Take Screenshot With Name    e2e_sorting_test_complete


TC504: User Session - Login, Browse, Logout
    [Documentation]    
    ...    Test complete user session:
    ...    1. Navigate to login
    ...    2. Login successfully
    ...    3. Browse products
    ...    4. Logout
    ...    5. Verify back at login page
    [Tags]    e2e    smoke    medium_priority
    
    Log Test Step    Step 1: Navigate to Login
    Navigate To Login Page
    Login Page Should Be Displayed
    
    Log Test Step    Step 2: Login with Valid Credentials
    Login With Valid User
    User Should Be Logged In
    
    Log Test Step    Step 3: Browse Products
    Products Page Should Be Loaded
    Verify Product Count Greater Than Zero
    ${product_count}=    Get WebElements    class:inventory_item
    Log    Browsing ${product_count.__len__()} products
    
    Log Test Step    Step 4: Logout
    Logout User
    
    Log Test Step    Step 5: Verify Logout
    User Should Not Be Logged In
    Login Page Should Be Displayed
    
    Log Test Step    Test Completed: User Session Test
    Take Screenshot With Name    e2e_session_complete


TC505: Add All Products - Complete Cart
    [Documentation]    
    ...    Test adding all available products:
    ...    1. Login
    ...    2. Add all 6 products
    ...    3. Verify cart count matches product count
    ...    4. Verify all products in cart
    [Tags]    e2e    regression    high_priority
    
    Log Test Step    Step 1: Login
    Navigate To Login Page
    Login With Valid User
    
    Log Test Step    Step 2: Get Product Count
    ${all_products}=    Get WebElements    class:inventory_item
    ${total_products}=    Get Length    ${all_products}
    Log    Total products available: ${total_products}
    
    Log Test Step    Step 3: Add All Products to Cart
    Add All Products To Cart
    
    Log Test Step    Step 4: Verify Cart Count
    ${cart_count}=    Get Cart Item Count
    Should Be Equal As Integers    ${cart_count}    ${total_products}
    Log    All ${total_products} products successfully added to cart
    
    Log Test Step    Step 5: Navigate to Cart
    Go To Shopping Cart
    Verify Current URL Contains    /cart
    
    Log Test Step    Test Completed: Full Cart Test
    Take Screenshot With Name    e2e_full_cart_complete


*** Keywords ***

Log Suite Start
    # ${'='*80} is not valid Robot syntax - use inline Python ${{ }} instead
    Log    ${{'=' * 80}}    console=True
    Log    STARTING END-TO-END TEST SUITE    console=True
    Log    Testing complete user workflows and shopping journeys    console=True
    Log    ${{'=' * 80}}    console=True


Log Test Step
    [Documentation]    Log a numbered test step
    [Arguments]    ${step}
    Log    \n➤ ${step}    console=True
