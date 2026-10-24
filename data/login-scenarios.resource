*** Settings ***
Documentation    Purpose: verify the authorized test user reaches Lightning, including an email verification challenge when Salesforce presents one. Expected: the URL contains /lightning/. Salesforce and mailbox credentials come only from secure environment variables, never fixture data. The code is read from a new inbox message after this login attempt. UI controls are briefly highlighted before interaction so their selection is visually apparent. No acceptance-criteria ID was supplied.

*** Variables ***
${LOGIN_EXPECTED_PATH}    /lightning/
${LOGIN_MFA_CODE_LABEL}    Código de verificação
${LOGIN_MFA_VERIFY_BUTTON}    Verificar
${LOGIN_MFA_EMAIL_SENDER}    %{SF_MFA_EMAIL_SENDER=noreply@salesforce.com}
${LOGIN_MFA_IMAP_HOST}    %{SF_MFA_IMAP_HOST=imap.gmail.com}
