# README

# Tic Tac Toe

This is the Tic Tac Toe made with Ruby on Rails with ActionCable for the assessment test of profile development.

## Main Idea
The main idea is that there are 9 tiles
with a number on them

## Technical Description

1. The game is played on a grid that's 3 squares by 3 squares.
2. You are X, your friend (or the computer in this case) is O. Players take turns putting their
   marks in empty squares.
3. The first player to get 3 of her marks in a row (up, down, across, or diagonally) is the
   winner.
4. When all 9 squares are full, the game is over. If no player has 3 marks in a row, the game
   ends in a tie.

## Rules

• After start server application should wait for two players to connect. If any of players will
disconnect, the game is over.
• Client side should ask user for its name and when waiting for second player proper message
should be displayed.
• On each turn client side should display state of the game and allow to move for one of
players (either X or O)
• When the game is over, client side should display winner name if there is such.


## Setting up docker on Ubuntu Linux (20.04)

Follow instructions here: [docs/setup-requirements-ubuntu.md](docs/setup-requirements-ubuntu.md)

### Build and start:
``docker-compose up``
### Setup db:
``docker-compose run web rake db:setup db:migrate``

### Try it out

Open a browser and navigate to [http://localhost:3000/](http://localhost:3000/)


### Run the bash command line

``docker exec -it ttt_pd-web-1 bash``

After Entering into the container, you can run the specs

by typing ``rspec`` in the command line
