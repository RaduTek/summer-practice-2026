*** Settings ***
Resource  ../resources/keywords.robot
Resource  ../resources/variables.robot

Suite Setup    Load Project and Login

Test Setup    Run Keywords     
...    Go To Page    Devices    AND
...    Remove All Devices

*** Test Cases ***
Add New Device:
    Add New Device
    ...    device_name=AirScale BTS 1
    ...    device_sl_no=SN-000123
    ...    device_type=Base Station
    ...    hw_type=AirScale
    ...    site=Milan
    ...    group=TIM Test Lab
    ...    owner=admin
    ...    ip=192.168.1.10
    ...    port=22
    ...    connectivity_type=ssh
    ...    login_user=testuser
    ...    password=hunter2

    Check Device Info
    ...    device_name=AirScale BTS 1
    ...    device_sl_no=SN-000123
    ...    device_type=Base Station
    ...    hw_type=AirScale
    ...    site=Milan
    ...    group=TIM Test Lab
    ...    owner=admin
    ...    connectivity_type=ssh
    ...    ip=192.168.1.10
    ...    port=22

Edit Device:
    Click Device Option    AirScale BTS 1    Edit
    Fail    Test case not implemented yet

Remove Device:
    Fail    Test case not implemented yet