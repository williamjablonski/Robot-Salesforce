*** Settings ***
Documentation    Basic smoke test to verify the Robot Framework setup.

*** Test Cases ***
Robot Framework Is Ready
    Should Be Equal    ${1 + 1}    ${2}
