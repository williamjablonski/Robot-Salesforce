*** Settings ***
Documentation       End-to-end Salesforce Lightning examples using Robot Framework and SeleniumLibrary only.
Library             SeleniumLibrary    timeout=15 seconds    implicit_wait=0 seconds    run_on_failure=Capture Page Screenshot
Library             String
Library             OperatingSystem
Suite Setup         Login To Salesforce And Open Accounts
Suite Teardown      Close All Browsers

*** Variables ***
${LOGIN_URL}                    %{SF_LOGIN_URL=https://test.salesforce.com}
${LIGHTNING_URL}                %{SF_LIGHTNING_URL=https://YOUR-DOMAIN.lightning.force.com}
${BROWSER}                      %{SF_BROWSER=chrome}
${ACCOUNT_LIST_URL}             ${LIGHTNING_URL}/lightning/o/Account/list

# Keep XPath locators in one place. Prefer stable attributes and accessible labels;
# avoid generated Salesforce IDs, positional indexes, and styling-only class names.
${XPATH_USERNAME}               xpath=//input[@id='username']
${XPATH_PASSWORD}               xpath=//input[@id='password']
${XPATH_LOGIN_BUTTON}           xpath=//input[@id='Login']
${XPATH_NEW_ACCOUNT}            xpath=//button[@title='New' or normalize-space(.)='New'] | //a[@title='New']
${XPATH_ACCOUNT_NAME_INPUT}     xpath=//input[@name='Name' or @aria-label='Account Name']
${XPATH_PHONE_INPUT}            xpath=//input[@name='Phone' or @aria-label='Phone']
${XPATH_WEBSITE_INPUT}          xpath=//input[@name='Website' or @aria-label='Website']
${XPATH_DESCRIPTION_INPUT}      xpath=//textarea[@name='Description' or @aria-label='Description']
${XPATH_SAVE_BUTTON}            xpath=//button[@name='SaveEdit' or @title='Save' or normalize-space(.)='Save']
${XPATH_EDIT_BUTTON}            xpath=//button[@name='Edit' or @title='Edit' or normalize-space(.)='Edit']
${XPATH_DETAILS_TAB}            xpath=//*[@role='tab' and normalize-space(.)='Details']
${XPATH_REQUIRED_ERROR}         xpath=//*[self::div or self::span][contains(normalize-space(.),'Complete this field')]

*** Test Cases ***
Create Account And Verify Details
    [Documentation]    Creates an Account with realistic fields and verifies the saved record.
    [Tags]    salesforce    lightning    xpath    smoke

    ${suffix}=          Generate Random String    8    [LOWER][NUMBERS]
    ${account_name}=    Set Variable    Copado XPath Create ${suffix}
    ${phone}=           Generate Test Phone
    ${website}=         Set Variable    https://example.com/copado-${suffix}
    ${description}=     Set Variable    Created by the Robot Framework XPath example ${suffix}

    Open New Account Form
    Fill Account Form    ${account_name}    ${phone}    ${website}    ${description}
    Save Account    ${account_name}
    Open Account Details
    Account Details Should Contain    ${account_name}    ${phone}    ${website}    ${description}

Update Account And Verify Changed Values
    [Documentation]    Creates an Account, edits key fields, then verifies the persisted values.
    [Tags]    salesforce    lightning    xpath    regression

    ${suffix}=              Generate Random String    8    [LOWER][NUMBERS]
    ${account_name}=        Set Variable    Copado XPath Update ${suffix}
    ${phone_digits}=        Generate Random String    8    [NUMBERS]
    ${old_phone}=           Set Variable    555${phone_digits}
    ${new_phone}=           Set Variable    444${phone_digits}
    ${old_website}=         Set Variable    https://example.com/before-${suffix}
    ${new_website}=         Set Variable    https://example.com/after-${suffix}
    ${description}=         Set Variable    Updated by the Robot Framework XPath example ${suffix}

    Open New Account Form
    Fill Account Form    ${account_name}    ${old_phone}    ${old_website}    ${description}
    Save Account    ${account_name}
    Edit Current Account    ${new_phone}    ${new_website}
    Open Account Details
    Account Details Should Contain    ${account_name}    ${new_phone}    ${new_website}    ${description}

Account Name Is Required
    [Documentation]    Confirms that Salesforce prevents saving a new Account without its required name.
    [Tags]    salesforce    lightning    xpath    validation

    Open New Account Form
    Click Save
    Wait Until Element Is Visible    ${XPATH_REQUIRED_ERROR}
    Page Should Contain    Complete this field

*** Keywords ***
Login To Salesforce And Open Accounts
    Should Not Be Equal    ${LIGHTNING_URL}    https://YOUR-DOMAIN.lightning.force.com
    ${username}=    Get Environment Variable    SF_USERNAME
    ${password}=    Get Environment Variable    SF_PASSWORD
    Should Not Be Empty    ${username}    SF_USERNAME must be configured as a secure environment variable.
    Should Not Be Empty    ${password}    SF_PASSWORD must be configured as a secure environment variable.

    Open Browser    ${LOGIN_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    ${XPATH_USERNAME}
    Input Text    ${XPATH_USERNAME}    ${username}
    Input Password    ${XPATH_PASSWORD}    ${password}
    Click Element    ${XPATH_LOGIN_BUTTON}

    # Complete the organization's approved SSO/MFA flow before relying on the session.
    Go To    ${ACCOUNT_LIST_URL}
    Wait Until Element Is Visible    ${XPATH_NEW_ACCOUNT}    timeout=60 seconds

Open New Account Form
    Go To    ${ACCOUNT_LIST_URL}
    Wait Until Element Is Visible    ${XPATH_NEW_ACCOUNT}
    Click Element    ${XPATH_NEW_ACCOUNT}
    Wait Until Element Is Visible    ${XPATH_ACCOUNT_NAME_INPUT}

Fill Account Form
    [Arguments]    ${account_name}    ${phone}    ${website}    ${description}

    Input Text    ${XPATH_ACCOUNT_NAME_INPUT}    ${account_name}
    Input Text    ${XPATH_PHONE_INPUT}    ${phone}
    Input Text    ${XPATH_WEBSITE_INPUT}    ${website}
    Input Text    ${XPATH_DESCRIPTION_INPUT}    ${description}

Save Account
    [Arguments]    ${account_name}

    Click Save
    Wait Until Page Contains    ${account_name}    timeout=30 seconds

Click Save
    Wait Until Element Is Enabled    ${XPATH_SAVE_BUTTON}
    Click Element    ${XPATH_SAVE_BUTTON}

Edit Current Account
    [Arguments]    ${phone}    ${website}

    Wait Until Element Is Visible    ${XPATH_EDIT_BUTTON}
    Click Element    ${XPATH_EDIT_BUTTON}
    Wait Until Element Is Visible    ${XPATH_ACCOUNT_NAME_INPUT}
    Clear Element Text    ${XPATH_PHONE_INPUT}
    Input Text    ${XPATH_PHONE_INPUT}    ${phone}
    Clear Element Text    ${XPATH_WEBSITE_INPUT}
    Input Text    ${XPATH_WEBSITE_INPUT}    ${website}
    Click Save
    Wait Until Page Contains    ${phone}    timeout=30 seconds

Open Account Details
    Wait Until Element Is Visible    ${XPATH_DETAILS_TAB}
    Click Element    ${XPATH_DETAILS_TAB}

Account Details Should Contain
    [Arguments]    ${account_name}    ${phone}    ${website}    ${description}

    Wait Until Page Contains    ${account_name}    timeout=20 seconds
    Page Should Contain    ${phone}
    Page Should Contain    ${website}
    Page Should Contain    ${description}

Generate Test Phone
    ${digits}=    Generate Random String    8    [NUMBERS]
    RETURN    555${digits}
