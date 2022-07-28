import ballerina/lang.value;
import ballerina/log;

final GameDB gamedb = check new GameDB("games");

public function getGames() returns Game[]|error {
    log:printInfo("getGames()");
    return check gamedb.retrieve();
}
public function getGame(int id) returns Game|error {
    log:printInfo("getGame(id:" + value:toString(id) + "): ");
    Game game = check gamedb.game(id);
    log:printInfo("    returns " + game.toString());
    return game;
}
public function createGame(string p1, string p2) returns Game|error {
    log:printInfo("createGame(p1:" + p1 + ",p2:" + p2 + ")");

    // p1 is X and board always first to move; TODO randomize this

    int id = check gamedb.insert(p1, p2);
    Game result = check gamedb.game(id);
    log:printInfo("    returns " + result.toString());
    return result;
}
final int[][] WIN_PATTERNS = [
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
function checkWinner(Game game, string player) returns boolean|error {
    // Chiran's version, but it doesn't yield the same results as mine;
    // figure out why later. --TKN
    //
    //check from int[] pattern in WIN_PATTERNS
    //    from int pos in pattern
    //    do {
    //        log:printDebug("Checking pattern " + value:toBalString(pattern));
    //        if game.board[pos] != player {
    //            win = false;
    //        }
    //    };

    log:printInfo("Checking for winner in game " + value:toString(game.id) + " for player " + player);

    foreach int[] pattern in WIN_PATTERNS {
        log:printDebug("Checking pattern " + value:toBalString(pattern) + ": ");

        boolean win = true;
        pattern.forEach(function (int pos) {
            if (game.board[pos] != player) {
                win = false;
            }
        });
        log:printDebug(win.toString());

        if (win) {
            log:printInfo(player + "WIN!");
            return true;
        }
    }
    
    return false;
}
function checkCats(Game game) returns boolean|error { 
    log:printInfo("Checking for cats game in game " + value:toString(game.id));

    // Brute-force method: if any space is open, it's not cats yet
    var openSqs = game.board.filter(function (string sq) returns boolean { return (sq == ""); });
    log:printDebug(value:toString(openSqs.length()) + " squares are open");
    return openSqs.length() == 0;

    // TODO: optimize this to detect when there's an open square on an unwinnable game
    // so the players don't have to go through the motions
}
public function makeMove(Game game, Move move) returns Game|error {
    log:printInfo("makeMove(game:" + value:toBalString(game) + ", move:" + value:toBalString(move) + ")");

    // Game must not be over
    if (game.winner is string) {
        fail error("Game is completed; " + (game.winner ?: "") + " won.");
    }

    // It must be this player's turn
    if (game.playerToMove is string && game.playerToMove != move.player) {
        fail error("Illegal move: Not your turn!");
    }

    ///////////////////////
    // Process the move
    int boardPos = move.boardPosition;

    // That position cannot already be occupied
    if (game.board[boardPos] != "") {
        fail error("Illegal move: Occupied space!");
    }

    // Put the player in that given square
    game.board[boardPos] = move.player;
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
