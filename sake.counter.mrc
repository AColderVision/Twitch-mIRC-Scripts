;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; SAKE COUNTER COMPANION ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ON *:TEXT:*:%mychan: {
  IF (($nick == $me) && (To date, A Colder Vision has consumed isin $1-)) {
    INC %sake.count
    WRITE -l1 sake.txt Saké Poured This Stream: %sake.count
  }
  ELSEIF (($1 == !setcount) && ($regex($2,^\d+$)) && ($isEditor)) {
    SET %sake.count $2
    WRITE -l1 sake.txt %sake.count
  }
  ELSEIF (($1 == !setrecord) && ($regex($2,^\d+$)) && ($isEditor)) {
    SET %sake.record $2
    WRITE -l1 sake_record.txt %sake.record on $asctime(mmm d yyyy)
  }
  ELSEIF (($1 == !reset) && ($isEditor)) {
    WRITE sake_history.txt $asctime(mmm d h:nn TT) - %sake.count sakés poured
    IF (%sake.count > %sake.record) {
      WRITE -l1 sake_record.txt %sake.count on $asctime(mmm d yyyy)
      SET %sake.record %sake.count
    }
    UNSET %sake.count
    WRITE -l1 sake.txt 0
  }
}