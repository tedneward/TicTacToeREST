import ballerina/log;
import ballerina/test;

@test:Config {}
function functions_newGame() returns error? {
    Game game = check createGame("Pebbles", "BamBam");
    test:assertEquals(game.playerOne, "Pebbles");
    test:assertEquals(game.playerTwo, "BamBam");
    test:assertEquals(game.board, ["", "", "", "", "", "", "", "", ""]);
}

@test:Config {}
function functions_makeMoveSuccessfully() returns error? {
    Game game = check createGame("Pebbles", "BamBam");

    // Pebbles goes center-square
    Move move = { player: "Pebbles", boardPosition: 4 };
    game = check makeMove(game, move);

    test:assertEquals(game.board[4], "Pebbles");
    test:assertEquals(game.playerToMove, "BamBam");
    test:assertEquals(game.message, "Last move: Pebbles takes square 4");
}

@test:Config {}
function functions_tryToMoveOutOfTurn() returns error? {
    Game game = check createGame("Pebbles", "BamBam");
    test:assertEquals(game.playerToMove, "Pebbles");

    // Pebbles goes center-square
    Game|error result = makeMove(game, { player: "BamBam", boardPosition: 4 });
    test:assertTrue(result is error);
    test:assertTrue((<error>result).message() == "Illegal move: Not your turn!");
}

@test:Config {}
function functions_tryToMoveToOccupiedSpot() returns error? {
    Game game = check createGame("Pebbles", "BamBam");

    // Pebbles goes center-square
    game = check makeMove(game, { player: "Pebbles", boardPosition: 4 });

    // BamBam tries to go center-square too
    Game|error result = makeMove(game, { player: "BamBam", boardPosition: 4});
    test:assertTrue(result is error);
    test:assertTrue((<error>result).message() == "Illegal move: Occupied space!");
}

// test winners
@test:Config {
    dataProvider: winningMovesGen
}
function functions_checkWinners(int[] winningMoves) returns error? {
    Game game = check createGame("Pebbles", "BamBam");
    string currentPlayer = "";

    foreach int move in winningMoves {
        currentPlayer = game.playerToMove ?: "Problem, boss";
        game = check makeMove(game, { player: currentPlayer, boardPosition: move });
        log:printInfo(game.message);
    }

    test:assertEquals(game.winner, currentPlayer);
    test:assertEquals(game.message, "Last move: " + currentPlayer + " takes square " + winningMoves[winningMoves.length() - 1].toString() + "; " + currentPlayer + " WINS!");
}
function winningMovesGen() returns map<[int[]]>|error {
    map<[int[]]> dataSet = {
        "p1, across, top row": [[0, 3, 1, 7, 2]],
        "p1, across, middle row": [[3, 0, 4, 1, 5]],  
        "p1, across, bottom row": [[6, 3, 7, 1, 8]], 
        "p1, down, far-left column": [[0, 1, 3, 2, 6]], 
        "p1, down, center column": [[1, 2, 4, 5, 7]], 
        "p1, down, far-right column": [[2, 3, 5, 6, 8]], 
        "p1, diagonal \\": [[0, 1, 4, 2, 8]],
        "p1, diagonal /": [[2, 0, 4, 1, 6]]
    };
    return dataSet;
}

// test cats
@test:Config {
    dataProvider: nowinnerMovesGen
}
function functions_checkCatsGames(int[] moves) returns error? {
    Game game = check createGame("Pebbles", "BamBam");
    string currentPlayer = "";

    foreach int move in moves {
        currentPlayer = game.playerToMove ?: "Problem, boss";
        game = check makeMove(game, { player: currentPlayer, boardPosition: move });
        log:printInfo(game.message);
    }

    test:assertEquals(game.winner, currentPlayer);
    test:assertEquals(game.message, "Last move: " + currentPlayer + " takes square " + moves[moves.length() - 1].toString() + "; " + currentPlayer + " WINS!");
}
function nowinnerMovesGen() returns map<[int[]]>|error {
    map<[int[]]> dataSet = {
        "cats 1": [[0, 3, 6, 7, 2, 1, 8, 5, 4]]
        //"cats 2": [[0, 1, 2, 3, 6, 8, 4, 7, 5]]
    };
    return dataSet;
}

// TODO: test cats games before board is entirely filled
