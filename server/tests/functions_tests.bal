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

@test:Config {
    dataProvider: winningBoards
}
function functions_checkWinners(string[] board) returns error? {
    Game game = { id: -1, playerOne: "P1", playerTwo: "P2",
        board: board,
        message: ""
    };
    boolean result = check checkWinner(game.cloneReadOnly(), "P1");
    test:assertTrue(result);
    result = check checkWinner(game.cloneReadOnly(), "P2");
    test:assertFalse(result);
}

function winningBoards() returns map<[string[]]>|error {
    map<[string[]]> dataSet = {
        "p1, across, top row": [
            ["P1", "P1", "P1", 
             "P2", "P2", "P1",
             "P2", "P1", "P2"]
        ],
        "p1, across, middle row": [
            ["P2", "P2", "P1", 
             "P1", "P1", "P1",
             "P2", "P1", "P2"]
        ],  
        "p1, across, bottom row": [
            ["P2", "P1", "P2",
             "P2", "P2", "P1",
             "P1", "P1", "P1"]
        ], 
        "p1, down, far-left column": [
            ["P1", "P2", "P2",
             "P1", "P2", "P1",
             "P1", "P1", "P2"]
        ], 
        "p1, down, center column": [
            ["P2", "P1", "P2",
             "P2", "P1", "P1",
             "P1", "P1", "P2"]
        ], 
        "p1, down, far-right column": [
            ["P2", "P2", "P1",
             "P1", "P2", "P1",
             "P2", "P1", "P1"]
        ], 
        "p1, diagonal slash": [
            ["P1", "P2", "P2",
             "P2", "P1", "P1",
             "P2", "P1", "P1"]
        ],
        "p1, diagonal backslash": [
            ["P2", "P2", "P1",
             "P2", "P1", "P1",
             "P1", "P1", "P2"]
        ]
    };
    return dataSet;
}

// test cats
@test:Config {
    dataProvider: drawBoards
}
function functions_checkCats(string[] board) returns error? {
    Game game = { id: -1, playerOne: "P1", playerTwo: "P2",
        board: board,
        message: ""
    };
    boolean result = check checkWinner(game.cloneReadOnly(), "P1");
    test:assertFalse(result);
    result = check checkWinner(game.cloneReadOnly(), "P2");
    test:assertFalse(result);
    result = check checkCats(game);
    test:assertTrue(result);
}
function drawBoards() returns map<[string[]]>|error {
    map<[string[]]> dataSet = {
        "p1, across, top row": [
            ["P1", "P2", "P1", 
             "P2", "P2", "P1",
             "P1", "P1", "P2"]
        ]
    };
    return dataSet;
}

@test:Config {
    dataProvider: stillOpenBoards
}
function functions_checkNoWinnerNoDraw(string[] board) returns error? {
    Game game = { id: -1, playerOne: "P1", playerTwo: "P2",
        board: board,
        message: ""
    };
    boolean result = check checkWinner(game.cloneReadOnly(), "P1");
    test:assertFalse(result);
    result = check checkWinner(game.cloneReadOnly(), "P2");
    test:assertFalse(result);
    result = check checkCats(game);
    test:assertFalse(result);
}
function stillOpenBoards() returns map<[string[]]>|error {
    map<[string[]]> dataSet = {
        "empty board": [
            ["", "", "", 
             "", "", "",
             "", "", ""]
        ]
    };
    return dataSet;
}


// TODO: test cats games before board is entirely filled
