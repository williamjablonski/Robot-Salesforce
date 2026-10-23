*** Settings ***
Documentation       Salesforce successful login smoke test using SeleniumLibrary.
Library             SeleniumLibrary    timeout=15 seconds    implicit_wait=0 seconds    run_on_failure=Capture Page Screenshot
Library             OperatingSystem
Suite Setup         Open Salesforce Login Page
Suite Teardown      Close All Browsers

*** Variables ***
${LOGIN_URL}        %{SF_LOGIN_URL=https://q4sureplatform.my.salesforce.com}
${BROWSER}          %{SF_BROWSER=chrome}
${XPATH_USERNAME}   xpath=//input[@id='username']
${XPATH_PASSWORD}   xpath=//input[@id='password']
${XPATH_LOGIN}      xpath=//input[@id='Login']

*** Test Cases ***
Login With Valid Salesforce Credentials
    [Documentation]    Logs in with credentials supplied through secure environment variables and verifies Lightning opens.
    [Tags]    salesforce    login    smoke

    ${username}=    Get Environment Variable    SF_USERNAME
    ${password}=    Get Environment Variable    SF_PASSWORD

    Wait Until Element Is Visible    ${XPATH_USERNAME}
    Input Text    ${XPATH_USERNAME}    ${username}
    Input Password    ${XPATH_PASSWORD}    ${password}
    Click Element    ${XPATH_LOGIN}
    Wait Until Location Contains    /lightning/    timeout=60 seconds

*** Keywords ***
Open Salesforce Login Page
    Open Browser    ${LOGIN_URL}    ${BROWSER}
    Maximize Browser Window
