//import ballerina/log;
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

// test cats

// TODO: test cats games before board is entirely filled
