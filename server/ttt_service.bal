import ballerina/http;
import ballerina/io;
import ballerina/lang.value;

listener http:Listener ep0 = new (9090, config = {host: "localhost"});

service / on ep0 {
    resource function get games() 
        returns Game[] 
    {
        io:print("GET /games: ");
        Game[]|error games = getGames();
        if games is error {
            io:println("[]");
            return [];
        }
        else {
            io:println("Currently " + games.length().toString() + " games.");
            return games;
        }
    }
    resource function get games/[int  id]() 
        returns Game|http:NotFound 
    {
        io:print("GET /games/{" + value:toString(id) + "}");

        Game?|error game = getGame(id);
        if (game is ()) {
            io:println("Nil: NotFound");
            return <http:NotFound>{};
        }
        else if game is error {
            io:println("Error: NotFound");
            return <http:NotFound>{};
        }
        else {
            io:println("Found " + game.toString());
            return game;
        }
    }
    resource function post games(@http:Payload GamesBody payload) 
        returns http:Created|http:BadRequest|http:MethodNotAllowed
    {
        io:println("POST /games " + value:toBalString(payload) + ": ");

        Game|error game = createGame(payload.playerOne, payload.playerTwo);
        if game is error {
            io:println("Error: BadRequest");
            return <http:BadRequest>{};
        }
        else {
            io:println("Created: " + game.toString());
            return <http:Created>{ body:game };
        }
    }
    resource function post games/[int  id]/move(@http:Payload Move payload)
        returns Game|http:NotFound|http:BadRequest
    {
        io:println("POST /games/" + value:toString(id) + "/move " + value:toBalString(payload) + ": ");

        Game?|error game = getGame(id);
        if (game is ()) {
            io:println("    Error: NotFound");
            return <http:NotFound> { body:"Game " + value:toString(id) + " is not in this service's database" };
        }
        else if (game is error) {
            io:println("    Error: BadRequest");
            return <http:BadRequest> {};
        }
        else {
            io:println("    Checking move; game " + game.toString());
            Game|error result = makeMove(game, payload);
            if (result is error) {
                io:println("    Error: Illegal move: " + result.toString());
                return <http:BadRequest> { body:"That move is illegal:" + error:message(result) };
            }
            else {
                io:println("    " + game.toString());
                return result;
            }
        }
    }
}


