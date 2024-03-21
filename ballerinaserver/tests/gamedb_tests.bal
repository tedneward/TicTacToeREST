//import ballerina/log;
import ballerina/test;

GameDB db = check new GameDB("target/cache/testdb");

@test:BeforeEach
function newGamedb() returns error? {
    check db.close();
    db = check new GameDB("target/cache/testdb");
}

@test:AfterEach
function cleanupGamedb() returns error? {
    check db.drop();
    check db.close();
}

@test:Config {}
function testConstruction() returns error? {
    Game[] games = check db.retrieve();
    test:assertEquals(games, [], msg="Games not empty: " + games.toString());
}

@test:Config {}
function testCreateAndRetrieveNewGame() returns error? {
    int gameID = check db.insert("Fred", "Barney");

    Game[] games = check db.retrieve();
    test:assertTrue(games.length() > 0, msg="Games empty: " + games.toString());

    string[] emptyBoard = ["", "", "", "", "", "", "", "", ""];

    Game game = check db.game(gameID);
    test:assertEquals(game.playerOne, "Fred");
    test:assertEquals(game.playerTwo, "Barney");
    test:assertEquals(game.board, emptyBoard);
    test:assertEquals(game.playerToMove, "Fred");
}

@test:Config {}
function updateAGame() returns error? {
    int gameID = check db.insert("Fred", "Barney");

    Game[] games = check db.retrieve();
    test:assertTrue(games.length() > 0, msg="Games empty: " + games.toString());

    Game game = check db.game(gameID);

    game.board[0] = "Fred";
    game.playerToMove = "Barney";

    check db.update(game);

    game = check db.game(gameID);
    test:assertEquals(game.playerOne, "Fred");
    test:assertEquals(game.playerTwo, "Barney");
    test:assertEquals(game.board, ["Fred", "", "", "", "", "", "", "", ""]);
    test:assertEquals(game.playerToMove, "Barney");
}

@test:Config {}
function createAndDeleteAGame() returns error? {
    int gameID = check db.insert("Fred", "Barney");
    Game game = check db.game(gameID);
    test:assertEquals(game.id, gameID);

    check db.delete(gameID);

    Game[] games = check db.retrieve("WHERE id = " + gameID.toString());
    test:assertEquals(games, []);
}

