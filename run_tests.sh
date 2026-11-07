#!/bin/bash
# run_tests.sh - Test execution script for Robot Framework

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="${PROJECT_DIR}/tests"
RESULTS_DIR="${PROJECT_DIR}/results"
REPORTS_DIR="${RESULTS_DIR}/reports"
LOGS_DIR="${RESULTS_DIR}/logs"
SCREENSHOTS_DIR="${RESULTS_DIR}/screenshots"

# Create directories if they don't exist
mkdir -p "${REPORTS_DIR}" "${LOGS_DIR}" "${SCREENSHOTS_DIR}"

# Parse command line arguments
RUN_MODE="${1:-all}"  # all, smoke, regression, e2e, or specific test file
BROWSER="${2:-chrome}"
HEADLESS="${3:-false}"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Robot Framework - Swag Labs Automation Testing         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${YELLOW}Configuration:${NC}"
echo "  Project Dir: ${PROJECT_DIR}"
echo "  Tests Dir: ${TESTS_DIR}"
echo "  Results Dir: ${RESULTS_DIR}"
echo "  Browser: ${BROWSER}"
echo "  Headless Mode: ${HEADLESS}"
echo "  Run Mode: ${RUN_MODE}"
echo ""

# Function to run all tests
run_all_tests() {
    echo -e "${GREEN}Running ALL tests...${NC}\n"
    robot \
        --variable BROWSER:${BROWSER} \
        --variable HEADLESS_MODE:${HEADLESS} \
        --variablefile "${PROJECT_DIR}/config/env_config.yaml" \
        --outputdir "${REPORTS_DIR}" \
        --log log.html \
        --report report.html \
        --output output.xml \
        --loglevel INFO \
        "${TESTS_DIR}"
}

# Function to run smoke tests
run_smoke_tests() {
    echo -e "${GREEN}Running SMOKE tests...${NC}\n"
    robot \
        --variable BROWSER:${BROWSER} \
        --variable HEADLESS_MODE:${HEADLESS} \
        --variablefile "${PROJECT_DIR}/config/env_config.yaml" \
        --include smoke \
        --outputdir "${REPORTS_DIR}" \
        --log log_smoke.html \
        --report report_smoke.html \
        --output output_smoke.xml \
        --loglevel INFO \
        "${TESTS_DIR}"
}

# Function to run regression tests
run_regression_tests() {
    echo -e "${GREEN}Running REGRESSION tests...${NC}\n"
    robot \
        --variable BROWSER:${BROWSER} \
        --variable HEADLESS_MODE:${HEADLESS} \
        --variablefile "${PROJECT_DIR}/config/env_config.yaml" \
        --include regression \
        --outputdir "${REPORTS_DIR}" \
        --log log_regression.html \
        --report report_regression.html \
        --output output_regression.xml \
        --loglevel INFO \
        "${TESTS_DIR}"
}

# Function to run end-to-end tests
run_e2e_tests() {
    echo -e "${GREEN}Running END-TO-END tests...${NC}\n"
    robot \
        --variable BROWSER:${BROWSER} \
        --variable HEADLESS_MODE:${HEADLESS} \
        --variablefile "${PROJECT_DIR}/config/env_config.yaml" \
        --include e2e \
        --outputdir "${REPORTS_DIR}" \
        --log log_e2e.html \
        --report report_e2e.html \
        --output output_e2e.xml \
        --loglevel INFO \
        "${TESTS_DIR}"
}

# Function to run specific test file
run_specific_test() {
    local test_file="$1"
    echo -e "${GREEN}Running test file: ${test_file}${NC}\n"
    robot \
        --variable BROWSER:${BROWSER} \
        --variable HEADLESS_MODE:${HEADLESS} \
        --variablefile "${PROJECT_DIR}/config/env_config.yaml" \
        --outputdir "${REPORTS_DIR}" \
        --log log_${test_file}.html \
        --report report_${test_file}.html \
        --output output_${test_file}.xml \
        --loglevel INFO \
        "${TESTS_DIR}/${test_file}"
}

# Function to run parallel tests
run_parallel_tests() {
    echo -e "${GREEN}Running tests in PARALLEL...${NC}\n"
    pabot \
        --variable BROWSER:${BROWSER} \
        --variable HEADLESS_MODE:${HEADLESS} \
        --variablefile "${PROJECT_DIR}/config/env_config.yaml" \
        --outputdir "${REPORTS_DIR}" \
        --log log_parallel.html \
        --report report_parallel.html \
        --output output_parallel.xml \
        --loglevel INFO \
        --processes 4 \
        "${TESTS_DIR}"
}

# Don't abort on test failures - we want to report them below
set +e

# Use the project's virtualenv if it exists
if [ -f "${PROJECT_DIR}/venv/bin/activate" ]; then
    source "${PROJECT_DIR}/venv/bin/activate"
fi

# Execute based on mode
case ${RUN_MODE} in
    all)
        run_all_tests
        ;;
    smoke)
        run_smoke_tests
        ;;
    regression)
        run_regression_tests
        ;;
    e2e)
        run_e2e_tests
        ;;
    parallel)
        run_parallel_tests
        ;;
    login)
        run_specific_test "01_login_tests.robot"
        ;;
    products)
        run_specific_test "02_product_tests.robot"
        ;;
    cart)
        run_specific_test "03_shopping_cart_tests.robot"
        ;;
    checkout)
        run_specific_test "04_checkout_tests.robot"
        ;;
    e2e_file)
        run_specific_test "05_end_to_end_tests.robot"
        ;;
    *)
        echo -e "${RED}Unknown run mode: ${RUN_MODE}${NC}"
        echo "Usage: $0 [all|smoke|regression|e2e|parallel|login|products|cart|checkout|e2e_file] [browser] [headless]"
        exit 1
        ;;
esac

# Check exit status (robot's return code = number of failed tests)
STATUS=$?
if [ ${STATUS} -eq 0 ]; then
    echo -e "\n${GREEN}✓ Tests completed successfully!${NC}"
    echo -e "${GREEN}Reports available in: ${REPORTS_DIR}${NC}\n"
else
    echo -e "\n${RED}✗ Some tests failed!${NC}"
    exit 1
fi
