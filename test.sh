echo Get list of all games ---------------------------
curl http://localhost:9090/games
echo .

echo Create a game ----------------------
curl -d '{"playerOne":"Wilma","playerTwo":"Betty"}' -H 'Content-Type: application/json' http://localhost:9090/games
echo .

echo Get that just-created game -------------------------------
curl http://localhost:9090/games/0
echo .

echo Wilma goes center-square ----------------------------
curl -d '{"player":"Wilma","boardPosition":4}' -H 'Content-Type: application/json' http://localhost:9090/games/1/move
echo .

echo Betty tries to go center-square ----------------------------
curl -d '{"player":"Betty","boardPosition":4}' -H 'Content-Type: application/json' http://localhost:9090/games/1/move
echo .

echo Betty goes upper-left ----------------------------
curl -d '{"player":"Betty","boardPosition":0}' -H 'Content-Type: application/json' http://localhost:9090/games/1/move
echo .

echo Wilma goes top-center ----------------------------
curl -d '{"player":"Wilma","boardPosition":1}' -H 'Content-Type: application/json' http://localhost:9090/games/1/move
echo .

echo Betty goes lower-right ----------------------------
curl -d '{"player":"Betty","boardPosition":8}' -H 'Content-Type: application/json' http://localhost:9090/games/1/move
echo .

echo Wilma goes bottom-center and wins ----------------------------
curl -d '{"player":"Wilma","boardPosition":7}' -H 'Content-Type: application/json' http://localhost:9090/games/1/move
echo .

echo Betty tries to go upper-right ----------------------------
curl -d '{"player":"Betty","boardPosition":2}' -H 'Content-Type: application/json' http://localhost:9090/games/1/move
echo .
