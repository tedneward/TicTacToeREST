import ballerina/lang.value;
import ballerina/log;

configurable string gamedbfile = "games"; 
final GameDB gamedb = check new GameDB(gamedbfile);

# getGames()
# + return - a list of all the games from the database
isolated function getGames() returns Game[]|error {
    log:printInfo("getGames()");
    return check gamedb.retrieve();
}
# getGame()
# + id - the identifier of the Game we wish to retrieve
# + return - the Game found
isolated function getGame(int id) returns Game|error {
    log:printInfo("getGame(id:" + value:toString(id) + "): ");
    Game game = check gamedb.game(id);
    log:printInfo("    returns " + game.toString());
    return game;
}
# createGame()
# + p1 - player one for the game
# + p2 - player two for the game
# + return - the (now-stored in the database) Game record for this game
isolated function createGame(string p1, string p2) returns Game|error {
    log:printInfo("createGame(p1:" + p1 + ",p2:" + p2 + ")");

    // p1 is always first to move; TODO randomize this

    int id = check gamedb.insert(p1, p2);
    Game result = check gamedb.game(id);
    log:printInfo("    returns " + result.toString());
    return result;
}
final int[][] & readonly WIN_PATTERNS = [
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
# Check if there's a winner
# + game - the game instance whose board we are examining
# + player - the player whose cells we are checking for victory
# + return - boolean true/false for that player's victory
isolated function checkWinner(Game & readonly game, string player) returns boolean|error {
    log:printInfo("Checking for winner in game " + value:toString(game.id) + " for player " + player);
    foreach int[] pattern in WIN_PATTERNS {
        log:printDebug("Checking pattern " + pattern.toBalString() + " against board " + game.board.toString());
        if (pattern.filter((pos) => game.board[pos] == player)).length() == 3 {
            log:printDebug(player + " WIN!");
            return true;
        }
    }
    
    log:printDebug(player + " no win");
    return false;
}
# Check if this is a tie ("cats") game
# + game - the game instance whose board we are examining
# + return - true/false whether this game is tied; note at this point it is a dumb check, and will false out if there is any empty squares
isolated function checkCats(Game game) returns boolean|error { 
    log:printInfo("Checking for cats game in game " + value:toString(game.id));

    // Brute-force method: if any space is open, it's not cats yet
    // NOTE: This has the undesirable side-effect of reporting a false positive--
    // winning games that happen to be on a filled-up board come back as a draw
    string[] openSqs = game.board.filter((sq) => sq == "");
    log:printDebug(value:toString(openSqs.length()) + " squares are open");
    return openSqs.length() == 0;

    // TODO: optimize this to detect when there's an open square on an unwinnable game
    // so the players don't have to go through the motions
    // Thought: go through win patterns, this time checking for == player AND == ""
    // In other words, check for possible winners; if there is one, it's not a cats game
}
# (Attempt to) Make a move on the board
# + game - the game instance against which we are making the move
# + move - the player/cell combo that comprises the move
# + return - the updated Game instance, or an error if the move is illegal
isolated function makeMove(Game game, Move move) returns Game|error {
    log:printInfo("makeMove(game:" + value:toBalString(game) + ", move:" + value:toBalString(move) + ")");

    // Game must not be over
    if (game.winner is string) {
        return error("Game is completed; " + (game.winner ?: "") + " won.");
    }

    // It must be this player's turn
    if (game.playerToMove is string && game.playerToMove != move.player) {
        return error("Illegal move: Not your turn!");
    }

    ///////////////////////
    // Process the move
    int boardPos = move.boardPosition;

    // That position cannot already be occupied
    if (game.board[boardPos] != "") {
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
    if (check checkWinner(game.cloneReadOnly(), game.playerOne)) {
        game.winner = game.playerOne;
        game.message += "; " + game.playerOne + " WINS!";
    }
    else if (check checkWinner(game.cloneReadOnly(), game.playerTwo)) {
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
