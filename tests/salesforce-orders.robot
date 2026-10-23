*** Settings ***
Documentation       Salesforce Order creation test using shared session and label-based Python keywords. Confirm field labels against the target org DOM.
Resource            ../resources/salesforce-session.resource
Resource            ../data/order-scenarios.resource
Suite Setup         Open Salesforce Object List    Order
Suite Teardown      Close All Browsers

*** Test Cases ***
Criar Order E Validar Dados
    [Documentation]    Cria um Order para uma Account configurada e valida status e data no registro salvo.
    [Tags]    salesforce    lightning    order    smoke

    ${account_name}=    Get Environment Variable    SF_ORDER_ACCOUNT_NAME
    ${effective_date}=    Get Environment Variable    SF_ORDER_EFFECTIVE_DATE
    ${status}=    Get Environment Variable    SF_ORDER_STATUS
    Should Not Be Empty    ${account_name}    Configure SF_ORDER_ACCOUNT_NAME with an existing authorized Account visible to this user.
    Should Not Be Empty    ${effective_date}    Configure SF_ORDER_EFFECTIVE_DATE in the format accepted by the target org.
    Should Not Be Empty    ${status}    Configure SF_ORDER_STATUS with a valid Order status from the target org.

    Open New Order Form
    LabelUI.Type Text    ${ORDER_ACCOUNT_LABEL}    ${account_name}
    LabelUI.Click Text    ${account_name}
    LabelUI.Type Text    ${ORDER_EFFECTIVE_DATE_LABEL}    ${effective_date}
    LabelUI.Click Text    ${ORDER_STATUS_LABEL}
    LabelUI.Click Text    ${status}
    LabelUI.Click Text    Save
    Wait Until Page Contains    ${account_name}    timeout=30 seconds

    LabelUI.Click Text    Details
    LabelUI.Verify Text    ${account_name}
    LabelUI.Verify Text    ${effective_date}
    LabelUI.Verify Text    ${status}

*** Keywords ***
Open New Order Form
    LabelUI.Click Text    New
    Wait Until Page Contains    ${ORDER_ACCOUNT_LABEL}
