s;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; VARIABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
HEY!  LOOK HERE!  This is what you need to change in this script...

Change the %rpk_minbet and %_maxbet to the minimum and maximum
amount of points that must be spent in order to play the game.  The
%rpk_cd variable is the per user cooldown time (in seconds) that a user
must wait before being able to use !rpk again.

You will need to UNLOAD and RE-LOAD this script for any changes to the
variables below to take effect.  This can be done by pressing ALT-R in
mIRC > Select "View" > Select "rpk.mrc" > Click on "File" > "Unload."
Then, click on "File" and "Load..." and select the rpk.mrc file again.

Have fun!!!
*/

ON *:LOAD: {
  SET %rpk_minbet 1
  SET %rpk_maxbet 500
  SET %rpk_cd 120
}

ON *:UNLOAD: UNSET %rpk_*
ON *:CONNECT: {
  IF ($server == tmi.twitch.tv) {
    UNSET %rpk.*
    UNSET %RPK_CD.*
  }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; ROCK/PAPER/KATANA GAME ;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


ON $*:TEXT:/^!rpk\s(on|off)/iS:%mychan: {

  IF ($ModCheck) {
    IF ($2 == on) {
      IF (!%GAMES_RPK_ACTIVE) {
        SET %GAMES_RPK_ACTIVE On
        MSG $chan $nick $+ , the Rock/Paper/Katana game is now enabled!  Type !rpk for more info!  Have fun!  PogChamp
      }
      ELSE MSG $chan $nick $+ , !rpk is already enabled.  FailFish
    }
    ELSEIF ($2 == off) {
      IF (%GAMES_RPK_ACTIVE) {
        UNSET %GAMES_RPK_ACTIVE
        MSG $chan $nick $+ , the Rock/Paper/Katana game is now disabled.
      }
      ELSE MSG $chan $nick $+ , !rpk is already disabled.  FailFish
    }
  }
}


ON $*:TEXT:/^!rpk(\s|$)/iS:%mychan: {

  IF ($($+(%,floodRPK.,$nick),2)) halt
  SET -u3 %floodRPK. $+ $nick On
  IF (!%GAMES_RPK_ACTIVE) {
    IF ((%floodRPK_ACTIVE) || ($($+(%,floodRPK_ACTIVE.,$nick),2))) halt
    SET -u15 %floodRPK_ACTIVE On
    SET -u120 %floodRPK_ACTIVE. $+ $nick On
    MSG $chan $nick $+ , the Rock/Paper/Katana game is currently disabled.
    halt
  }
  ELSEIF ($2 isnum %rpk_minbet - %rpk_maxbet) && (!%rpk.p1) {
    IF ($($+(%,RPK_CD.,$nick),2)) MSG $nick $nick $+ , please wait for your cooldown to expire in $duration(%RPK_CD. [ $+ [ $nick ] ]) before trying to play RPK again.
    ELSEIF ($GetPoints($nick) < $2) MSG $chan $nick $+ , you don't have enough %curname to play.  FailFish
    ELSEIF (!$3) {
      SET %rpk.p1 $nick
      SET %rpk.bet $floor($2)
      MSG $chan KAPOW %rpk.p1 has issued a Rock/Paper/Katana challenge for %rpk.bet %curname to the first person to accept within 90 seconds!  To accept this challenge type "!rpk accept"
      .timer.rpk.wait1 1 90 MSG $chan Sorry, %rpk.p1 $+ , but nobody wanted to accept your RPK challenge!  FeelsBadMan
      .timer.rpk.wait2 1 90 UNSET %rpk.*
      .timer.rpk.wait3 1 90 SET -z %RPK_CD. $+ $nick %rpk_cd
    }
    ELSEIF ($3) && ($3 != $me) {
      VAR %target $remove($3, @)
      IF (%target ison $chan) {
        IF ($GetPoints(%target) < $2) MSG $chan $nick $+ , $twitch_name(%target) doesn't have enough %curname to play.  FailFish
        ELSE {
          SET %rpk.p1 $nick
          SET %rpk.p2 $twitch_name(%target)
          SET %rpk.bet $floor($2)
          MSG $chan KAPOW %rpk.p1 has issued a Rock/Paper/Katana challenge for %rpk.bet %curname to %rpk.p2 $+ !  %rpk.p2 now has 90 seconds to accept this challenge by typing "!rpk accept"
          .timer.rpk.wait1 1 90 MSG $chan Sorry, %rpk.p1 $+ , but %rpk.p2 didn't want to accept your RPK challenge!  FeelsBadMan
          .timer.rpk.wait2 1 90 UNSET %rpk.*
          .timer.rpk.wait3 1 90 SET -z %RPK_CD. $+ $nick %rpk_cd
        }
      }
      ELSE MSG $chan $nick $+ , %target is not the name of a user here in the channel.  Please check the spelling and make sure that they are actually here.
    }
  }
  ELSEIF ((%rpk.p1) && ($nick != %rpk.p1) && ($2 == accept)) {
    IF (!%rpk.p2) {
      IF ($GetPoints($nick) < %rpk.bet) MSG $chan $nick $+ , you don't have enough %curname to play.  FailFish
      ELSE SET %rpk.p2 $nick
    }
    IF ((%rpk.p2 == $nick) && (!$timer(.rpk.start)) && (!%rpk.on) && (!$timer(.rpk.end))) {
      .timer.rpk.wait* off
      MSG $chan %rpk.p2 has accepted the RPK challenge of %rpk.p1 $+ !  In a few seconds, I will WHISPER both players and ask for their choice, and the winning player will win %rpk.bet %curname from the other player!
      .timer.rpk.start 1 4 rpk_start
    }
  }
  ELSEIF (!%rpk.p1) {
    IF (%floodrpkinfo) halt
    SET -u6 %floodrpkinfo On
    MSG $chan Play Rock/Paper/Katana with a friend to try and win each others %curname $+ !  Just type "!rpk $chr(91) $+ %rpk_minbet $+ - $+ %rpk_maxbet $+ $chr(93) $+ " to play against ANYONE, -or- type "!rpk $chr(91) $+ %rpk_minbet $+ - $+ %rpk_maxbet $+ $chr(93) username" to play against a specific person! ▌ Example:  !rpk %rpk_maxbet
  }
}


alias rpk_start {
  SET %rpk.on On
  MSG %rpk.p1 %rpk.p1 $+ , please enter your choice of [r]ock, [p]aper, or [k]atana. (you only need to enter the first letter of your choice) View the result in %streamer $+ 's main chat.
  MSG %rpk.p2 %rpk.p2 $+ , please enter your choice of [r]ock, [p]aper, or [k]atana. (you only need to enter the first letter of your choice) View the result in %streamer $+ 's main chat.
  .timer.rpk.tooslow 1 60 rpk_tooslow
}


ON *:TEXT:*:?:{
  IF (%rpk.on) {
    IF ($nick == %rpk.p1) && (!%rpk.p1c) {
      IF ($left($1,1) == r) SET %rpk.p1c Rock
      ELSEIF ($left($1,1) == p) SET %rpk.p1c Paper
      ELSEIF ($left($1,1) == s) SET %rpk.p1c Katana
      CLOSE -m %rpk.p1
    }
    ELSEIF ($nick == %rpk.p2) && (!%rpk.p2c) {
      IF ($left($1,1) == r) SET %rpk.p2c Rock
      ELSEIF ($left($1,1) == p) SET %rpk.p2c Paper
      ELSEIF ($left($1,1) == s) SET %rpk.p2c Katana
      CLOSE -m %rpk.p2
    }
    IF (%rpk.p1c) && (%rpk.p2c) {
      .timer.rpk.tooslow off
      UNSET %rpk.on
      IF (%rpk.p1c == %rpk.p2c) .timer.rpk.end 1 3 rpk_draw
      ELSEIF (%rpk.p1c == Paper) && (%rpk.p2c == Rock) .timer.rpk.end 1 3 rpk_win1
      ELSEIF (%rpk.p1c == Katana) && (%rpk.p2c == Paper) .timer.rpk.end 1 3 rpk_win1
      ELSEIF (%rpk.p1c == Rock) && (%rpk.p2c == Katana) .timer.rpk.end 1 3 rpk_win1
      ELSEIF (%rpk.p1c == Rock) && (%rpk.p2c == Paper) .timer.rpk.end 1 3 rpk_win2
      ELSEIF (%rpk.p1c == Paper) && (%rpk.p2c == Katana) .timer.rpk.end 1 3 rpk_win2
      ELSEIF (%rpk.p1c == Katana) && (%rpk.p2c == Rock) .timer.rpk.end 1 3 rpk_win2
      SET -z %RPK_CD. $+ %rpk.p1 %rpk_cd
    }
  }
}


alias rpk_tooslow {
  IF (!%rpk.p1c) && (!%rpk.p2c) {
    MSG %mychan Both %rpk.p1 and %rpk.p2 did not make a choice!  They both lose %rpk.bet %curname $+ !
    REMOVEPOINTS %rpk.p1 %rpk.bet
    REMOVEPOINTS %rpk.p2 %rpk.bet
  }
  ELSEIF (!%rpk.p1c) {
    MSG %mychan %rpk.p1 did not make a choice!  %rpk.p2 wins %rpk.bet %curname from %rpk.p1 $+ !
    ADDPOINTS %rpk.p2 %rpk.bet
    REMOVEPOINTS %rpk.p1 %rpk.bet
  }
  ELSEIF (!%rpk.p2c) {
    MSG %mychan %rpk.p2 did not make a choice!  %rpk.p1 wins %rpk.bet %curname from %rpk.p2 $+ !
    ADDPOINTS %rpk.p1 %rpk.bet
    REMOVEPOINTS %rpk.p2 %rpk.bet
  }
  UNSET %rpk.*
}

alias rpk_draw {
  MSG %mychan %rpk.p1 and %rpk.p2 both chose %rpk.p1c $+ .  The game is tied!
  UNSET %rpk.*
}

alias rpk_win1 {
  MSG %mychan %rpk.p1c beats %rpk.p2c $+ ! %rpk.p1 wins %rpk.bet %curname from %rpk.p2 $+ !
  ADDPOINTS %rpk.p1 %rpk.bet
  REMOVEPOINTS %rpk.p2 %rpk.bet
  UNSET %rpk.*
}

alias rpk_win2 {
  MSG %mychan %rpk.p2c beats %rpk.p1c $+ ! %rpk.p2 wins %rpk.bet %curname from %rpk.p1 $+ !
  ADDPOINTS %rpk.p2 %rpk.bet
  REMOVEPOINTS %rpk.p1 %rpk.bet
  UNSET %rpk.*
}
