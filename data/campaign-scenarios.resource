*** Settings ***
Documentation    Campaign CRUD test data. Creates one synthetic Campaign with a unique name, reads and renames that same record, then deletes only the record created by the current test. Campaign Name and Status labels and any required status value must be confirmed in the target org. Set SF_CAMPAIGN_STATUS only if the org requires a status or if a specific valid status is part of the test contract. No cleanup affects pre-existing records.

*** Variables ***
${CAMPAIGN_NAME_LABEL}    Campaign Name
${CAMPAIGN_STATUS_LABEL}    Status
${CAMPAIGN_TEST_NAME_PREFIX}    Robot Campaign
${CAMPAIGN_UPDATED_NAME_PREFIX}    Robot Campaign Updated
${CAMPAIGN_STATUS_ENV}    SF_CAMPAIGN_STATUS
${CAMPAIGN_LIST_PATH}    /lightning/o/Campaign/list
