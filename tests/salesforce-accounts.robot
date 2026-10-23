*** Settings ***
Documentation       Salesforce Account creation test using label-based Python keywords and SeleniumLibrary. Confirm field labels against the target org DOM.
Library             SeleniumLibrary    timeout=15 seconds    implicit_wait=0 seconds    run_on_failure=Capture Page Screenshot
Library             OperatingSystem
Library             String
Resource            ../resources/label-ui.resource
Resource            ../data/account-scenarios.resource
Suite Setup         Login To Salesforce And Open Accounts
Suite Teardown      Close All Browsers

*** Variables ***
${LOGIN_URL}                    %{SF_LOGIN_URL=https://q4sureplatform.my.salesforce.com}
${BROWSER}                      %{SF_BROWSER=chrome}
${XPATH_USERNAME}               xpath=//input[@id='username']
${XPATH_PASSWORD}               xpath=//input[@id='password']
${XPATH_LOGIN_BUTTON}           xpath=//input[@id='Login']
${XPATH_ACCOUNT_NAME_INPUT}     xpath=//input[@name='Name' or @aria-label='Account Name']

*** Test Cases ***
Criar Conta E Validar Dados
    [Documentation]    Cria uma Account com dados sintéticos únicos e valida os valores no registro salvo.
    [Tags]    salesforce    lightning    account    smoke

    ${suffix}=          Generate Random String    8    [LOWER][NUMBERS]
    ${account_name}=    Set Variable    ${ACCOUNT_TEST_NAME_PREFIX} ${suffix}
    ${phone_digits}=    Generate Random String    8    [NUMBERS]
    ${phone}=           Set Variable    ${ACCOUNT_TEST_PHONE_PREFIX}${phone_digits}
    ${website}=         Set Variable    ${ACCOUNT_TEST_WEBSITE_PREFIX}${suffix}
    ${description}=     Set Variable    ${ACCOUNT_TEST_DESCRIPTION_PREFIX} ${suffix}

    Open New Account Form
    LabelUI.Type Text    ${ACCOUNT_NAME_LABEL}    ${account_name}
    LabelUI.Type Text    ${ACCOUNT_PHONE_LABEL}    ${phone}
    LabelUI.Type Text    ${ACCOUNT_WEBSITE_LABEL}    ${website}
    LabelUI.Type Text    ${ACCOUNT_DESCRIPTION_LABEL}    ${description}
    LabelUI.Click Text    Save
    Wait Until Page Contains    ${account_name}    timeout=30 seconds

    Open Account Details
    LabelUI.Verify Text    ${account_name}
    Page Should Contain    ${phone}
    Page Should Contain    ${website}
    Page Should Contain    ${description}

*** Keywords ***
Login To Salesforce And Open Accounts
    ${username}=    Get Environment Variable    SF_USERNAME
    ${password}=    Get Environment Variable    SF_PASSWORD
    Should Not Be Empty    ${username}    SF_USERNAME must be configured in the environment.
    Should Not Be Empty    ${password}    SF_PASSWORD must be configured in the environment.

    Open Browser    ${LOGIN_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    ${XPATH_USERNAME}
    Input Text    ${XPATH_USERNAME}    ${username}
    Input Password    ${XPATH_PASSWORD}    ${password}
    Click Element    ${XPATH_LOGIN_BUTTON}
    Wait Until Location Contains    /lightning/    timeout=60 seconds

    ${current_url}=    Get Location
    ${url_parts}=    Split String    ${current_url}    /lightning/
    Go To    ${url_parts}[0]/lightning/o/Account/list
    Wait Until Page Contains    New    timeout=60 seconds

Open New Account Form
    LabelUI.Click Text    New
    Wait Until Element Is Visible    ${XPATH_ACCOUNT_NAME_INPUT}

Open Account Details
    LabelUI.Click Text    Details
