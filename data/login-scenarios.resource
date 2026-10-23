*** Settings ***
Documentation    Purpose: verify the authorized test user reaches Lightning. Expected: the URL contains /lightning/. Credentials come only from secure environment variables, never fixture data. No acceptance-criteria ID was supplied.

*** Variables ***
${LOGIN_EXPECTED_PATH}    /lightning/
