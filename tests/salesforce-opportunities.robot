*** Settings ***
Documentation       Salesforce Opportunity creation test using the existing Robot Framework and SeleniumLibrary stack. Opportunity form locators require confirmation against the target org DOM.
Library             SeleniumLibrary    timeout=15 seconds    implicit_wait=0 seconds    run_on_failure=Capture Page Screenshot
Library             OperatingSystem
Library             String
Suite Setup         Login To Salesforce And Open Opportunities
Suite Teardown      Close All Browsers

*** Variables ***
${LOGIN_URL}                    %{SF_LOGIN_URL=https://q4sureplatform.my.salesforce.com}
${BROWSER}                      %{SF_BROWSER=chrome}
${XPATH_USERNAME}               xpath=//input[@id='username']
${XPATH_PASSWORD}               xpath=//input[@id='password']
${XPATH_LOGIN_BUTTON}           xpath=//input[@id='Login']
${XPATH_NEW_OPPORTUNITY}        xpath=//button[@title='New' or normalize-space(.)='New'] | //a[@title='New']
${XPATH_OPPORTUNITY_NAME}       xpath=//input[@name='Name' or @aria-label='Opportunity Name']
${XPATH_CLOSE_DATE}             xpath=//input[@name='CloseDate' or @aria-label='Close Date']
${XPATH_STAGE_PICKLIST}         xpath=//*[@role='combobox' and (@aria-label='Stage' or @title='Stage')]
${XPATH_SAVE_BUTTON}            xpath=//button[@name='SaveEdit' or @title='Save' or normalize-space(.)='Save']
${XPATH_DETAILS_TAB}            xpath=//*[@role='tab' and normalize-space(.)='Details']

*** Test Cases ***
Criar Oportunidade E Validar Dados
    [Documentation]    Cria uma Opportunity com Stage e Close Date configurados para a org e verifica o registro salvo.
    [Tags]    salesforce    lightning    opportunity    smoke

    ${suffix}=          Generate Random String    8    [LOWER][NUMBERS]
    ${opportunity_name}=    Set Variable    Robot Opportunity ${suffix}
    ${stage}=           Get Environment Variable    SF_OPPORTUNITY_STAGE
    ${close_date}=      Get Environment Variable    SF_OPPORTUNITY_CLOSE_DATE
    Should Not Be Empty    ${stage}    Configure SF_OPPORTUNITY_STAGE with a valid Stage label from the target org.
    Should Not Be Empty    ${close_date}    Configure SF_OPPORTUNITY_CLOSE_DATE in the format accepted by the target org.

    Open New Opportunity Form
    Input Text    ${XPATH_OPPORTUNITY_NAME}    ${opportunity_name}
    Input Text    ${XPATH_CLOSE_DATE}    ${close_date}
    Select Opportunity Stage    ${stage}
    Click Save
    Wait Until Page Contains    ${opportunity_name}    timeout=30 seconds

    Open Opportunity Details
    Page Should Contain    ${opportunity_name}
    Page Should Contain    ${stage}

*** Keywords ***
Login To Salesforce And Open Opportunities
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
    Go To    ${url_parts}[0]/lightning/o/Opportunity/list
    Wait Until Element Is Visible    ${XPATH_NEW_OPPORTUNITY}    timeout=60 seconds

Open New Opportunity Form
    Click Element    ${XPATH_NEW_OPPORTUNITY}
    Wait Until Element Is Visible    ${XPATH_OPPORTUNITY_NAME}

Select Opportunity Stage
    [Arguments]    ${stage}

    Click Element    ${XPATH_STAGE_PICKLIST}
    ${stage_option}=    Set Variable    xpath=//*[@role='option' and normalize-space(.)='${stage}']
    Wait Until Element Is Visible    ${stage_option}
    Click Element    ${stage_option}

Click Save
    Wait Until Element Is Enabled    ${XPATH_SAVE_BUTTON}
    Click Element    ${XPATH_SAVE_BUTTON}

Open Opportunity Details
    Wait Until Element Is Visible    ${XPATH_DETAILS_TAB}
    Click Element    ${XPATH_DETAILS_TAB}
