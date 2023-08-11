#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"
R=$(($RANDOM % 1000 + 1))
echo Enter your username:
read username
names=$($PSQL "SELECT * FROM names WHERE username='$username'")
if [[ -z $names ]]
then
  INSERT_NAMES=$($PSQL "INSERT INTO names VALUES('$username', 0, 9999)")
  echo Welcome, $username! It looks like this is your first time here.
else
  echo "$names" | while IFS='|' read username games_played best_game
  do
    echo Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses.
  done
fi
secret_number=0
number_of_guesses=0
echo Guess the secret number between 1 and 1000:
while [[ $secret_number -ne $R ]]
do
  read secret_number
  if [[ $secret_number =~ ^[0-9]*$ ]]
  then
    number_of_guesses=$(($number_of_guesses + 1))
    if [[ $secret_number -eq $R ]]
    then
      echo You guessed it in $number_of_guesses tries. The secret number was $secret_number. Nice job!
      UPDATE_NAMES=$($PSQL "UPDATE names set games_played=games_played+1,best_game=case when(best_game>$number_of_guesses) then $number_of_guesses else best_game end where username='$username'")
    else
      if [[ $secret_number -gt $R ]]
      then
        echo "It's higher than that, guess again:"
      else
        echo "It's lower than that, guess again:"
      fi
    fi
  else
    echo That is not an integer, guess again:
  fi
done
