*** Settings ***
Documentation       Salesforce service catalog creation test using Product2. Form locator and org-required fields must be confirmed in the target org.
Library             SeleniumLibrary    timeout=15 seconds    implicit_wait=0 seconds    run_on_failure=Capture Page Screenshot
Library             OperatingSystem
Library             String
Suite Setup         Login To Salesforce And Open Products
Suite Teardown      Close All Browsers

*** Variables ***
${LOGIN_URL}                    %{SF_LOGIN_URL=https://q4sureplatform.my.salesforce.com}
${BROWSER}                      %{SF_BROWSER=chrome}
${XPATH_USERNAME}               xpath=//input[@id='username']
${XPATH_PASSWORD}               xpath=//input[@id='password']
${XPATH_LOGIN_BUTTON}           xpath=//input[@id='Login']
${XPATH_NEW_PRODUCT}            xpath=//button[@title='New' or normalize-space(.)='New'] | //a[@title='New']
${XPATH_PRODUCT_NAME}           xpath=//input[@name='Name' or @aria-label='Product Name' or @aria-label='Product Name*']
${XPATH_SAVE_BUTTON}            xpath=//button[@name='SaveEdit' or @title='Save' or normalize-space(.)='Save']

*** Test Cases ***
Criar Servico No Catalogo E Validar Nome
    [Documentation]    Cria um Product2 usado como serviço no catálogo e valida o nome do registro.
    [Tags]    salesforce    lightning    product2    service    smoke

    ${suffix}=          Generate Random String    8    [LOWER][NUMBERS]
    ${service_name}=    Set Variable    Robot Service ${suffix}

    Open New Product Form
    Input Text    ${XPATH_PRODUCT_NAME}    ${service_name}
    Click Save
    Wait Until Page Contains    ${service_name}    timeout=30 seconds
    Page Should Contain    ${service_name}

*** Keywords ***
Login To Salesforce And Open Products
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
    Go To    ${url_parts}[0]/lightning/o/Product2/list
    Wait Until Element Is Visible    ${XPATH_NEW_PRODUCT}    timeout=60 seconds

Open New Product Form
    Click Element    ${XPATH_NEW_PRODUCT}
    Wait Until Element Is Visible    ${XPATH_PRODUCT_NAME}

Click Save
    Wait Until Element Is Enabled    ${XPATH_SAVE_BUTTON}
    Click Element    ${XPATH_SAVE_BUTTON}
