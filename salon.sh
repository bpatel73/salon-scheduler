#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=postgres --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
    echo -e "$1"

    AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")

    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
        echo "$SERVICE_ID) $NAME"
    done

    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
        MAIN_MENU "\nThat is not a valid choice, please try again."
    else
        SERVICE_FOUND=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

        if [[ -z $SERVICE_FOUND ]]
        then
            MAIN_MENU "\nI could not find that service.  What would you like today?"
        else
            SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
            echo -e "\nWhat's your phone number?"
            read PHONE_NUMBER
            CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$PHONE_NUMBER'")

            if [[ -z $CUSTOMER_NAME ]]
            then
                echo -e "\nI don't have a record for that phone number, what's your name?"
                read CUSTOMER_NAME
                INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$PHONE_NUMBER')")
            fi
            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$PHONE_NUMBER'")
            SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')
            CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
            echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
            read SERVICE_TIME
            INSERT_APPT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")
            echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
        fi
    fi
}
MAIN_MENU "Welcome to My Salon, how can I help you?\n"