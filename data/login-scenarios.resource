*** Settings ***
Documentation    Purpose: verify the authorized test user reaches Lightning. The observed login flow requests a username first, then a password. Expected: the URL contains /lightning/. Credentials come only from secure environment variables, never fixture data. No acceptance-criteria ID was supplied.

*** Variables ***
${LOGIN_EXPECTED_PATH}    /lightning/
