#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

SERVICES() {
  if [[ $1 ]]
  then echo -e "\n$1"
  fi

  echo "Welcome to My Salon, how can I help you?"

  #get availabile services
  AVAIL_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  #if not available
    if [[ -z $AVAIL_SERVICES ]]
    then

    #send to services menu
    MAIN_MENU "I could not find that service. What would you like today?"
    else

    #display services
    echo "$AVAIL_SERVICES" | while read SERVICE_ID BAR NAME
      do
        echo "$SERVICE_ID) $NAME"
      done

    #user input
    read SERVICE_ID_SELECTED

      #if input is not a number
      if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]

      #send to services menu
      then SERVICES "That is not a vaild service number."
      else

      #if not available
        if [[ -z $SERVICE_ID_SELECTED ]]
        then SERVICES "That service is not available."
        else

        #get customer info
          echo -e "\nWhat's your phone number?"
          read CUSTOMER_PHONE

          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

          #if customer doesn't exist
          if [[ -z $CUSTOMER_NAME ]]
          #get new customer name
          then echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME

          #insert newm customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
          fi
        
        #get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

        #get service name
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

        #get appointment time
        echo -e "\nWhat time would you like your$SERVICE_NAME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
        read SERVICE_TIME

        #insert appointment
        INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

        #confirm statement
        echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

      fi
    fi
  fi
}

SERVICES
