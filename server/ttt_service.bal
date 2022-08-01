import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/lang.value;

function init() {
    io:println("Initializer firing; all setup complete");
}

listener http:Listener ep0 = new (9090, config = {host: "localhost"});

service / on ep0 {
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
