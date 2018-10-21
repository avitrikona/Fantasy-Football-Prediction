### 1. Executive Summary:
Growth of fantasy sport coincides with increasing interest in and understanding of data. Our start-up team of data scientists at Fantasy Football Fanalytics (FFF) has leveraged this trend and used our data analysis skills to predict the best football players of the National Football League (NFL) to be picked by Fantasy Football users for the 2018 Football season.  The goal for this project is to build a prediction model to rank fantasy football players that can be sold profitably to betting companies such as DraftKings and Fan Duel as well as private users of Fantasy Football. 
</br>DraftKings - the leading commercial internet operator of the fantasy football betting system - hosts weekly competitions where users try to pick the best players on a week to week basis. DraftKings has approached our team to build a prediction model for fantasy football points of individual players. Our prediction model will help them retain their position as the leading commercial Fantasy Football betting system by improving their current model. The improvement of the model will also help them maintain their competitive advantage over their main competitor Fan Duel. The model predicts the statistics of players based on games played, and that helps DraftKings improve their model, therefore attract more customer and in that way, increase profits. Our model also estimates how rookies will perform in the NFL based on total career fantasy points. This is valuable information for players of fantasy, which again helps DraftKings become a better betting platform with more benefits for users and in the same way help increase user count and therefore profits.  Another use case for our prediction model will be to optimize the betting odds for the offered competitions, thus maximizing the profit from the money invested by users. 
From the data set that we were provided from kaggle, we were able to achieve three results: A 30% accuracy in predicting fantasy points from a linear regression model. Secondly, we attained a 60% accuracy on predicting the winner of the game with classification.  Thirdly, with the clustering approach we obtained a clear tendency of which colleges are likely to yield higher-performing players that are drafted into the NFL based on career fantasy points.

### 2. Team Name : Fantasy Football Fanalytics
### 3. Team Members
● Harshal Sanap
● Steven Ditsworth
● Muddu Appanervanda
● Karl-Ludwig Bueckle

### 4. Describe the data and problem being addressed (1 paragraph)
The data is historical records of stats for individual football players in games from the year 1950
to 2017. The data set is also key to each individual player which has over 18 variables. Our
intention is to determine which players will perform best on a fantasy football roster for the 2018
season. We can use this historical data along with individual player data to come to this
solution.

### 5 . Data description
#### a. How many rows and columns?
2 Data sets currently, Span from 1950 to 2017 in years
1. Games Data: First Data Set has 1,024,164 observations and 47 variables
(This data set has an individual player’s stats for an individual
game)
2. Player Data: Second Data Set has 25,043 observations and 18 variables
(This data set has individual player information)
#### b . What is being predicted?
We are trying to predict which players in each class will have the highest value in fantasy
points for the next season. The Positions that we will look at include</br>
● Quarterback (QB)
● Running Back (RM)
● Wide Receiver (WR)
● Kicker (K)
● Tight End (TE)</br>
Fantasy points will be determined based off basic Non-PPR leagues such as the one on
ESPN or Yahoo. Some examples of points are as follows</br>
● 1 Point per 10 yards of Running
● 6 Points per touchdown
● 1 Point per 10 yards Rushing, or to simplify, .1 points per yard.
● 2 points for over 100 yards in 1 game

● Objective 1: Predict the Fantasy points based on played games (With the help of regression models)</br>
● Objective 2: Predict a tendency for fantasy points of upcoming player’s according to the college they are drafted from (With the help of clustering models)</br>
● Objective 3: Predict the winner of a game based on the given historical game parameters (With the help of classification models)</br>

#### c. What are the datatypes of the predictors?
Games Data: Most of the data is numerical stats (game stats such as Reception yards,
touchdowns, etc), but there are some that have classification such as teams, or Geospatial data
such as location of game.
Player Data: Also mostly numerical such as height, weight, and salary but it also includes;
character data such as team and college; categorical data of position; Geospatial Data such as
location of birth, college, etc.
