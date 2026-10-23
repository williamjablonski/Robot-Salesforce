*** Settings ***
Documentation       Salesforce Account creation test using shared session and label-based Python keywords. Confirm field labels against the target org DOM.
Resource            ../resources/salesforce-session.resource
Resource            ../data/account-scenarios.resource
Suite Setup         Open Salesforce Object List    Account
Suite Teardown      Close All Browsers

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
Open New Account Form
    LabelUI.Click Text    New
    Wait Until Page Contains    ${ACCOUNT_NAME_LABEL}

Open Account Details
    LabelUI.Click Text    Details
