ViHero
======

A simple game for learning to associate h,j,k,l with left, down, up, right, written as a console app in ruby

Instructions

Start the game by running ViHero.rb

The first screen will ask you to choose your settings.
* Difficulty determines how long each command stays on screen for you to react and press the associated h,j,k,l key.
*   Easy difficulty: 5 seconds per command
*   Normal difficulty: 3 seconds per command
*   Hard difficulty: 1 second per command
  
* Duration determines how many commands will be in a session.
*   Short duration is 10 commands
*   Medium duration is 30 commands
*   Long duration is 99 commands
  
You can change the settings here by pressing the first letter of the setting you want: E/N/H and S/M/L
Press Enter to begin the game with the shown settings.

The second screen is the actual game. It will display a warmup countdown before the game begins. After the warmup,
commands will appear in the center of the screen and scroll to the left. Each command displays a direction in English,
either Up, Down, Left or Right. Pressing the corresponding Vi direction (h,j,k,l) will clear the command and begin
the next one. If the command scrolls all the way off the screen, or the wrong direction is pressed, you will be penalized
and the next command will begin. As the command scrolls, it changes color to represent how little time remaining it has.

* Green commands have between their full time and 2/3rds of their time remaining.
* Yellow commands have between 1/3rd and 2/3rds of their time remaining.
* Red commands have 1/3rd or less time remaining.

At the bottom of the screen, you will see two lines of characters. The first line displays the command history, using
<, v, ^, > to represent left, down, up, and right. Under it displays your attempt at clearing the command. If you
pressed the corresponding Vi direction, an 'o' will appear. If you pressed the incorrect Vi direction, your wrong input
will appear as a <, v, ^ or >. If the command scrolled off the screen, an 'x' will appear. For correct input, the 'o'
will be colored based on the color of the command when it was cleared.

After all commands have been cleared, the game waits for you to press Enter to advance, giving you time to review the
command history. Once you're ready, press Enter to visit the score screen.

The final screen calculates how well you performed, and gives you an overall score. It tracks two metrics: Accuracy
and Speed. 

* Accuracy is measured by how many commands you answered correctly versus total commands.
* Speed is measured by how quickly you answered commands correctly

Accuracy will be further broken down to show you how accurate you were for each direction.
Speed is further broken down to show you how many commands you cleared were Green, Yellow or Red. For the purpose of
scoring, Green commands are 3 points, Yellow are 2, and Red are 1. This is measured against a perfect score possible,
which would be if all commands cleared were still Green.

Accuracy and Speed are combined together to give you a total score at the bottom.
After reviewing your scores, you have 3 options. You can start a New Game by pressing N, which takes you back to the
settings screen. You can Retry by pressing R, which will take you directly to the game screen with the same settings.
Finally, you can Quit the game by pressing Q.
