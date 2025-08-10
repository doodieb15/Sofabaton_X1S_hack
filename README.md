## auto_test3.sh

Dieses Skript testet systematisch, welche Zeichen und Kombinationen vom Sofabaton X1S über Telnet akzeptiert werden. Es speichert alle gültigen Kombinationen, die mit einem Leerzeichen enden, in der Datei `words_ending_with_space.txt`.

Bei mir ist der Port 8102 für Telnet sessions offen

Folgende Wörter habe ich bisher gefunden:

ACL
GET
PUT
ACL
BIND
COPY
GET
HEAD
LINK
LOCK
MOVE
POST
PUT
ACL
BIND
COPY
GET

Ev kann man damit eine lokale API basteln
