*** Settings ***
Documentation       Salesforce successful login smoke test using shared session keywords.
Resource            ../resources/salesforce-session.resource
Resource            ../data/login-scenarios.resource
Suite Setup         Open Salesforce Login Page
Suite Teardown      Close All Browsers

*** Test Cases ***
Login With Valid Salesforce Credentials
    [Documentation]    Logs in with credentials supplied through secure environment variables and verifies Lightning opens.
    [Tags]    salesforce    login    smoke

    Login To Salesforce
    Location Should Contain    ${LOGIN_EXPECTED_PATH}
