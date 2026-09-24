#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNERGOALS OPPONENTGOALS
do
  # skip the first row of column headers (e.g. line starts with 'year')
  if [[ $YEAR != year ]]
  then
    # get winner_id (see if it already exists in teams table)
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # if record is not found in teams
    if [[ -z $WINNER_ID ]]
    then
      # insert team to teams table
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
      # check response to make sure record was inserted correctly
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        # echo nice 'inserted' message
        echo Inserted into teams, $WINNER
      fi
      # get new winner_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # get opponent_id (see if it already exists in teams table)
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # if not found
    if [[ -z $OPPONENT_ID ]]
    then
      # insert team to teams table
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
      # check response to make sure record was inserted correctly
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        # echo 'inserted' message
        echo Inserted into teams, $OPPONENT
      fi
      # get opponent_id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi
    # insert game
    INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNERGOALS, $OPPONENTGOALS)")
    # check response to make sure record was inserted correctly
    if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]
    then
      # echo an 'inserted' message
      echo Inserted into games: year=$YEAR, round=$ROUND, winner_id=$WINNER_ID, opponent_id=$OPPONENT_ID, winner_goal=$WINNERGOALS, opponent_goals=$OPPONENTGOALS
    fi
  fi
done
