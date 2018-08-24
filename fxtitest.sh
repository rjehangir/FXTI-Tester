#!/bin/bash

# Define test parameters
INTERFACE=eth1
PING_LISTENER_IP=192.168.2.2
FATHOMX_TIMEOUT=10              # seconds
SLEEP_TIMEOUT=0.1               # seconds

# Define status LED pins
JIG_READY_LED_PIN=21
USB_PASS_LED_PIN=22
FATHOMX_PASS_LED_PIN=23
FXTI_PASS_LED_PIN=24
FXTI_FAIL_LED_PIN=25

# Define States
STATE_READY=0
STATE_USB_CONNECTED=1
STATE_FATHOMX_CONNECTED=2
STATE_FATHOMX_TIMEOUT=3

# Initialize State to "READY"
STATE=$STATE_READY

# Configure GPIO pins
gpio mode $JIG_READY_LED_PIN out
gpio mode $USB_PASS_LED_PIN out
gpio mode $FATHOMX_PASS_LED_PIN out
gpio mode $FXTI_PASS_LED_PIN out
gpio mode $FXTI_FAIL_LED_PIN out

# Signal that the jig is ready
gpio write $JIG_READY_LED_PIN 1

# Initialize pass/fail status LEDs to off
gpio write $USB_PASS_LED_PIN 0
gpio write $FATHOMX_PASS_LED_PIN 0
gpio write $FXTI_PASS_LED_PIN 0
gpio write $FXTI_FAIL_LED_PIN 0

# Initialize USB connection time
USB_CONNECT_TIME=$SECONDS

# Loop
while true; do
    # Test for interface (USB test)
    ifconfig $INTERFACE
    USB_CONNECTION=$?

    # Test for network (Fathom-X) connection
    ping $PING_LISTENER_IP -i 0.2 -c 4 -w 1 -q
    FATHOMX_CONNECTION=$?

    case $STATE in
        $STATE_READY)
            # Check USB connection
            if [ $USB_CONNECTION -eq 0 ]; then
                # Illuminate USB_PASS_LED
                gpio write $USB_PASS_LED_PIN 1

                # Record USB connection time
                USB_CONNECTION_TIME=$SECONDS

                # Move to STATE_USB_CONNECTED
                STATE=$STATE_USB_CONNECTED
            fi
            ;;
        $STATE_USB_CONNECTED)
            # Check USB Connection
            if [ $USB_CONNECTION -ne 0 ]; then
                # Extinguish USB_PASS_LED
                gpio write $USB_PASS_LED_PIN 0

                # Move to STATE_READY
                STATE=$STATE_READY

            # Check Fathom-X Connection
            elif [ $FATHOMX_CONNECTION -eq 0 ]; then
                # Illuminate FATHOMX_PASS_LED
                gpio write $FATHOMX_PASS_LED_PIN 1

                # Illuminate FXTI_PASS_LED
                gpio write $FXTI_PASS_LED_PIN 1

                # Move to STATE_FATHOMX_CONNECTED
                STATE=$STATE_FATHOMX_CONNECTED

            # Check for Fathom-X Timeout
            elif [ $SECONDS - $USB_CONNECTION_TIME -gt $FATHOMX_TIMEOUT ]; then
                # Illuminate FXTI_FAIL_LED
                gpio write $FXTI_FAIL_LED

                # Move to STATE_FATHOMX_TIMEOUT
                STATE=$STATE_FATHOMX_TIMEOUT
            fi
            ;;
        $STATE_FATHOMX_CONNECTED)
            # Check USB Connection
            if [ $USB_CONNECTION -ne 0 ]; then
                # Extinguish USB_PASS_LED
                gpio write $USB_PASS_LED_PIN 0

                # Extinguish FATHOMX_PASS_LED
                gpio write $FATHOMX_PASS_LED_PIN 0

                # Extinguish FXTI_PASS_LED
                gpio write $FXTI_PASS_LED_PIN 0

                # Move to STATE_READY
                STATE=$STATE_READY

            # Check Fathom-X Connection
            elif [ $FATHOMX_CONNECTION -ne 0 ]; then
                # Extinguish FATHOMX_PASS_LED
                gpio write $FATHOMX_PASS_LED_PIN 0

                # Extinguish FXTI_PASS_LED
                gpio write $FXTI_PASS_LED_PIN 0

                # Record "USB connection time"
                USB_CONNECTION_TIME=$SECONDS

                # Move to STATE_USB_CONNECTED
                STATE=$STATE_USB_CONNECTED
            fi
            ;;
        $STATE_FATHOMX_TIMEOUT)
            # Check USB Connection
            if [ $USB_CONNECTION -ne 0 ]; then
                # Extinguish USB_PASS_LED
                gpio write $USB_PASS_LED_PIN 0

                # Extinguish FXTI_FAIL_LED
                gpio write $FXTI_FAIL_LED_PIN 0

                # Move to STATE_READY
                STATE=$STATE_READY

            # Check Fathom-X Connection
            elif [ $FATHOMX_CONNECTION -eq 0 ]; then
                # Illuminate FATHOMX_PASS_LED
                gpio write $FATHOMX_PASS_LED_PIN 1
                
                # Extinguish FATHOMX_FAIL_LED
                gpio write $FATHOMX_FAIL_LED_PIN 0

                # Illuminate FXTI_PASS_LED
                gpio write $FXTI_PASS_LED_PIN 1

                # Move to STATE_USB_CONNECTED
                STATE=$STATE_FATHOMX_CONNECTED
            fi
            ;;
    esac

    sleep $SLEEP_TIMEOUT
done

