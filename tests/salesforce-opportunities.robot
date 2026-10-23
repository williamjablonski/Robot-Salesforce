*** Settings ***
Documentation       Salesforce Opportunity creation test using shared session and label-based Python keywords. Confirm field labels against the target org DOM.
Resource            ../resources/salesforce-session.resource
Resource            ../data/opportunity-scenarios.resource
Suite Setup         Open Salesforce Object List    Opportunity
Suite Teardown      Close All Browsers

*** Test Cases ***
Criar Oportunidade E Validar Dados
    [Documentation]    Cria uma Opportunity com Stage e Close Date configurados para a org e verifica o registro salvo.
    [Tags]    salesforce    lightning    opportunity    smoke

    ${suffix}=          Generate Random String    8    [LOWER][NUMBERS]
    ${opportunity_name}=    Set Variable    ${OPPORTUNITY_TEST_NAME_PREFIX} ${suffix}
    ${stage}=           Get Environment Variable    SF_OPPORTUNITY_STAGE
    ${close_date}=      Get Environment Variable    SF_OPPORTUNITY_CLOSE_DATE
    Should Not Be Empty    ${stage}    Configure SF_OPPORTUNITY_STAGE with a valid Stage label from the target org.
    Should Not Be Empty    ${close_date}    Configure SF_OPPORTUNITY_CLOSE_DATE in the format accepted by the target org.

    Open New Opportunity Form
    LabelUI.Type Text    ${OPPORTUNITY_NAME_LABEL}    ${opportunity_name}
    LabelUI.Type Text    ${OPPORTUNITY_CLOSE_DATE_LABEL}    ${close_date}
    LabelUI.Click Text    ${OPPORTUNITY_STAGE_LABEL}
    LabelUI.Click Text    ${stage}
    LabelUI.Click Text    Save
    Wait Until Page Contains    ${opportunity_name}    timeout=30 seconds

    LabelUI.Click Text    Details
    LabelUI.Verify Text    ${opportunity_name}
    LabelUI.Verify Text    ${stage}

*** Keywords ***
Open New Opportunity Form
    LabelUI.Click Text    New
    Wait Until Page Contains    ${OPPORTUNITY_NAME_LABEL}
