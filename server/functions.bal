import ballerina/io;
import ballerina/lang.value;
import ballerina/time;

int nextId = 1;
table<Game> key(id) games = table [
    {id:0, playerOne:"Fred", playerTwo:"Barney", 
        board:[" ", " ", " ", " ", " ", " ", " ", " ", " "],
        playerToMove:"Fred", createdAt: time:utcToString(time:utcNow()) }
];

public function getGames() returns Game[] {
    io:println("getGames()");

    return games;
}
public function getGame(int id) returns Game {
    io:println("getGame(id:" + int:toHexString(id) + ")");

    return games[id];
}
public function createGame(string p1, string p2) returns Game {
    io:println("createGame(p1:" + p1 + ",p2:" + p2 + ")");

    int gid = ++nextId;
    Game game = { id:gid, playerOne:p1, playerTwo:p2,
        board:[" ", " ", " ", " ", " ", " ", " ", " ", " " ],
        playerToMove: p1, createdAt: time:utcToString(time:utcNow()) };
    games.add(game);

    return game;
}
function makeMove(Game game, Move move) returns Game|error {
    io:println("makeMove(game:" + value:toBalString(game) + ", move:" + value:toBalString(move) + ")");

    

    return game;
}
