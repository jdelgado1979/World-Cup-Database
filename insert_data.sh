#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams"); 

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS  
do 
  if [[ $WINNER != "winner" ]]; then
    echo "Processing game: $YEAR, $ROUND, $WINNER, $OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS"
    
    # Get winner_id 
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'") 
    echo "Winner ID: $WINNER_ID"
    
    # If winner not found, insert into teams table 
    if [[ -z $WINNER_ID ]]; then
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')") 
      echo "Inserted into teams, $WINNER" 
      # Get new winner_id 
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'") 
      echo "New Winner ID: $WINNER_ID"
    fi 

    # Get loser_id 
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    echo "Opponent ID: $OPPONENT_ID"
    
    # If loser not found, insert into teams table 
    if [[ -z $OPPONENT_ID ]]; then
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')") 
      echo "Inserted into teams, $OPPONENT" 
      # Get new loser_id 
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'") 
      echo "New Opponent ID: $OPPONENT_ID"
    fi 
    
    # Insert into games table 
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    
    if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]]; then 
      echo "Inserted into games, winner: $WINNER, opponent: $OPPONENT" 
    fi 
  fi
done