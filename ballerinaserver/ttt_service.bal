import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/lang.value;

function init() {
    io:println("Initializer firing; all setup complete");
}

listener http:Listener ep0 = new (9090);

# The (singular) service for this TicTacToe implementation
service / on ep0 {
    # Return a list of all the games already in the database
    # + return - the complete database, warning this could be a lot of data!
    isolated resource function get games() returns Game[]
    {
        log:printInfo("GET /games: ");
        Game[]|error games = getGames();
        if games is error {
            log:printError("Failed to get games", games);
            return [];
        }
        else {
            log:printInfo("Current games", count = games.length());
            return games;
        }
    }
    # Return a particular game from the database
    # identified by its unique identifier.
    # (Games can be purged and ids reused, just FYI.)
    # + id - the id of the game to retrieve
    # + return - either the Game data, or a NotFound (404) if that ID isn't found in the database
    isolated resource function get games/[int  id]() returns Game|http:NotFound 
    {
        log:printInfo("GET /games/{" + value:toString(id) + "}");

        Game?|error game = getGame(id);
        if (game is ()) {
            log:printWarn("Nil: NotFound");
            return <http:NotFound>{};
        }
        else if game is error {
            log:printError("Error: NotFound", game);
            return <http:NotFound>{};
        }
        else {
            log:printInfo("Found ", game=game);
            return game;
        }
    }
    # Put new game into the database by providing the basics
    # (that is, two players' names, in the respective P1 and P2
    # spots in the Game payload). The rest of the Game data will
    # be filled in.
    # + payload - the GameBody payload to update, assuming only P1 and P2 are filled in
    # + return - either a Created (201) if all is good, or a BadRequest(400) or MethodNotAllowed (4xx) depending on what is wrong
    isolated resource function post games(@http:Payload GamesBody payload) returns http:Created|http:BadRequest|http:MethodNotAllowed
    {
        log:printInfo("POST /games " + value:toBalString(payload) + ": ");

        Game|error game = createGame(payload.playerOne, payload.playerTwo);
        if game is error {
            log:printError("Error: BadRequest", game);
            return <http:BadRequest>{};
        }
        else {
            log:printInfo("Created: " + game.toString());
            return <http:Created>{ body:game };
        }
    }
    # Play a move on a particular game; this will trigger enforcement of all
    # game logic, so that games cannot be (easily) cheated. Results will be 
    # updated in the database and a Game object returned, with the 'message'
    # element describing what just happened.
    # + id - the Game to post the move to
    # + payload - the move that is being played
    # + return - the Game if the move is accepted, a NotFound (404) if that ID isn't recongized, or a BadRequest (400) if that's an illegal move somehow
    resource function post games/[int id]/move(@http:Payload Move payload)
        returns Game|http:NotFound|http:BadRequest
    {
        log:printInfo("POST /games/" + value:toString(id) + "/move " + value:toBalString(payload) + ": ");

        Game?|error game = getGame(id);
        if (game is ()) {
            log:printWarn("    Error: NotFound");
            return <http:NotFound> { body:"Game " + value:toString(id) + " is not in this service's database" };
        }
        else if (game is error) {
            log:printError("    Error: BadRequest", game);
            return <http:BadRequest> {};
        }
        else {
            log:printInfo("    Checking move; game " + game.toString());
            Game|error result = makeMove(game, payload);
            if (result is error) {
                log:printError("    Error: Illegal move: " + result.toString(), result);
                return <http:BadRequest> { body:"That move is illegal:" + result.message()};
            }
            else {
                log:printInfo("    Moved", game=game);
                return result;
            }
        }
    }
}
