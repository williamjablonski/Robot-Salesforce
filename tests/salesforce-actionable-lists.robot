*** Settings ***
Documentation    CRUD de Listas acionáveis Salesforce. Requer confirmação do API name, rota Lightning e labels da UI na org alvo; não assume metadata não fornecida.
Resource    ../resources/actionable-list.resource
Suite Setup    Open Actionable List For CRUD
Suite Teardown    Close All Browsers

*** Test Cases ***
Criar Consultar Atualizar E Excluir Lista Acionavel De Marketing
    [Documentation]    Cria um registro sintético com nome único, valida leitura e atualização do nome e exclui somente o registro criado nesta execução.
    [Tags]    salesforce    lightning    actionable-list    regression

    ${suffix}=    Generate Random String    8    [LOWER][NUMBERS]
    ${actionable_list_name}=    Set Variable    ${ACTIONABLE_LIST_TEST_NAME_PREFIX} ${suffix}
    ${updated_name}=    Set Variable    ${ACTIONABLE_LIST_UPDATED_NAME_PREFIX} ${suffix}

    LabelUI.Click Text    ${ACTIONABLE_LIST_NEW_LABEL}
    Wait Until Page Contains    ${ACTIONABLE_LIST_NAME_LABEL}
    LabelUI.Type Text    ${ACTIONABLE_LIST_NAME_LABEL}    ${actionable_list_name}
    LabelUI.Click Text    ${ACTIONABLE_LIST_SAVE_LABEL}
    Wait Until Page Contains    ${actionable_list_name}    timeout=30 seconds
    LabelUI.Verify Text    ${actionable_list_name}

    LabelUI.Click Text    ${ACTIONABLE_LIST_EDIT_LABEL}
    Wait Until Page Contains    ${ACTIONABLE_LIST_NAME_LABEL}
    LabelUI.Type Text    ${ACTIONABLE_LIST_NAME_LABEL}    ${updated_name}
    LabelUI.Click Text    ${ACTIONABLE_LIST_SAVE_LABEL}
    Wait Until Page Contains    ${updated_name}    timeout=30 seconds
    LabelUI.Verify Text    ${updated_name}

    LabelUI.Click Text    ${ACTIONABLE_LIST_DELETE_LABEL}
    LabelUI.Click Text In Dialog    ${ACTIONABLE_LIST_DELETE_CONFIRM_LABEL}
    Wait Until Location Contains    ${ACTIONABLE_LIST_LIST_PATH}    timeout=30 seconds
    Page Should Not Contain    ${updated_name}
