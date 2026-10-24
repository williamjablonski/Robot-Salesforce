*** Settings ***
Documentation    Preparação compartilhada do CRUD de Listas acionáveis usando API name, rota e labels explicitamente confirmados e configurados pelo ambiente.
Resource    ../data/actionable-list-scenarios.resource
Resource    salesforce-session.resource

*** Keywords ***
Open Actionable List For CRUD
    Validate Actionable List Configuration
    Open Salesforce Object List    ${ACTIONABLE_LIST_OBJECT_API_NAME}
    Location Should Contain    ${ACTIONABLE_LIST_LIST_PATH}

Validate Actionable List Configuration
    Should Not Be Empty    ${ACTIONABLE_LIST_OBJECT_API_NAME}    Configure SF_ACTIONABLE_LIST_OBJECT_API_NAME with the confirmed Salesforce object API name.
    Should Not Be Empty    ${ACTIONABLE_LIST_NAME_LABEL}    Configure SF_ACTIONABLE_LIST_NAME_LABEL with the exact visible name-field label.
    Should Not Be Empty    ${ACTIONABLE_LIST_LIST_PATH}    Configure SF_ACTIONABLE_LIST_LIST_PATH with the confirmed Lightning list URL path.
    Should Not Be Empty    ${ACTIONABLE_LIST_NEW_LABEL}    Configure SF_ACTIONABLE_LIST_NEW_LABEL with the exact visible New action label.
    Should Not Be Empty    ${ACTIONABLE_LIST_SAVE_LABEL}    Configure SF_ACTIONABLE_LIST_SAVE_LABEL with the exact visible Save action label.
    Should Not Be Empty    ${ACTIONABLE_LIST_EDIT_LABEL}    Configure SF_ACTIONABLE_LIST_EDIT_LABEL with the exact visible Edit action label.
    Should Not Be Empty    ${ACTIONABLE_LIST_DELETE_LABEL}    Configure SF_ACTIONABLE_LIST_DELETE_LABEL with the exact visible Delete action label.
    Should Not Be Empty    ${ACTIONABLE_LIST_DELETE_CONFIRM_LABEL}    Configure SF_ACTIONABLE_LIST_DELETE_CONFIRM_LABEL with the exact Delete confirmation action label.
