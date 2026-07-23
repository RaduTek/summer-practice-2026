*** Settings ***
Resource  ../resources/keywords.robot
Resource  ../resources/variables.robot

Test Setup    Load Project

*** Test Cases ***
Login with no credentials
    Attempt Invalid Login    ${EMPTY}    ${EMPTY}    ${EMPTY}

Login with valid credentials
    Attempt Login

Login with invalid credentials
    Attempt Invalid Login    INVALID    INVALID

Login with valid user and invalid password
    Fail    Test case not implemented yet

Login with invalid user and valid password
    Fail    Test case not implemented yet


*** Keywords ***
Attempt Invalid Login 
    [Documentation]
    ...    Attempt to login with bad credentials, and expect error
    [Arguments]
    ...    ${username}
    ...    ${password}
    ...    ${error_message}=Invalid credentials
    
    Run Keyword And Expect Error    *
    ...    Attempt Login    ${username}    ${password}
    
    IF    "${error_message}" != "${EMPTY}"
        Wait For Elements State    "${error_message}"
    END