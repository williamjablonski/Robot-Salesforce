*** Settings ***
Documentation    Purpose: create a synthetic Contact. Expected: the saved record shows the generated first name, last name, and email. Each run appends a unique suffix; records remain for authorized sandbox inspection. No acceptance-criteria ID was supplied.

*** Variables ***
${CONTACT_FIRST_NAME_LABEL}    First Name
${CONTACT_LAST_NAME_LABEL}    Last Name
${CONTACT_EMAIL_LABEL}    Email
${CONTACT_TEST_FIRST_NAME}    Robot
${CONTACT_TEST_LAST_NAME_PREFIX}    Contact
${CONTACT_TEST_EMAIL_PREFIX}    robot.contact.
${CONTACT_TEST_EMAIL_DOMAIN}    @example.com
