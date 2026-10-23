*** Settings ***
Documentation       Salesforce Account creation test using Robot Framework and SeleniumLibrary. XPath locators follow the existing suite and need confirmation against the target org DOM.
Library             SeleniumLibrary    timeout=15 seconds    implicit_wait=0 seconds    run_on_failure=Capture Page Screenshot
Library             OperatingSystem
Library             String
Suite Setup         Login To Salesforce And Open Accounts
Suite Teardown      Close All Browsers

*** Variables ***
${LOGIN_URL}                    %{SF_LOGIN_URL=https://q4sureplatform.my.salesforce.com}
${BROWSER}                      %{SF_BROWSER=chrome}
${XPATH_USERNAME}               xpath=//input[@id='username']
${XPATH_PASSWORD}               xpath=//input[@id='password']
${XPATH_LOGIN_BUTTON}           xpath=//input[@id='Login']
${XPATH_NEW_ACCOUNT}            xpath=//button[@title='New' or normalize-space(.)='New'] | //a[@title='New']
${XPATH_ACCOUNT_NAME_INPUT}     xpath=//input[@name='Name' or @aria-label='Account Name']
${XPATH_PHONE_INPUT}            xpath=//input[@name='Phone' or @aria-label='Phone']
${XPATH_WEBSITE_INPUT}          xpath=//input[@name='Website' or @aria-label='Website']
${XPATH_DESCRIPTION_INPUT}      xpath=//textarea[@name='Description' or @aria-label='Description']
${XPATH_SAVE_BUTTON}            xpath=//button[@name='SaveEdit' or @title='Save' or normalize-space(.)='Save']
${XPATH_DETAILS_TAB}            xpath=//*[@role='tab' and normalize-space(.)='Details']

*** Test Cases ***
Criar Conta E Validar Dados
    [Documentation]    Cria uma Account com dados sintéticos únicos e valida os valores no registro salvo.
    [Tags]    salesforce    lightning    account    smoke

    ${suffix}=          Generate Random String    8    [LOWER][NUMBERS]
    ${account_name}=    Set Variable    Robot Account ${suffix}
    ${phone_digits}=    Generate Random String    8    [NUMBERS]
    ${phone}=           Set Variable    555${phone_digits}
    ${website}=         Set Variable    https://example.com/robot-account-${suffix}
    ${description}=     Set Variable    Created by Robot Framework test ${suffix}

    Open New Account Form
    Input Text    ${XPATH_ACCOUNT_NAME_INPUT}    ${account_name}
    Input Text    ${XPATH_PHONE_INPUT}    ${phone}
    Input Text    ${XPATH_WEBSITE_INPUT}    ${website}
    Input Text    ${XPATH_DESCRIPTION_INPUT}    ${description}
    Click Save
    Wait Until Page Contains    ${account_name}    timeout=30 seconds

    Open Account Details
    Page Should Contain    ${account_name}
    Page Should Contain    ${phone}
    Page Should Contain    ${website}
    Page Should Contain    ${description}

*** Keywords ***
Login To Salesforce And Open Accounts
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
    Go To    ${url_parts}[0]/lightning/o/Account/list
    Wait Until Element Is Visible    ${XPATH_NEW_ACCOUNT}    timeout=60 seconds

Open New Account Form
    Click Element    ${XPATH_NEW_ACCOUNT}
    Wait Until Element Is Visible    ${XPATH_ACCOUNT_NAME_INPUT}

Click Save
    Wait Until Element Is Enabled    ${XPATH_SAVE_BUTTON}
    Click Element    ${XPATH_SAVE_BUTTON}

Open Account Details
    Wait Until Element Is Visible    ${XPATH_DETAILS_TAB}
    Click Element    ${XPATH_DETAILS_TAB}
