*** Settings ***
Library  Browser    enable_presenter_mode=True

Resource  ./variables.robot


*** Keywords ***

Load Project
    [Documentation]
    ...    Open a new Robot Framework Browser window and navigate to the project
    New Browser    headless=False     timeout=60s
    New Context    viewport={'width': 1280, 'height': 800}
    New Page       ${FRONTEND_URL}

Attempt Login
    [Documentation]
    ...    Attempt to login with given credentials
    [Arguments]
    ...    ${username}=${TEST_USER}    
    ...    ${password}=${TEST_PASSWORD}    
    ...    ${url}=${FRONTEND_URL}
    
    Go To    ${url}

    Wait For Elements State    span:has-text("Login")

    Type Text    input#username    ${username}
    Type Secret  input#password    $password

    Click    button:has-text("Login")
    
    Check Logged In

Check Logged In
    [Documentation]
    ...    Check that the user is logged in (sidebar menu options are visible)
    Wait For Elements State    span:has-text("Home")
    Wait For Elements State    span:has-text("Devices")

Load Project and Login
    [Documentation]
    ...    Start a browser session and login with the default user ${TEST_USER}
    Load Project
    Attempt Login

Go To Page
    [Documentation]
    ...    Navigate to a page available in the sidebar
    [Arguments]
    ...    ${page}
    
    Click    span:has-text("${page}")

Add New Device
    [Documentation]
    ...    Add a new device (must already be on the Devices page)
    [Arguments]
    ...    ${device_name}
    ...    ${device_sl_no}
    ...    ${device_type}
    ...    ${hw_type}
    ...    ${site}
    ...    ${group}
    ...    ${owner}
    ...    ${ip}
    ...    ${port}
    ...    ${connectivity_type}
    ...    ${login_user}=${EMPTY}
    ...    ${password}=${EMPTY}
    ...    ${read_community}=${EMPTY}
    ...    ${write_community}=${EMPTY}
    
    Click    button:has-text("Add Device")

    Fill Text    css=input[name="deviceName"]    ${device_name}
    Fill Text    css=input[name="deviceSlNo"]    ${device_sl_no}
    Fill Text    css=input[name="deviceType"]    ${device_type}
    Fill Text    css=input[name="hwType"]    ${hw_type}
    Fill Text    css=input[name="site"]    ${site}
    Fill Text    css=input[name="group"]    ${group}
    Fill Text    css=input[name="owner"]    ${owner}
    Fill Text    css=input[name="ip"]    ${ip}
    Fill Text    css=input[name="port"]    ${port}

    Click    css=#add-device-form [role="combobox"]
    Click    css=li[data-value="${connectivity_type}"]

    IF    '${connectivity_type}' == 'ssh'
        Fill Text    css=input[name="loginUser"]    ${login_user}
        Fill Text    css=input[name="password"]    ${password}
    ELSE IF    '${connectivity_type}' == 'snmp'
        Fill Text    css=input[name="readCommunity"]    ${read_community}
        Fill Text    css=input[name="writeCommunity"]    ${write_community}
    ELSE
        Fail    Unsupported connectivity type: ${connectivity_type}
    END

    Click    button:has-text("Submit")

    Wait For Elements State    css=#add-device-form    detached

Check Device Info
    [Documentation]
    ...    Check device information for given name in the devices table.
    ...    Any argument left as ${IGNORE} is not checked.
    [Arguments]
    ...    ${device_name}=${IGNORE}
    ...    ${device_sl_no}=${IGNORE}
    ...    ${device_type}=${IGNORE}
    ...    ${hw_type}=${IGNORE}
    ...    ${site}=${IGNORE}
    ...    ${group}=${IGNORE}
    ...    ${owner}=${IGNORE}
    ...    ${connectivity_type}=${IGNORE}
    ...    ${ip}=${IGNORE}
    ...    ${port}=${IGNORE}

    # The table renders connectivity data in a single "Connection" column as
    # "{type} | {ip}:{port}", defaulting any missing value to "-".
    ${connection}=    Set Variable    ${IGNORE}
    IF    '${connectivity_type}' != '${IGNORE}' or '${ip}' != '${IGNORE}' or '${port}' != '${IGNORE}'
        ${conn_type}=    Set Variable If    '${connectivity_type}' == '${IGNORE}'    -    ${connectivity_type}
        ${conn_ip}=      Set Variable If    '${ip}' == '${IGNORE}'                   -    ${ip}
        ${conn_port}=    Set Variable If    '${port}' == '${IGNORE}'                 -    ${port}
        ${connection}=    Set Variable    ${conn_type} | ${conn_ip}:${conn_port}
    END

    @{expected_values}    Create List
    ...    ${device_sl_no}
    ...    ${device_type}
    ...    ${hw_type}
    ...    ${site}
    ...    ${group}
    ...    ${owner}
    ...    ${connection}

    ${rows}=    Get Elements    css=table.MuiTable-root tbody > tr

    ${row_found}=    Set Variable    ${False}

    FOR    ${row}    IN    @{rows}
        ${columns}=    Get Elements    ${row} >> css=td
        ${col_name}=   Get Text        ${columns}[0]

        Log    ${col_name}

        IF    '${col_name}' == '${device_name}'
            ${row_found}=    Set Variable    ${True}
            FOR    ${i}    IN RANGE    0    7
                IF    '${expected_values}[${i}]' == '${IGNORE}'    CONTINUE
                ${table_index}=    Evaluate                    ${i} + 1
                ${text}=           Get Text                    ${columns}[${table_index}]
                Should Be Equal    ${expected_values}[${i}]    ${text}
            END
        END
    END

    IF    not ${row_found}
        Fail    Row with name '${device_name}' not found
    END

Remove All Devices
    [Documentation]
    ...    Removes all devices

    ${rows}=  Get Element Count    css=table.MuiTable-root tbody > tr

    WHILE    ${rows} > 0
        ${rows}=       Evaluate        ${rows} - 1
        
        # Click the button in the last column
        ${button}=    Get Element    css=table.MuiTable-root tbody > tr:last-child >> td:last-child >> button
        Click         ${button}
        Click         li:has-text("Remove")
    END

Click Device Option
    [Documentation]
    ...    Clicks the action button on the row where the device name matches.
    [Arguments]
    ...    ${name}
    ...    ${option}

    ${rows}=    Get Elements    css=table.MuiTable-root tbody > tr
    ${row_found}=    Set Variable    ${False}

    FOR    ${row}    IN    @{rows}
        ${columns}=    Get Elements    ${row} >> css=td
        ${col_name}=   Get Text        ${columns}[0]

        IF    '${col_name}' == '${name}'
            # Click the button in the last column
            ${button}=     Get Element    ${columns}[-1] >> css=button
            Click          ${button}
            Click          "${option}"
            ${row_found}=  Set Variable   ${True}
            Exit For Loop
        END
    END

    IF    not ${row_found}
        Fail    Row with name '${name}' not found
    END

Click Device Option by Index
    [Documentation]
    ...    Clicks the action button on the row where the device name matches.
    [Arguments]
    ...    ${index}
    ...    ${option}

    ${row}=     Get Element    css=table.MuiTable-root tbody > tr:nth-child(${index})
    ${button}=  Get Element    ${row} >> css=td:last-child > button
    Click       ${button}
    Click       li:has-text("${option}")


Edit Device
    [Documentation]
    ...    Edit a given device details
    [Arguments]
    ...    ${name}
    ...    ${newName}=${EMPTY}
    ...    ${group}=${EMPTY}
    ...    ${on_time}=${EMPTY}
    ...    ${off_time}=${EMPTY}
    ...    ${count}=${EMPTY}
    ...    ${consumption}=${EMPTY}
    
    Click Device Option    ${name}    Edit

    IF    "${newName}" != "${EMPTY}"
        Fill Text    ((//div)[contains(@class, 'MuiDialogContent-root')]//input)[1]    ${newName}
    END

    Click    button:has-text("Update")