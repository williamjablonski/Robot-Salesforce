*** Settings ***
Documentation       Salesforce Order creation test using Robot Framework and SeleniumLibrary. Order form locators are provisional and must be verified against the target org DOM.
Library             SeleniumLibrary    timeout=15 seconds    implicit_wait=0 seconds    run_on_failure=Capture Page Screenshot
Library             OperatingSystem
Library             String
Suite Setup         Login To Salesforce And Open Orders
Suite Teardown      Close All Browsers

*** Variables ***
${LOGIN_URL}                    %{SF_LOGIN_URL=https://q4sureplatform.my.salesforce.com}
${BROWSER}                      %{SF_BROWSER=chrome}
${XPATH_USERNAME}               xpath=//input[@id='username']
${XPATH_PASSWORD}               xpath=//input[@id='password']
${XPATH_LOGIN_BUTTON}           xpath=//input[@id='Login']
${XPATH_NEW_ORDER}              xpath=//button[@title='New' or normalize-space(.)='New'] | //a[@title='New']
${XPATH_ORDER_ACCOUNT}          xpath=//input[@aria-label='Account Name' or @placeholder='Search Accounts...']
${XPATH_ORDER_EFFECTIVE_DATE}   xpath=//input[@name='EffectiveDate' or @aria-label='Order Start Date' or @aria-label='Effective Date']
${XPATH_ORDER_STATUS}           xpath=//*[@role='combobox' and (@aria-label='Status' or @title='Status')]
${XPATH_SAVE_BUTTON}            xpath=//button[@name='SaveEdit' or @title='Save' or normalize-space(.)='Save']
${XPATH_DETAILS_TAB}            xpath=//*[@role='tab' and normalize-space(.)='Details']

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
    Select Order Account    ${account_name}
    Input Text    ${XPATH_ORDER_EFFECTIVE_DATE}    ${effective_date}
    Select Order Status    ${status}
    Click Save
    Wait Until Page Contains    ${account_name}    timeout=30 seconds

    Open Order Details
    Page Should Contain    ${account_name}
    Page Should Contain    ${effective_date}
    Page Should Contain    ${status}

*** Keywords ***
Login To Salesforce And Open Orders
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
    Go To    ${url_parts}[0]/lightning/o/Order/list
    Wait Until Element Is Visible    ${XPATH_NEW_ORDER}    timeout=60 seconds

Open New Order Form
    Click Element    ${XPATH_NEW_ORDER}
    Wait Until Element Is Visible    ${XPATH_ORDER_ACCOUNT}

Select Order Account
    [Arguments]    ${account_name}

    Input Text    ${XPATH_ORDER_ACCOUNT}    ${account_name}
    ${account_option}=    Set Variable    xpath=//*[@role='option' and normalize-space(.)='${account_name}']
    Wait Until Element Is Visible    ${account_option}
    Click Element    ${account_option}

Select Order Status
    [Arguments]    ${status}

    Click Element    ${XPATH_ORDER_STATUS}
    ${status_option}=    Set Variable    xpath=//*[@role='option' and normalize-space(.)='${status}']
    Wait Until Element Is Visible    ${status_option}
    Click Element    ${status_option}

Click Save
    Wait Until Element Is Enabled    ${XPATH_SAVE_BUTTON}
    Click Element    ${XPATH_SAVE_BUTTON}

Open Order Details
    Wait Until Element Is Visible    ${XPATH_DETAILS_TAB}
    Click Element    ${XPATH_DETAILS_TAB}
