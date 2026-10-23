*** Settings ***
Documentation       Salesforce service catalog creation test using Product2 and shared label-based Python keywords. Confirm field labels and required fields in the target org.
Resource            ../resources/salesforce-session.resource
Resource            ../data/service-scenarios.resource
Suite Setup         Open Salesforce Object List    Product2
Suite Teardown      Close All Browsers

*** Test Cases ***
Criar Servico No Catalogo E Validar Nome
    [Documentation]    Cria um Product2 usado como serviço no catálogo e valida o nome do registro.
    [Tags]    salesforce    lightning    product2    service    smoke

    ${suffix}=          Generate Random String    8    [LOWER][NUMBERS]
    ${service_name}=    Set Variable    ${SERVICE_TEST_NAME_PREFIX} ${suffix}

    Open New Product Form
    LabelUI.Type Text    ${SERVICE_NAME_LABEL}    ${service_name}
    LabelUI.Click Text    Save
    Wait Until Page Contains    ${service_name}    timeout=30 seconds
    LabelUI.Verify Text    ${service_name}

*** Keywords ***
Open New Product Form
    LabelUI.Click Text    New
    Wait Until Page Contains    ${SERVICE_NAME_LABEL}
