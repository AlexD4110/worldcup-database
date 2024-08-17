#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Empty the tables
echo $($PSQL "TRUNCATE TABLE games, teams")

# Read from games.csv and insert data
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
    # Skip the header row
    if [[ $YEAR != "year" ]]
    then
        # Insert teams if they don't exist
        # Winner
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
        if [[ -z $WINNER_ID ]]
        then
            INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
            if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
            then
                echo Inserted into teams, $WINNER
            fi
            WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
        fi

        # Opponent
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
        if [[ -z $OPPONENT_ID ]]
        then
            INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
            if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
            then
                echo Inserted into teams, $OPPONENT
            fi
            OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
        fi

        # Insert game
        INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
        if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
        then
            echo Inserted into games, $YEAR : $ROUND
        fi
    fi
done