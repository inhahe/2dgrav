'G constant/real objects

PEN ON
'SCREEN 9
'CONST yo2 = 175, xo2 = 320, ymax = 350, xmax = 640,cs=16

'SCREEN 13
'CONST yo2 = 100, xo2 = 160, ymax = 200, xmax=320,cs=256

SCREEN 12
CONST yo2 = 240, xo2 = 320, ymax = 480, xmax = 640, cs = 16

up = yo2: right = xo2
OPTION BASE 1
'delay = 7000
DIM dx AS DOUBLE
DIM dy AS DOUBLE
DIM dist AS DOUBLE
DIM dist2 AS DOUBLE
DIM ttmp AS DOUBLE
DIM ttmpx AS DOUBLE
DIM ttmpy AS DOUBLE
DIM tr AS DOUBLE
DIM tv AS DOUBLE
DIM sizetmp AS INTEGER
DIM frames AS LONG
DIM relations AS LONG
DIM positions AS LONG
DIM msign AS INTEGER
msign = 1
CONST true = -1
CONST false = 0
GOTO 1
dims:
dimcalls = dimcalls + 1
REDIM x(objects + 1)   AS DOUBLE
REDIM y(objects + 1)   AS DOUBLE
REDIM ix(objects + 1)   AS DOUBLE
REDIM iy(objects + 1)   AS DOUBLE
REDIM tmpx(objects + 1) AS LONG
REDIM tmpy(objects + 1) AS LONG
REDIM ltmpx(objects + 1) AS LONG
REDIM ltmpy(objects + 1) AS LONG
REDIM updated(objects + 1) AS INTEGER
REDIM vx(objects + 1)   AS DOUBLE
REDIM vy(objects + 1)   AS DOUBLE
REDIM ivx(objects + 1)  AS DOUBLE
REDIM ivy(objects + 1)  AS DOUBLE
REDIM m(objects + 1)    AS DOUBLE
REDIM rm(objects)       AS DOUBLE
REDIM im(objects)       AS DOUBLE
REDIM size(objects + 1) AS INTEGER
REDIM isize(objects + 1) AS INTEGER
REDIM c(objects + 1)    AS INTEGER
REDIM sign(objects + 1) AS INTEGER
REDIM bouncel(objects)  AS INTEGER
REDIM bouncer(objects)   AS INTEGER
REDIM bounceu(objects)   AS INTEGER
REDIM bounced(objects)   AS INTEGER
REDIM rel(objects) AS INTEGER
RETURN
1
LOCATE , , 0, 7, 7
'FOR s = 0 TO 12 STEP 3
'  DO
'    r = INT(RND + .5)
'    g = INT(RND + .5)
'    b = INT(RND + .5)
' LOOP UNTIL r + b + g > 0
' FOR ss = 1 TO 3
'   PALETTE s + ss, r * ss * 16 + g * ss * 4 + b * ss
' NEXT
'nEXT


'delay = 7000
COLOR 2: PRINT "I"; : COLOR 7: PRINT "nput parameters, "; : COLOR 2: PRINT "L"; : COLOR 7: PRINT "oad from file, or "; : COLOR 10: PRINT "R"; : COLOR 7: PRINT "andomize?"
WHILE iol$ = "": iol$ = INKEY$: WEND
SELECT CASE LCASE$(iol$)
  CASE "l": GOSUB loadparameters
  CASE "i": GOSUB inputparameters
  CASE ELSE: GOSUB rndmz
END SELECT
GOSUB commands
GOSUB init1

SHELL "mode con: rate=32 delay=1"
t = TIMER
DO
  a$ = INKEY$
  GOSUB docommand
  FOR dly = 1 TO delay: NEXT
  FOR s = 1 TO objects - 1
    IF sign(s) = 0 THEN 7
    FOR ss = s + 1 TO objects
      IF sign(ss) = 0 THEN 6
      IF lines AND (updated(s) OR updated(ss)) THEN
        IF ro = 2 THEN lc = lc MOD 15 + 1 ELSE lc = (ss + s) MOD 15 + 1
        IF clrline OR ((s = objects OR ss = objects) AND mouse) THEN LINE (ltmpx(s), ltmpy(s))-(ltmpx(ss), ltmpy(ss)), 0
        LINE (tmpx(s), tmpy(s))-(tmpx(ss), tmpy(ss)), lc
      END IF
      dx = x(ss) - x(s): dy = y(ss) - y(s)
      dist2 = dx ^ 2 + dy ^ 2
      dist = SQR(dist2)
      ttmp = 1 / dist2 / dist
      ttmpx = ttmp * dx
      ttmpy = ttmp * dy

      IF ss < objects OR NOT mouse THEN
        IF dist < size(s) + size(ss) AND sign(s) = sign(ss) THEN
          IF size(ss) > size(s) THEN c(s) = c(ss)
          IF circles AND clrcircle THEN
            CIRCLE (ltmpx(ss), ltmpy(ss)), size(ss), 0
            CIRCLE (ltmpx(s), ltmpy(s)), size(s), 0
          END IF
          IF dots AND clrdot THEN
            PSET (ltmpx(ss), ltmpy(ss)), 0
            PSET (ltmpx(s), ltmpy(s)), 0
          END IF
          IF lines AND clrline THEN
            FOR ltmp = 1 TO objects
              LINE (ltmpx(s), ltmpy(s))-(ltmpx(ltmp), ltmpy(ltmp)), 0
              LINE (ltmpx(ss), ltmpy(ss))-(ltmpx(ltmp), ltmpy(ltmp)), 0
            NEXT
          END IF
          x(s) = x(ss) - dx / (m(s) + m(ss)) * m(s)
          y(s) = y(ss) - dy / (m(s) + m(ss)) * m(s)
          ABSms = ABS(m(s))
          ABSmss = ABS(m(ss))
          vx(s) = (vx(ss) * ABSmss + vx(s) * ABSms) / (ABSms + ABSmss)
          vy(s) = (vy(ss) * ABSmss + vy(s) * ABSms) / (ABSms + ABSmss)
          m(s) = m(s) + m(ss)
          rm(s) = rm(s) + rm(ss)
          size(s) = (ABS(rm(s)) * 3 / 4 / 3.14) ^ (1 / 3) * 6
          sign(ss) = 0
          GOSUB setbounces
          ro = ro - 1
          IF ro = 1 THEN
             LOCATE 1, 1
             PRINT "This has suddenly become VERY dull..."
          ELSE
             IF ro = 2 THEN
               rottmp = 0
               FOR rotmp = 1 TO objects
                 rottmp = rottmp + sign(rotmp)
               NEXT
               IF rottmp = 0 THEN
                 LOCATE 1, 1
                 PRINT "Yawn..."
               END IF
             END IF
          END IF
          IF locknum = ss THEN locknum = s
          rel(ss) = s
          GOTO 6
        END IF
        vx(ss) = vx(ss) - m(s) * ttmpx * sign(ss) * msign
        vy(ss) = vy(ss) - m(s) * ttmpy * sign(ss) * msign
       
      ELSE
        x(ss) = PEN(4) - xo2
        y(ss) = yo2 - PEN(5)
      END IF
     
      vx(s) = vx(s) + m(ss) * ttmpx * sign(s) * msign
      vy(s) = vy(s) + m(ss) * ttmpy * sign(s) * msign

6
    NEXT ss
7
  NEXT s
  IF lck AND locknum >= 1 AND locknum <= objects THEN
    IF updated(locknum) THEN
      bc = 0
      GOSUB border
      right = xo2 - x(locknum)
      up = y(locknum) + yo2
      bc = 15
      GOSUB border
    END IF
  END IF
  FOR s = 1 TO objects
    IF sign(s) = 0 THEN 22
    x(s) = x(s) + vx(s)
    y(s) = y(s) + vy(s)
    IF bounce THEN
      IF x(s) < bouncel(s) OR x(s) > bouncer(s) THEN vx(s) = -vx(s): x(s) = x(s) + vx(s)
      IF y(s) < bounced(s) OR y(s) > bounceu(s) THEN vy(s) = -vy(s): y(s) = y(s) + vy(s)
    END IF
    IF updated(s) THEN
      IF circles THEN
        IF clrcircle OR (s = objects AND mouse) THEN CIRCLE (ltmpx(s), ltmpy(s)), size(s), 0
        CIRCLE (tmpx(s), tmpy(s)), size(s), c(s)
      END IF
      IF dots THEN
        IF clrdot OR (s = objects AND mouse) THEN
          PSET (ltmpx(s), ltmpy(s)), 0
          PSET (tmpx(s), tmpy(s)), c(s)
        ELSE
          IF cd THEN
            LINE (tmpx(s), tmpy(s))-(ltmpx(s), ltmpy(s)), c(s)
          ELSE
            PSET (tmpx(s), tmpy(s)), c(s)
          END IF
        END IF
      END IF
    END IF
    ltmpx(s) = tmpx(s)
    ltmpy(s) = tmpy(s)
    tmpx(s) = x(s) + right
    tmpy(s) = up - y(s)
   
    IF tmpx(s) <> ltmpx(s) OR tmpy(s) <> ltmpy(s) THEN updated(s) = true ELSE updated(s) = 0
22
  NEXT
  'frames = frames + 1
LOOP

docommand:
SELECT CASE a$
  CASE ""
  CASE CHR$(0) + "S": rflag = true: GOSUB rndmz: GOSUB init1
  CASE "s": cd = NOT cd
  CASE "G", "g"
    IF a$ = "G" THEN grav = 1 / 2 ELSE grav = 2
    FOR etmp = 1 TO objects
      m(etmp) = m(etmp) * grav
    NEXT
  CASE "T", "t"
    IF a$ = "T" THEN res = 1 / 2 ELSE res = 2
    FOR etmp = 1 TO objects
      m(etmp) = m(etmp) * res ^ 2
      vx(etmp) = vx(etmp) * res
      vy(etmp) = vy(etmp) * res
    NEXT
  CASE "p": delay = -delay
  CASE CHR$(0) + "H"
    bc = 0: GOSUB border
    up = up + 50
    bc = 15: GOSUB border
  CASE CHR$(0) + "M"
    IF bounce THEN bc = 0: GOSUB border
    right = right - 50
    IF bounce THEN bc = 15: GOSUB border
  CASE CHR$(0) + "P"
    IF bounce THEN bc = 0: GOSUB border
    up = up - 50
    IF bounce THEN bc = 15: GOSUB border
  CASE CHR$(0) + "K"
    IF bounce THEN bc = 0: GOSUB border
    right = right + 50
    IF bounce THEN bc = 15: GOSUB border
  CASE "r", " "
    IF a$ = " " THEN CLS
    IF bounce THEN bc = 15: GOSUB border
    FOR rtmp = 1 TO objects
      IF sign(rtmp) <> 0 THEN
        ltmpx(rtmp) = tmpx(rtmp) + 1
        ltmpy(rtmp) = tmpy(rtmp) + 1
      END IF
    NEXT
  CASE "z", "0"
    IF bounce THEN bc = 0: GOSUB border
    up = yo2: right = xo2
    IF bounce THEN bc = 15: GOSUB border
  CASE "L": clrline = NOT clrline
  CASE "l"
    lines = NOT lines
    IF NOT lines AND clrline THEN
      FOR ltmp = 1 TO objects - 1
        FOR ltmp2 = ltmp + 1 TO objects
          LINE (tmpx(ltmp), tmpy(ltmp))-(tmpx(ltmp2), tmpy(ltmp2)), 0
        NEXT
      NEXT
    END IF
  CASE "c"
    circles = NOT circles
    IF NOT circles AND clrcircle THEN
      FOR ctmp = 1 TO objects
        IF sign(ctmp) <> 0 THEN CIRCLE (ltmpx(ctmp), ltmpy(ctmp)), size(ctmp), 0
      NEXT
    END IF
    'GOSUB setbounces
  CASE "C": clrcircle = NOT clrcircle
  CASE "d": dots = NOT dots
    IF NOT dots AND clrdot THEN
      FOR ctmp = 1 TO objects
        IF sign(ctmp) <> 0 THEN PSET (tmpx(ctmp), tmpy(ctmp)), 0
      NEXT
    END IF
  CASE "D": clrdot = NOT clrdot
  CASE "b": bounce = NOT bounce: bc = -15 * bounce: GOSUB border
  CASE "m"
    mouse = NOT mouse
    IF mouse THEN
      objects = objects + 1
                                                      'm(objects) = 5
      c(objects) = 14
      size(objects) = 10
      sign(objects) = 1
    ELSE
      objects = objects - 1
    END IF
  CASE "+", "=": IF mouse THEN m(objects) = m(objects) + 1
  CASE "-", "_": IF mouse THEN m(objects) = m(objects) - 1
  CASE "": GOTO nd
  CASE "v"
    tv = 1
    FOR sss = 1 TO objects
      tv = tv + ABS(m(sss)) * SQR(vx(sss) ^ 2 + vy(sss) ^ 2)
    NEXT
    LOCATE 1, 1
    PRINT USING "####.################"; tv
  CASE "n"
    FOR sss = 1 TO objects
      vx(sss) = 0: vy(sss) = 0
    NEXT
  CASE "k"
    lck = NOT lck
  CASE ELSE
    IF a$ = RTRIM$(LTRIM$(STR$(VAL(a$)))) AND VAL(a$) <= objects THEN
       locknum = VAL(a$)
       IF sign(locknum) = 0 THEN locknum = rel(locknum)
       bc = 0
       GOSUB border
       right = xo2 - x(locknum)
       up = y(locknum) + yo2
       bc = 15
       GOSUB border
    END IF
END SELECT
RETURN


inputparameters:
PRINT
inputed = true
PRINT "How many objects? ";
COLOR 2: INPUT "", objects
IF objects < 1 THEN GOSUB loadparameters: GOTO 4
GOSUB dims

PRINT
COLOR 7
GOSUB getres
PRINT "Resolution: ("; : COLOR 2: PRINT RTRIM$(LTRIM$(STR$(resolution))); : COLOR 7: PRINT "): ";
COLOR 10
INPUT "", res
IF res = 0 THEN res = resolution

PRINT
COLOR 7
PRINT "Gravitational constant ("; : COLOR 2: PRINT "1"; : COLOR 7: PRINT "): ";
INPUT "", grav
IF grav = 0 THEN grav = 1

PRINT
COLOR 7: PRINT "Circles? ("; : COLOR 10: PRINT "Y"; : COLOR 7: PRINT "/"; : COLOR 2: PRINT "n"; : COLOR 7: PRINT ")"
DO: a$ = INKEY$: LOOP UNTIL a$ <> ""
IF UCASE$(a$) <> "N" THEN circles = true

PRINT
COLOR 7: PRINT "Circle clearing? ("; : COLOR 10: PRINT "Y"; : COLOR 7: PRINT "/"; : COLOR 2: PRINT "n"; : COLOR 7: PRINT ")"
DO: a$ = INKEY$: LOOP UNTIL a$ <> ""
IF UCASE$(a$) <> "N" THEN clrcircle = true

PRINT
COLOR 7: PRINT "Lines? ("; : COLOR 2: PRINT "y"; : COLOR 7: PRINT "/"; : COLOR 10: PRINT "N"; : COLOR 7: PRINT ")"
DO: a$ = INKEY$: LOOP UNTIL a$ <> ""
IF UCASE$(a$) = "Y" THEN lines = true

PRINT
COLOR 7: PRINT "Line clearing? ("; : COLOR 10: PRINT "Y"; : COLOR 7: PRINT "/"; : COLOR 2: PRINT "n"; : COLOR 7: PRINT ")"
DO: a$ = INKEY$: LOOP UNTIL a$ <> ""
IF UCASE$(a$) <> "N" THEN clrline = true

PRINT
COLOR 7: PRINT "Dots? ("; : COLOR 2: PRINT "y"; : COLOR 7: PRINT "/"; : COLOR 10: PRINT "N"; : COLOR 7: PRINT ")"
DO: a$ = INKEY$: LOOP UNTIL a$ <> ""
IF UCASE$(a$) = "Y" THEN dots = true

PRINT
COLOR 7: PRINT "Dot clearing? ("; : COLOR 2: PRINT "y"; : COLOR 7: PRINT "/"; : COLOR 10: PRINT "N"; : COLOR 7: PRINT ")"
DO: a$ = INKEY$: LOOP UNTIL a$ <> ""
IF UCASE$(a$) = "Y" THEN clrdot = true

PRINT
COLOR 7: PRINT "Solid dot trace? ("; : COLOR 2: PRINT "y"; : COLOR 7: PRINT "/"; : COLOR 10: PRINT "N"; : COLOR 7: PRINT ")"
COLOR 7: PRINT "(Effective when"
         PRINT "dots and not dot"
         PRINT "clearing)"
DO: a$ = INKEY$: LOOP UNTIL a$ <> ""
IF UCASE$(a$) = "Y" THEN cd = true

PRINT
PRINT "Bounce objects off the sides? ("; : COLOR 2: PRINT "y"; : COLOR 7: PRINT "/"; : COLOR 10: PRINT "N"; : COLOR 7: PRINT ")"
DO: a$ = INKEY$: LOOP UNTIL a$ <> ""
IF UCASE$(a$) = "Y" THEN bounce = true
FOR s = 1 TO objects
  PRINT
  PRINT "X coordinate of object #"; LTRIM$(STR$(s)); ": ";
  COLOR 10: INPUT "", x(s)
  COLOR 7: PRINT "Y coordinate of object #"; LTRIM$(STR$(s)); ": ";
  COLOR 10: INPUT "", y(s)
  COLOR 7: PRINT "X velocity of object #"; LTRIM$(STR$(s)); " ("; CHR$(27); "- +"; CHR$(26); "): ";
  COLOR 10: INPUT "", vx(s)
  COLOR 7: PRINT "Y velocity of object #"; LTRIM$(STR$(s)); " ("; CHR$(25); "- +"; CHR$(24); "): ";
  COLOR 10: INPUT "", vy(s)
  COLOR 7: PRINT "Mass of object #"; LTRIM$(STR$(s)); " (ñ): ";
  COLOR 10: INPUT "", m(s)
  IF m(s) < 0 THEN sign(s) = -1 ELSE sign(s) = 1
  sizetmp = (ABS(m(s)) * 3 / 4 / 3.14) ^ (1 / 3) * 6
  COLOR 7: PRINT "Size of object #"; LTRIM$(STR$(s)); " ("; : COLOR 2: PRINT LTRIM$(RTRIM$(STR$(sizetmp))); : COLOR 7: PRINT "): ";
  COLOR 10: INPUT "", size(s)
  IF size(s) = 0 THEN size(s) = sizetmp
  Colortmp = INT(RND * (cs - 1)) + 1
  COLOR 7: PRINT "Color of object #"; LTRIM$(STR$(s)); " ("; : COLOR 2: PRINT LTRIM$(RTRIM$(STR$(Colortmp))); : COLOR 7: PRINT "): ";
  COLOR 10: INPUT "", a$
  IF a$ <> "0" AND VAL(a$) = 0 THEN c(s) = Colortmp ELSE c(s) = VAL(a$)
  COLOR 7
NEXT s
4
RETURN

saveparameters:
PRINT

GOSUB fls

PRINT "Save parameters in filename.2DG: ";
COLOR 2: INPUT "", file$
IF RIGHT$(file$, 4) = ".2dg" THEN file$ = LEFT$(file$, LEN(file$) - 4)
IF file$ <> "" THEN
  OPEN file$ + ".2dg" FOR OUTPUT AS #1
  PRINT #1, objects
  PRINT #1, ires
  PRINT #1, igrav
  PRINT #1, bounce
  PRINT #1, circles
  PRINT #1, clrcircle
  PRINT #1, lines
  PRINT #1, clrline
  PRINT #1, dots
  PRINT #1, clrdot
  PRINT #1, cd
  FOR s = 1 TO objects
    PRINT #1, RTRIM$(STR$(ix(s))); ","; RTRIM$(STR$(iy(s))); ",";
    PRINT #1, RTRIM$(STR$(ivx(s))); ","; RTRIM$(STR$(ivy(s))); ",";
    PRINT #1, RTRIM$(STR$(im(s))); ","; RTRIM$(STR$(isize(s))); ",";
    PRINT #1, RTRIM$(STR$(c(s)))
  NEXT s
  PRINT #1,
  PRINT #1, ro
  PRINT #1, 1
  PRINT #1, 1
  PRINT #1, bounce
  PRINT #1, circles
  PRINT #1, clrcircle
  PRINT #1, lines
  PRINT #1, clrline
  PRINT #1, dots
  PRINT #1, clrdot
  PRINT #1, cd
  FOR s = 1 TO objects
    IF sign(s) = 0 THEN 8
    PRINT #1, RTRIM$(STR$(x(s))); ","; RTRIM$(STR$(y(s))); ",";
    PRINT #1, RTRIM$(STR$(vx(s))); ","; RTRIM$(STR$(vy(s))); ",";
    PRINT #1, RTRIM$(STR$(m(s))); ","; RTRIM$(STR$(size(s))); ",";
    PRINT #1, RTRIM$(STR$(c(s)))
8
  NEXT s
END IF
CLOSE
RETURN

commands:
PRINT
COLOR 7: PRINT "See command keys? "; : PRINT "("; : COLOR 2: PRINT "y"; : COLOR 7: PRINT "/"; : COLOR 10: PRINT "N"; : COLOR 7: PRINT ")"
WHILE sck$ = "": sck$ = INKEY$: WEND
IF LCASE$(sck$) <> "y" THEN GOTO 3
PRINT ""
PRINT "Arrow keys scroll the screen"
PRINT "Jump to object number "; : COLOR 10: PRINT "1"; : COLOR 7: PRINT "-"; : COLOR 10: PRINT "9"
COLOR 7: PRINT "Loc"; : COLOR 10: PRINT "k"; : COLOR 7: PRINT " onto coordinates of last object jumped to"
COLOR 10: PRINT "Z"; : COLOR 7: PRINT "er"; : COLOR 10: PRINT "0"; : COLOR 7: PRINT " offset"
PRINT "e"; : COLOR 10: PRINT "R"; : COLOR 7: PRINT "ase screan"
COLOR 10: PRINT "c"; : COLOR 7: PRINT "ircle draw"
COLOR 10: PRINT "C"; : COLOR 7: PRINT "ircle erase"
COLOR 10: PRINT "l"; : COLOR 7: PRINT "ine draw"
COLOR 10: PRINT "L"; : COLOR 7: PRINT "ine erase"
COLOR 10: PRINT "d"; : COLOR 7: PRINT "ot draw"
COLOR 10: PRINT "D"; : COLOR 7: PRINT "ot erase"
COLOR 10: PRINT "s"; : COLOR 7: PRINT "olidify"
COLOR 10: PRINT "n"; : COLOR 7: PRINT "ullify velocities"
COLOR 10: PRINT "ESC"; : COLOR 7: PRINT "ape pgm"
PRINT
PRINT "Special keys:"
PRINT "  G, g: halve/double G constant"
PRINT "  T, t: double/halve precision"
PRINT "  View kinetic energy of system"
PRINT "  DELete system and randomize new"
PRINT
PRINT "Press any key to continue..."
WHILE INKEY$ = "": WEND
3
RETURN

rndmz:
  RANDOMIZE TIMER
  temp = INT(RND * 5) + 3
  IF NOT rflag THEN
    PRINT
    PRINT "Objects: ("; : COLOR 2: PRINT LTRIM$(RTRIM$(STR$(temp))); : COLOR 7: PRINT "): ";
    COLOR 10: INPUT "", objects
  END IF
IF objects = 0 OR rflag THEN objects = temp
GOSUB getres
res = resolution
grav = 1
IF NOT rflag THEN
  dots = 0
  clrcircle = true
  clrline = true
  lines = 0
  circles = true
  bounce = true
END IF
GOSUB dims
FOR s = 1 TO objects
  x(s) = RND * xmax * .8 - xo2 * .8
  y(s) = RND * ymax * .8 - yo2 * .8
  vx(s) = RND / 2.5 - 1 / 5
  vy(s) = RND / 2.5 - 1 / 5
  m(s) = RND * 10 - 5
  IF m(s) < 0 THEN sign(s) = -1 ELSE sign(s) = 1
  size(s) = (ABS(m(s)) * 3 / 4 / 3.14) ^ (1 / 3) * 6
  c(s) = INT(RND * (cs - 1)) + 1
  'IF size(s) = INT(m(s)) THEN C(s) = C(s) + 8
  'IF m(s) < 0 THEN C(s) = 11 ELSE C(s) = 15
NEXT
RETURN

loadparameters:
PRINT

GOSUB fls

COLOR 7
PRINT "File to load parameters from: ";
COLOR 2
INPUT "", file$
COLOR 7
IF LCASE$(RIGHT$(file$, 4)) = ".2dg" THEN file$ = LEFT$(file$, LEN(file$) - 4)
IF file$ = "" THEN GOSUB inputparameters: GOTO 2
OPEN file$ + ".2dg" FOR INPUT AS #1
INPUT #1, objects
GOSUB dims
INPUT #1, res
INPUT #1, grav
INPUT #1, bounce
INPUT #1, circles
INPUT #1, clrcircle
INPUT #1, lines
INPUT #1, clrline
INPUT #1, dots
INPUT #1, clrdot
INPUT #1, cd
FOR s = 1 TO objects
  INPUT #1, x(s)
  INPUT #1, y(s)
  INPUT #1, vx(s)
  INPUT #1, vy(s)
  INPUT #1, m(s)
  IF m(s) < 0 THEN sign(s) = -1 ELSE sign(s) = 1
  INPUT #1, size(s)
  INPUT #1, c(s)
NEXT s
PRINT "Use "; : COLOR 10: PRINT "I"; : COLOR 7: PRINT "nitial state or "; : COLOR 2: PRINT "C"; : COLOR 7: PRINT "urrent sate?"
DO: a$ = INKEY$: LOOP UNTIL a$ <> ""
IF LCASE$(a$) = "c" THEN
  INPUT #1, nul
  INPUT #1, objects
  INPUT #1, res
  INPUT #1, grav
  INPUT #1, bounce
  INPUT #1, circles
  INPUT #1, clrcircle
  INPUT #1, lines
  INPUT #1, clrline
  INPUT #1, dots
  INPUT #1, clrdot
  INPUT #1, cd
  FOR s = 1 TO objects
    INPUT #1, x(s)
    INPUT #1, y(s)
    INPUT #1, vx(s)
    INPUT #1, vy(s)
    INPUT #1, m(s)
    IF m(s) < 0 THEN sign(s) = -1 ELSE sign(s) = 1
    INPUT #1, size(s)
    INPUT #1, c(s)
  NEXT s
END IF
CLOSE
2
RETURN

setbounces:
    FOR ctmp = 1 TO objects
      bouncel(ctmp) = -xo2 + 1
      bounced(ctmp) = -yo2 + 2
      'IF circles THEN
        bouncel(ctmp) = size(ctmp) + bouncel(ctmp)
        bounced(ctmp) = size(ctmp) + bounced(ctmp)
      'END IF
      bouncer(ctmp) = -bouncel(ctmp) - 1
      bounceu(ctmp) = -bounced(ctmp)
    NEXT
RETURN

getres:
OPEN "\res" FOR BINARY AS #2
IF LOF(2) = 0 THEN
  CLOSE #2
  OPEN "\res" FOR OUTPUT AS #2
  PRINT "Please wait for damn near 1 second..."
  x = 0: t = TIMER + 1: WHILE TIMER < t: x = x + 1: WEND
  resolution = 62000 / x
  PRINT #2, resolution
ELSE
  CLOSE #2
  OPEN "\res" FOR INPUT AS #2
  INPUT #2, resolution
END IF
CLOSE #2
RETURN

fls:
SHELL "dir *.2dg> tmp"
OPEN "tmp" FOR INPUT AS #3
DO
  INPUT #3, tmp$
  IF MID$(tmp$, 10, 3) = "2DG" THEN PRINT LEFT$(tmp$, INSTR(tmp$, " 2"));
LOOP UNTIL EOF(3)
CLOSE #3
'KILL "tmp"
IF POS(0) > 1 THEN PRINT
RETURN

init1:
CLS
ro = objects
ires = res
igrav = grav
FOR s = 1 TO objects
  rm(s) = m(s)
  im(s) = m(s)
  isize(s) = size(s)
  ix(s) = x(s)
  iy(s) = y(s)
  ivx(s) = vx(s)
  ivy(s) = vy(s)
  m(s) = m(s) * res ^ 2
  vx(s) = vx(s) * res
  vy(s) = vy(s) * res
NEXT
GOSUB setbounces
IF bounce THEN bc = 15: GOSUB border
RETURN

border:
IF bounce THEN LINE (-xo2 + right, -yo2 + up)-(xo2 + right - 1, yo2 + up - 1), bc, B
RETURN

nd:
COLOR 10
Time = TIMER - t
secfrac = INT((Time - INT(Time)) * 100)
secs = Time
mins = secs \ 60
hours = mins \ 60
mins = mins MOD 60
secs = secs MOD 60
PRINT USING "Time: ##:##:##:##"; hours; mins; secs; secfrac
'PRINT "Frames:"; frames
'PRINT "Relations:"; relations
'PRINT "Positions:"; positions
'PRINT "Frames/sec:"; INT(frames / Time * 10) / 10
'PRINT "Relations/sec:"; INT(relations / Time * 10) / 10
'PRINT "Positions/sec:"; INT(positions / Time * 10) / 10
GOSUB saveparameters
SCREEN 0
      vain$ = "Richard A. Nichols III"
      LOCATE CSRLIN, 1
      l = TIMER
      FOR s = 1 TO LEN(vain$)
        LOCATE CSRLIN, 1
        PRINT RIGHT$(vain$, s) + STRING$(s * 2, 32);
        WHILE TIMER = l: WEND
        l = TIMER
      NEXT
      END

