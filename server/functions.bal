import ballerina/lang.value;
import ballerina/log;

configurable string username = "admin";
configurable string password = "admin";

final GameDB gamedb = check new GameDB("games");

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
    Game result = check gamedb.game(id);
    log:printInfo("returns " + result.toString());
    return result;
}
function checkWinner(Game game, string player) returns boolean|error {
    log:printInfo("Checking for winner in game " + value:toString(game.id) + " for player " + player);

        boolean win = true;

        check from int[] pattern in WIN_PATTERNS
            from int pos in pattern
            do {
                log:printDebug("Checking pattern " + value:toBalString(pattern) + ": ");
                if game.board[pos] != player {
                    win = false;
                }
            };
        return win;
}
function checkCats(Game game) returns boolean|error { 
    log:printInfo("Checking for cats game in game " + value:toString(game.id));

    // Brute-force method: if any space is open, it's not cats yet
    //string[] board = check game.board.fromJsonStringWithType();
    var openSqs = game.board.filter(function (string sq) returns boolean { return (sq == ""); });
    log:printDebug(value:toString(openSqs.length()) + " squares are open");
    return openSqs.length() == 0;

    // TODO: optimize this to detect when there's an open square on an unwinnable game
    // so the players don't have to go through the motions
}
public function makeMove(Game game, Move move) returns Game|error {
    log:printInfo("makeMove(game:" + value:toBalString(game) + ", move:" + value:toBalString(move) + ")");

    // Game must not be over
    if game.winner is string {
        fail error("Game is completed; " + (game.winner ?: "") + " won.");
    }

    string movePlayer = move.player;
    // It must be this player's turn
    if game.playerToMove is string && game.playerToMove != movePlayer {
        fail error("Illegal move: Not your turn!");
    }

    ///////////////////////
    // Process the move
    int boardPos = move.boardPosition;

    //string[] board = check game.board.fromJsonStringWithType();
    // That position cannot already be occupied
    if game.board[boardPos] != "" {
        fail error("Illegal move: Occupied space!");
    }

    // Put the player in that given square
    game.board[boardPos] = movePlayer;

    // Update the player moving
    game.playerToMove = (game.playerOne == movePlayer ? game.playerTwo : game.playerOne);
    // Update the most-recent message
    game.message = "Last move: " + move.player + " takes square " + value:toString(move.boardPosition);

    ///////////////////////
    // Check for winner
    if check checkWinner(game, game.playerOne) {
        game.winner = game.playerOne;
        game.message += "; " + game.playerOne + " WINS!";
    } else if check checkWinner(game, game.playerTwo) {
        game.winner = game.playerTwo;
        game.message += "; " + game.playerTwo + " WINS!";
    } else if check checkCats(game) {
        game.winner = "(NOBODY)";
        game.message += "; cats game (draw)!";
    }

    log:printInfo("Updating game: " + game.toString());
    _ = check gamedb.update(game);
    return game;
}
