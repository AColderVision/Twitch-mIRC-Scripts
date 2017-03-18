;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;; A_COLDER_VISION'S ULTIMATE !SAKE SCRIPT ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON *:CONNECT: {
  IF ($server == tmi.twitch.tv) {
    UNSET %colder_is_live
    UNSET %livecheck_CD
    UNSET %sake_CD2.*
    UNSET %topsake_CD
  }
}

ON $*:TEXT:/^!sake(\s|$)/iS:%mychan: {
  IF ($livecheck == $false) {
    IF (!%livecheck_CD) {
      SET -eu60 %livecheck_CD On
      MSG $chan $nick $+ , !sake is disabled while the stream is offline! acvRAGE
    }
  }
  ELSEIF ($timer(.sake_CD. $+ $nick)) {
    IF (!$($+(%,sake_CD2.,$nick),2)) {
      SET -eu60 %sake_CD2. $+ $nick On
      $wdelay(MSG $nick Be patient $+ $chr(44) $nick $+ !  You still have $duration($timer(.sake_CD. $+ $nick).secs) left in your !sake cooldown.)
    }
  }
  ELSE {
    WRITEINI sake.ini $nick sake $calc($readini(sake.ini,$nick,sake) + 1)
    .timer.sake_CD. $+ $nick 1 600 MSG $nick $nick $+ , your !sake cooldown has expired. You've poured Colder a total of $readini(sake.ini,$nick,sake) cups of Sakè. Pour him another with !sake.  BloodTrail
    IF ($right($readini(sake.ini,$nick,sake),3) == 000) {
      VAR %msg $nick has just recieved an additional 1000 Honor points for reaching a multiple of 1000 pours...
      ADDPOINTS $nick 1000
    }
    ELSEIF ($right($readini(sake.ini,$nick,sake),2) == 00) {
      VAR %msg $nick has just recieved an additional 100 Honor points for reaching a multiple of 100 pours...
      ADDPOINTS $nick 100
    }
    WRITEINI sake.ini _STATS_ total $calc($readini(sake.ini,_STATS_,total) + 1)
    WRITEINI sake.ini _STATS_ session $calc($readini(sake.ini,_STATS_,session) + 1)
    IF ($readini(sake.ini,_STATS_,session) > $readini(sake.ini,_STATS_,record)) {
      WRITEINI sake.ini _STATS_ record $readini(sake.ini,_STATS_,session)
      WRITE -l1 sake_record.txt Sakè Stream Record: $v1 on $asctime(mmm d yyyy)
    }
    WRITE -l1 sake.txt $readini(sake.ini,_STATS_,session)
    IF ($right($readini(sake.ini,_STATS_,total),3) == 000) {
      MSG $chan acvSAKE $nick $+ -san has poured A Colder Vision the SUPER MEGA SAKÈ SHOT! To date, A Colder Vision has consumed $bytes($readini(sake.ini,_STATS_,total),b) cups of Sakè! acvSAKE %msg
      VAR %sound_file Sake_1000.mp3
    }
    ELSEIF ($right($readini(sake.ini,_STATS_,total),2) == 00) {
      MSG $chan acvSAKE $nick $+ -san has poured A Colder Vision the SUPER SAKÈ SHOT! To date, A Colder Vision has consumed $bytes($readini(sake.ini,_STATS_,total),b) cups of Sakè! acvSAKE %msg
      VAR %sound_file Sake_100.mp3
    }
    ELSE {
      MSG $chan acvSAKE $nick $+ -san has poured A Colder Vision a cup of warm Sakè. To date, A Colder Vision has consumed $bytes($readini(sake.ini,_STATS_,total),b) cups of Sakè! acvSAKE %msg
      VAR %sound_file Sake.mp3
    }
    SPLAY -pq C:\Users\dcorsivo\Desktop\Stream\Sound Clips\ $+ %sound_file
  }
}

alias -l livecheck {
  IF (%colder_is_live == $true) RETURN $true
  ELSEIF (%colder_is_live == $false) RETURN $false
  JSONOpen -uw livecheck https://api.twitch.tv/kraken/streams/a_colder_vision?nocache= $+ $ticks
  JSONUrlHeader livecheck Client-ID avm4vi7zv0xpjkpi3d4x0qzk8xbrdw8
  JSONUrlGet livecheck
  VAR %x $IIF($json(livecheck,stream),$true,$false)
  JSONClose livecheck
  SET -eu120 %colder_is_live %x
  RETURN %x
}

ON $*:TEXT:/^!setcount\s\d+$/iS:%mychan: {
  IF ($isEditor) {
    WRITEINI sake.ini _STATS_ session $2
    WRITE -l1 sake.txt $2
  }
}

ON $*:TEXT:/^!reset$/iS:%mychan: {
  IF ($isEditor) {
    WRITE sake_history.txt $asctime(mmm d h:nn TT) - $readini(sake.ini,_STATS_,session) sakè's
    IF ($readini(sake.ini,_STATS_,session) > $readini(sake.ini,_STATS_,record)) {
      WRITEINI sake.ini _STATS_ record $readini(sake.ini,_STATS_,session)
      WRITE -l1 sake_record.txt $readini(sake.ini,_STATS_,session) on $asctime(mmm d yyyy)
    }
    WRITEINI sake.ini _STATS_ session 0
    WRITE -l1 sake.txt 0
  }
}

ON *:TEXT:!topsake:%mychan: {
  IF (!%topsake_CD) {
    SET -eu10 %topsake_CD On
    WINDOW -h @. | VAR %i 1
    WHILE $ini(sake.ini,%i) {
      ALINE @. $v1 $readini(sake.ini,$v1,sake)
      INC %i
    }
    FILTER -cetuww 2 32 @. @.
    VAR %i 1 | WHILE %i <= 10 {
      TOKENIZE 32 $line(@.,%i)
      VAR %name $chr(35) $+ %i $1 $chr(40) $+ $2 $+ $chr(41) -
      VAR %list $addtok(%list, %name, 32)
      INC %i
    }
    MSG $chan acvSAKE Top Sakè Pourers: $left(%list, -1) acvSAKE
    WINDOW -c @.
  }
}
