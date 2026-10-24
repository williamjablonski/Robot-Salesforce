*** Settings ***
Documentation    Configuração do cenário CRUD de Listas acionáveis. Os valores da org (API name, rota da lista e rótulos da UI) são obrigatórios e devem ser confirmados no Salesforce antes da execução; não há metadata disponível neste repositório. O teste cria um registro com nome sintético único, consulta e atualiza esse registro e exclui somente esse mesmo registro. Se o teste falhar antes da exclusão, o registro pode permanecer no ambiente e deve ser identificado pelo prefixo Robot Actionable List e sufixo único antes de qualquer limpeza autorizada.

*** Variables ***
${ACTIONABLE_LIST_OBJECT_API_NAME}    %{SF_ACTIONABLE_LIST_OBJECT_API_NAME=}
${ACTIONABLE_LIST_NAME_LABEL}    %{SF_ACTIONABLE_LIST_NAME_LABEL=}
${ACTIONABLE_LIST_LIST_PATH}    %{SF_ACTIONABLE_LIST_LIST_PATH=}
${ACTIONABLE_LIST_NEW_LABEL}    %{SF_ACTIONABLE_LIST_NEW_LABEL=}
${ACTIONABLE_LIST_SAVE_LABEL}    %{SF_ACTIONABLE_LIST_SAVE_LABEL=}
${ACTIONABLE_LIST_EDIT_LABEL}    %{SF_ACTIONABLE_LIST_EDIT_LABEL=}
${ACTIONABLE_LIST_DELETE_LABEL}    %{SF_ACTIONABLE_LIST_DELETE_LABEL=}
${ACTIONABLE_LIST_DELETE_CONFIRM_LABEL}    %{SF_ACTIONABLE_LIST_DELETE_CONFIRM_LABEL=}
${ACTIONABLE_LIST_TEST_NAME_PREFIX}    Robot Actionable List
${ACTIONABLE_LIST_UPDATED_NAME_PREFIX}    Robot Actionable List Updated
