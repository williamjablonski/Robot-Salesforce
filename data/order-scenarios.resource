*** Settings ***
Documentation    Purpose: create an Order related to an existing authorized Account. Expected: the saved record shows that Account, configured Effective Date, and Status. Those values must be valid for the target org and are configured externally; records remain in the authorized target org for inspection. No acceptance-criteria ID was supplied.

*** Variables ***
${ORDER_ACCOUNT_LABEL}    Account Name
${ORDER_EFFECTIVE_DATE_LABEL}    Effective Date
${ORDER_STATUS_LABEL}    Status
