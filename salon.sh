#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ The Salon ~~~~~\n"
echo -e "Please select a service:"

SELECT_SERVICE() {
  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id,name FROM services ORDER BY service_id;")

  # print available services
  echo "$AVAILABLE_SERVICES" | while read SERVICE BAR NAME
  do
    echo $SERVICE")" $NAME
  done

  # get requested service
  read SERVICE_ID_SELECTED
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  # if not found
  if [[ -z $SERVICE_ID ]]
  then
    # reprint list of services and get selection again
    SELECT_SERVICE
  else
    # schedule appointment for customer for selected service
    SCHEDULE_APPOINTMENT $SERVICE_ID
  fi  
}

SCHEDULE_APPOINTMENT() {
  # get cutomer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
  # if not found
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get new customer's name
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone,name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME');")
  fi
  # get requested time
  echo -e "\nWhat time shall I put you down for?"
  read SERVICE_TIME
  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
  # insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID,'$SERVICE_TIME');")
  # get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID;")
  # notify customer that appointment has now been scheduled
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
}

SELECT_SERVICE