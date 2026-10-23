*** Settings ***
Documentation       Salesforce Contact creation smoke test using shared session and label-based Python keywords. Confirm field labels against the target org DOM.
Resource            ../resources/salesforce-session.resource
Resource            ../data/contact-scenarios.resource
Suite Setup         Open Salesforce Object List    Contact
Suite Teardown      Close All Browsers

*** Test Cases ***
Criar Contato E Validar Dados
    [Documentation]    Cria um Contact com dados únicos e verifica o e-mail salvo no registro.
    [Tags]    salesforce    lightning    contact    smoke

    ${suffix}=          Generate Random String    8    [LOWER][NUMBERS]
    ${first_name}=      Set Variable    ${CONTACT_TEST_FIRST_NAME}
    ${last_name}=       Set Variable    ${CONTACT_TEST_LAST_NAME_PREFIX} ${suffix}
    ${contact_name}=    Set Variable    ${first_name} ${last_name}
    ${email}=           Set Variable    ${CONTACT_TEST_EMAIL_PREFIX}${suffix}${CONTACT_TEST_EMAIL_DOMAIN}

    Open New Contact Form
    LabelUI.Type Text    ${CONTACT_FIRST_NAME_LABEL}    ${first_name}
    LabelUI.Type Text    ${CONTACT_LAST_NAME_LABEL}    ${last_name}
    LabelUI.Type Text    ${CONTACT_EMAIL_LABEL}    ${email}
    LabelUI.Click Text    Save
    Wait Until Page Contains    ${contact_name}    timeout=30 seconds
    LabelUI.Click Text    Details
    LabelUI.Verify Text    ${email}

*** Keywords ***
Open New Contact Form
    LabelUI.Click Text    New
    Wait Until Page Contains    ${CONTACT_LAST_NAME_LABEL}
