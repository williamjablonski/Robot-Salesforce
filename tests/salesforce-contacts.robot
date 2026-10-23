*** Settings ***
Documentation       Salesforce Contact creation smoke test using SeleniumLibrary.
Library             SeleniumLibrary    timeout=15 seconds    implicit_wait=0 seconds    run_on_failure=Capture Page Screenshot
Library             String
Library             OperatingSystem
Suite Setup         Login To Salesforce And Open Contacts
Suite Teardown      Close All Browsers

*** Variables ***
${LOGIN_URL}                    %{SF_LOGIN_URL=https://q4sureplatform.my.salesforce.com}
${BROWSER}                      %{SF_BROWSER=chrome}
${XPATH_USERNAME}               xpath=//input[@id='username']
${XPATH_PASSWORD}               xpath=//input[@id='password']
${XPATH_LOGIN_BUTTON}           xpath=//input[@id='Login']
${XPATH_NEW_CONTACT}            xpath=//button[@title='New' or normalize-space(.)='New'] | //a[@title='New']
${XPATH_FIRST_NAME_INPUT}       xpath=//input[@name='firstName' or @aria-label='First Name']
${XPATH_LAST_NAME_INPUT}        xpath=//input[@name='lastName' or @aria-label='Last Name']
${XPATH_EMAIL_INPUT}            xpath=//input[@name='Email' or @aria-label='Email']
${XPATH_SAVE_BUTTON}            xpath=//button[@name='SaveEdit' or @title='Save' or normalize-space(.)='Save']
${XPATH_DETAILS_TAB}            xpath=//*[@role='tab' and normalize-space(.)='Details']

*** Test Cases ***
Criar Contato E Validar Dados
    [Documentation]    Cria um Contact com dados únicos e verifica o e-mail salvo no registro.
    [Tags]    salesforce    lightning    contact    smoke

    ${suffix}=          Generate Random String    8    [LOWER][NUMBERS]
    ${first_name}=      Set Variable    Robot
    ${last_name}=       Set Variable    Contato ${suffix}
    ${contact_name}=    Set Variable    ${first_name} ${last_name}
    ${email}=           Set Variable    robot.contact.${suffix}@example.com

    Open New Contact Form
    Input Text    ${XPATH_FIRST_NAME_INPUT}    ${first_name}
    Input Text    ${XPATH_LAST_NAME_INPUT}    ${last_name}
    Input Text    ${XPATH_EMAIL_INPUT}    ${email}
    Click Save
    Wait Until Page Contains    ${contact_name}    timeout=30 seconds
    Open Contact Details
    Page Should Contain    ${email}

*** Keywords ***
Login To Salesforce And Open Contacts
    ${username}=    Get Environment Variable    SF_USERNAME
    ${password}=    Get Environment Variable    SF_PASSWORD

    Open Browser    ${LOGIN_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    ${XPATH_USERNAME}
    Input Text    ${XPATH_USERNAME}    ${username}
    Input Password    ${XPATH_PASSWORD}    ${password}
    Click Element    ${XPATH_LOGIN_BUTTON}
    Wait Until Location Contains    /lightning/    timeout=60 seconds

    ${current_url}=    Get Location
    ${url_parts}=    Split String    ${current_url}    /lightning/
    Go To    ${url_parts}[0]/lightning/o/Contact/list
    Wait Until Element Is Visible    ${XPATH_NEW_CONTACT}    timeout=60 seconds

Open New Contact Form
    Click Element    ${XPATH_NEW_CONTACT}
    Wait Until Element Is Visible    ${XPATH_LAST_NAME_INPUT}

Click Save
    Wait Until Element Is Enabled    ${XPATH_SAVE_BUTTON}
    Click Element    ${XPATH_SAVE_BUTTON}

Open Contact Details
    Wait Until Element Is Visible    ${XPATH_DETAILS_TAB}
    Click Element    ${XPATH_DETAILS_TAB}
