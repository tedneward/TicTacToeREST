import ballerina/lang.value;
import ballerina/log;

final GameDB gamedb;
function init() returns error? {
    gamedb = check new GameDB("games");
}

public function getGames() returns Game[]|error {
    log:printInfo("getGames()");
    return check gamedb.retrieve();
}
public function getGame(int id) returns Game|error {
    log:printInfo("getGame(id:" + value:toString(id) + "): ");
    Game game = check gamedb.game(id);
    log:printInfo(" returns " + game.toString());
    return game;
}
public function createGame(string p1, string p2) returns Game|error {
    log:printInfo("createGame(p1:" + p1 + ",p2:" + p2 + ")");

    // p1 is X and board always first to move; TODO randomize this

    int id = check gamedb.insert(p1, p2);
    Game|error result = check gamedb.game(id);
    if result is error {
        log:printError(result.toString());
    }
    else {
        log:printInfo("returns " + result.toString());
    }
    return result;
}
function checkWinner(Game game, string player) returns boolean|error {
    log:printInfo("Checking for winner in game " + value:toString(game.id) + " for player " + player);

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

    string[] board = check game.board.fromJsonStringWithType();
    foreach int[] pattern in winPatterns {
        log:printInfo("Checking pattern " + value:toBalString(pattern) + ": ");

        boolean win = true;
        pattern.forEach(function (int pos) {
            if (board[pos] != player) {
                win = false;
            }
        });
        log:printInfo(win.toString());

        if (win) {
            return true;
        }
    }

    return false;
}
function checkCats(Game game) returns boolean|error { 
    log:printInfo("Checking for cats game in game " + value:toString(game.id));

    // Brute-force method: if any space is open, it's not cats yet
    string[] board = check game.board.fromJsonStringWithType();
    var openSqs = board.filter(function (anydata sq) returns boolean { return (value:toString(sq) == ""); });
    log:printInfo(value:toString(openSqs.length()) + " squares are open");
    return openSqs.length() == 0;

    // TODO: optimize this to detect when there's an open square on an unwinnable game
    // so the players don't have to go through the motions
}
public function makeMove(Game game, Move move) returns Game|error {
    log:printInfo("makeMove(game:" + value:toBalString(game) + ", move:" + value:toBalString(move) + ")");

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

    string[] board = check game.board.fromJsonStringWithType();
    // That position cannot already be occupied
    if (board[boardPos] != "") {
        return error("Illegal move: Occupied space!");
    }

    // Put the player in that given square
    board[boardPos] = move.player;
    game.board = board.toJsonString();
    // Update the player moving
    game.playerToMove = (game.playerOne == move.player ? game.playerTwo : game.playerOne);
    // Update the most-recent message
    game.message = "Last move: " + move.player + " takes square " + value:toString(move.boardPosition);

    ///////////////////////
    // Check for winner
    if (check checkWinner(game, game.playerOne)) {
        game.winner = game.playerOne;
        game.message += "; " + game.playerOne + " WINS!";
    }
    else if (check checkWinner(game, game.playerTwo)) {
        game.winner = game.playerTwo;
        game.message += "; " + game.playerTwo + " WINS!";
    }
    else if (check checkCats(game)) {
        game.winner = "(NOBODY)";
        game.message += "; cats game (draw)!";
    }

    log:printInfo("Updating game: " + game.toString());
    _ = check gamedb.update(game);
    return game;
}
