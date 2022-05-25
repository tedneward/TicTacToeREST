import ballerina/io;
import ballerina/lang.value;
import ballerina/time;

int nextId = 1;
table<Game> key(id) games = table [  // table
    {id:0, playerOne:"Fred", playerTwo:"Barney", 
        board:[" ", " ", " ", "Fred", "Fred", "Barney", " ", " ", " "], message: "Sample game",
        playerToMove:"Barney", createdAt: time:utcToString(time:utcNow()) }
];

public function getGames() returns Game[] {
    io:println("getGames()");

    return games.toArray();
}
public function getGame(int id) returns Game? {
    io:println("getGame(id:" + value:toString(id) + ")");

    return games[id];
}
public function createGame(string p1, string p2) returns Game {
    io:println("createGame(p1:" + p1 + ",p2:" + p2 + ")");

    // p1 is X and therefore always first to move; TODO randomize this

    int gid = ++nextId;
    Game game = { id:gid, playerOne:p1, playerTwo:p2,
        board:[" ", " ", " ", " ", " ", " ", " ", " ", " " ],
        message: "Player 1 (X) is " + p1 + " and Player 2 (O) is " + p2 + ".",
        playerToMove: p1, createdAt: time:utcToString(time:utcNow()) };
    games.add(game); // table

    return game;
}
function checkWinner(Game game, string player) returns boolean {
    io:println("Checking for winner in game " + value:toString(game.id) + " for player " + player);

    var winPatterns = [
        // Down
        [0, 3, 6],
        [1, 4, 7],
        [2, 5, 8],
        // Across
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8],
        // Diagonal
        [0, 4, 8],
        [2, 4, 6]
    ];

    foreach int[] pattern in winPatterns {
        io:print("Checking pattern " + value:toBalString(pattern) + ": ");

        boolean win = true;
        pattern.forEach(function (int pos) {
            if (game.board[pos] != player) {
                win = false;
            }
        });
        io:println(win);

        if (win) {
            return true;
        }
    }

    return false;
}
function checkCats(Game game) returns boolean { 
    io:println("Checking for cats game in game " + value:toString(game.id));

    // Brute-force method: if any space is open, it's not cats yet
    var openSqs = game.board.filter(function (anydata sq) returns boolean { return (value:toString(sq) == " "); });
    io:println(value:toString(openSqs.length()) + " squares are open");
    return openSqs.length() == 0;

    // TODO: optimize this to detect when there's an open square on an unwinnable game
    // so the players don't have to go through the motions
}
public function makeMove(Game game, Move move) returns Game|error {
    io:println("makeMove(game:" + value:toBalString(game) + ", move:" + value:toBalString(move) + ")");

    ///////////////////////
    // Process the move
    int boardPos = move.boardPosition;

    // Game must not be over
    if (game.winner != () ) {
        return error("Game is completed; " + (game.winner ?: "") + " won.");
    }

    // It must be this player's turn
    if (game.playerToMove != () && game.playerToMove != move.player) {
        return error("Illegal move: Not your turn!");
    }

    // That position cannot already be occupied
    if (game.board[boardPos] != " ") {
        return error("Illegal move: Occupied space!");
    }

    // Put the player in that given square
    game.board[boardPos] = move.player;
    // Update the player moving
    game.playerToMove = (game.playerOne == move.player ? game.playerTwo : game.playerOne);
    // Update the most-recent message
    game.message = "Last move: " + move.player + " takes square " + value:toString(move.boardPosition);

    ///////////////////////
    // Check for winner
    if (checkWinner(game, game.playerOne)) {
        game.winner = game.playerOne;
        game.message += "; " + game.playerOne + " WINS!";
    }
    else if (checkWinner(game, game.playerTwo)) {
        game.winner = game.playerTwo;
        game.message += "; " + game.playerTwo + " WINS!";
    }
    else if (checkCats(game)) {
        game.winner = "(NOBODY)";
        game.message += "; cats game (draw)!";
    }

    return game;
}
