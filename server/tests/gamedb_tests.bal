//import ballerina/log;
import ballerina/test;

@test:Config {}
function testConstruction() returns error? {
    GameDB gamedb = check new GameDB("target/testConstruction");

    Game[] games = check gamedb.retrieve();
    test:assertEquals(games, [], msg="Games not empty: " + games.toString());

    check gamedb.close();
}

@test:Config {}
function testCreateAndRetrieveNewGame() returns error? {
    GameDB gamedb = check new GameDB("target/testCreateAndRetrieveNewGame");

    int gameID = check gamedb.insert("Fred", "Barney");

    Game[] games = check gamedb.retrieve();
    test:assertTrue(games.length() > 0, msg="Games empty: " + games.toString());

    Game game = check gamedb.game(gameID);
    test:assertEquals(game.playerOne, "Fred");
    test:assertEquals(game.playerTwo, "Barney");
    test:assertEquals(game.board, "[\"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\"]");
    test:assertEquals(game.playerToMove, "Fred");

    check gamedb.close();
}

@test:Config {}
function testMove() returns error? {
    GameDB gamedb = check new GameDB("target/testCreateAndRetrieveNewGame");

    int gameID = check gamedb.insert("Fred", "Barney");

    Game[] games = check gamedb.retrieve();
    test:assertTrue(games.length() > 0, msg="Games empty: " + games.toString());

    Game game = check gamedb.game(gameID);

    game.board = "[\"Fred\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\"]";
    game.playerToMove = "Barney";

    check gamedb.update(game);

    game = check gamedb.game(gameID);
    test:assertEquals(game.playerOne, "Fred");
    test:assertEquals(game.playerTwo, "Barney");
    test:assertEquals(game.board, "[\"Fred\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\"]");
    test:assertEquals(game.playerToMove, "Barney");

    check gamedb.close();
}
