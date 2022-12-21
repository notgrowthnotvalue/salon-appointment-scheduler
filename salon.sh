#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"


# Resets the index to 1
#echo $($PSQL "TRUNCATE TABLE customers, appointments ")
#echo $($PSQL "ALTER SEQUENCE customers_customer_id_seq RESTART WITH 1")
#echo $($PSQL "ALTER SEQUENCE services_service_id_seq RESTART WITH 1")


echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "Welcome to my Salon, how can I help you?"

  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services
  ORDER BY service_id")

  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME 
  do 
    echo "$SERVICE_ID) $NAME"
  done

  # ask for a service to select
  read SERVICE_ID_SELECTED
  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-3]$ ]]
  then 
    echo -e "\nI could not find that service. What would you like today?"
    MAIN_MENU 
  else
    # get customer phone number
    echo -e "What is your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")

    # if customer is not in the database 
    if [[ -z $CUSTOMER_NAME ]]
    then 
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # insert new customer 
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

      echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME

      # insert new appointment
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, time) VALUES('$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

    # if customer is in the database
    else 
      echo -e "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME"
      read SERVICE_TIME
      
      # insert new appointment
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID','$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."    
    fi
  fi
}

MAIN_MENU

