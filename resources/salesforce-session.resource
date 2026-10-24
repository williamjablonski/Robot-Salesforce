*** Settings ***
Documentation    Shared SeleniumLibrary session setup for executable Salesforce UI suites.
Library    SeleniumLibrary    timeout=15 seconds    implicit_wait=0 seconds    run_on_failure=Capture Page Screenshot
Library    OperatingSystem
Library    String
Resource    label-ui.resource
Resource    salesforce-email.resource

*** Variables ***
${LOGIN_URL}    %{SF_LOGIN_URL=https://q4sureplatform.my.salesforce.com}
${BROWSER}    %{SF_BROWSER=chrome}
${TARGET_ENVIRONMENT}    %{SF_TARGET_ENVIRONMENT=}
${ALLOW_PRODUCTION_WRITES}    %{SF_ALLOW_PRODUCTION_WRITES=false}
${XPATH_USERNAME}    xpath=//input[@id='username']
${XPATH_PASSWORD}    xpath=//input[@id='password']
${XPATH_LOGIN_BUTTON}    xpath=//input[@id='Login']

*** Keywords ***
Open Salesforce Login Page
    Validate Salesforce Target Environment
    Open Browser    ${LOGIN_URL}    ${BROWSER}
    Set Window Size    1920    1080

Validate Salesforce Target Environment
    ${target}=    Convert To Lower Case    ${TARGET_ENVIRONMENT}
    IF    $target == "production"
        ${production_writes}=    Convert To Lower Case    ${ALLOW_PRODUCTION_WRITES}
        Should Be Equal    ${production_writes}    true    Production runs create persistent Salesforce records. Set SF_ALLOW_PRODUCTION_WRITES=true only after explicitly approving these writes.
    ELSE IF    $target != "sandbox"
        Fail    Set SF_TARGET_ENVIRONMENT to either sandbox or production.
    END

Login To Salesforce
    ${username}=    Get Environment Variable    SF_USERNAME
    ${password}=    Get Environment Variable    SF_PASSWORD
    Should Not Be Empty    ${username}    SF_USERNAME must be configured in the environment.
    Should Not Be Empty    ${password}    SF_PASSWORD must be configured in the environment.

    Wait Until Element Is Visible    ${XPATH_USERNAME}
    Input Text    ${XPATH_USERNAME}    ${username}
    Input Password    ${XPATH_PASSWORD}    ${password}
    ${login_request_timestamp}=    Get Salesforce Login Request Timestamp
    Click Element    ${XPATH_LOGIN_BUTTON}
    ${login_state}=    Wait For Salesforce Login State
    ...    ${LOGIN_EXPECTED_PATH}
    ...    ${LOGIN_MFA_CODE_LABEL}
    IF    $login_state == "verification"
        Retrieve And Submit Salesforce Verification Code
        ...    ${LOGIN_MFA_CODE_LABEL}
        ...    ${LOGIN_MFA_VERIFY_BUTTON}
        ...    ${LOGIN_MFA_EMAIL_SENDER}
        ...    ${login_request_timestamp}
        ...    ${LOGIN_MFA_IMAP_HOST}
    END
    Wait Until Location Contains    /lightning/    timeout=60 seconds

Open Salesforce Object List
    [Arguments]    ${object_api_name}

    Open Salesforce Login Page
    Login To Salesforce
    ${current_url}=    Get Location
    ${url_parts}=    Split String    ${current_url}    /lightning/
    Go To    ${url_parts}[0]/lightning/o/${object_api_name}/list
    Wait Until Page Contains    New    timeout=60 seconds
