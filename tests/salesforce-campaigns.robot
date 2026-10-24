*** Settings ***
Documentation    Salesforce Campaign CRUD test. Campaign labels and required fields must be confirmed in the authorized target org before execution.
Resource    ../resources/salesforce-session.resource
Resource    ../data/campaign-scenarios.resource
Suite Setup    Open Salesforce Object List    Campaign
Suite Teardown    Close All Browsers

*** Test Cases ***
Criar Consultar Atualizar E Excluir Campanha De Marketing
    [Documentation]    Cria uma Campaign sintética, confirma os dados, altera o nome, confirma a alteração e exclui somente o registro criado neste teste.
    [Tags]    salesforce    lightning    campaign    regression

    ${suffix}=    Generate Random String    8    [LOWER][NUMBERS]
    ${campaign_name}=    Set Variable    ${CAMPAIGN_TEST_NAME_PREFIX} ${suffix}
    ${updated_campaign_name}=    Set Variable    ${CAMPAIGN_UPDATED_NAME_PREFIX} ${suffix}
    ${campaign_status}=    Get Environment Variable    ${CAMPAIGN_STATUS_ENV}    default=

    LabelUI.Click Text    New
    Wait Until Page Contains    ${CAMPAIGN_NAME_LABEL}
    LabelUI.Type Text    ${CAMPAIGN_NAME_LABEL}    ${campaign_name}
    IF    $campaign_status != ""
        LabelUI.Click Text    ${CAMPAIGN_STATUS_LABEL}
        LabelUI.Click Text    ${campaign_status}
    END
    LabelUI.Click Text    Save
    Wait Until Page Contains    ${campaign_name}    timeout=30 seconds
    LabelUI.Verify Text    ${campaign_name}

    LabelUI.Click Text    Edit
    Wait Until Page Contains    ${CAMPAIGN_NAME_LABEL}
    LabelUI.Type Text    ${CAMPAIGN_NAME_LABEL}    ${updated_campaign_name}
    LabelUI.Click Text    Save
    Wait Until Page Contains    ${updated_campaign_name}    timeout=30 seconds
    LabelUI.Verify Text    ${updated_campaign_name}

    LabelUI.Click Text    Delete
    LabelUI.Click Text In Dialog    Delete
    Wait Until Location Contains    ${CAMPAIGN_LIST_PATH}    timeout=30 seconds
    Page Should Not Contain    ${updated_campaign_name}
