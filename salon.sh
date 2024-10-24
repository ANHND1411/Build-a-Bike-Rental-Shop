#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICE_LIST() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nWhat service do you want?" 
  SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
  echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

SERVICE_MENU() {
  read SERVICE_ID_SELECTED
  

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
      # send to service menu
      SERVICE_LIST "That is not a valid service number."
  else
     # get service availability
      SERVICE_ID_CHECK=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED ")
      
      if [[ -z $SERVICE_ID_CHECK ]]
      then
       SERVICE_LIST "That service is not available."
      else
        echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
   
      if [[ -z $CUSTOMER_ID ]]
      then
      echo -e "\nYour information is not exist."
      echo -e "\nEnter your name:"
      read CUSTOMER_NAME
      CUSTOMER_UPDATE=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      echo "Insert info success. Name: $CUSTOMER_NAME .Phone: $CUSTOMER_PHONE"
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = '$CUSTOMER_ID'")
    
      fi
      fi
  fi
  
  echo -e "\nWhen do you want to do this service?"
    read SERVICE_TIME
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^ //g')
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ //g')
    INSERT_APPOINMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo "I have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
}


SERVICE_LIST
SERVICE_MENU

