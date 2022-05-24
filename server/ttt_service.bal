import ballerina/http;
import ballerina/io;
import ballerina/lang.value;

listener http:Listener ep0 = new (9090, config = {host: "localhost"});

service / on ep0 {
    resource function get games() 
        returns Game[] 
    {
        io:println("GET /games");
        return getGames();
    }
    resource function get games/[int  id]() 
        returns Game|http:NotFound 
    {
        io:println("GET /games/{" + int:toHexString(id) + "}");

        Game|error res = getGame(id);
        if (res is error) {
            return <http:NotFound>{};
        }
        else {
            return res;
        }
    }
    resource function post games(@http:Payload GamesBody payload) 
        returns http:Created|http:BadRequest|http:MethodNotAllowed
    {
        io:println("POST /games " + value:toBalString(payload));

        Game game = createGame(payload.playerOne ?: "", payload.playerTwo ?: "");

        return <http:Created>{ body:game };
    }
    resource function post games/[int  id]/move(@http:Payload Move payload)
        returns Game|http:NotFound|http:BadRequest
    {
        io:println("POST /games/" + int:toHexString(id) + "/move " + value:toBalString(payload));

        Game|error game = getGame(id);
        if (game is error) {
            http:NotFound notFound = { };
            return notFound;
        }
        else {
            Game|error result = makeMove(game, payload);
            if (result is error) {
                http:BadRequest badRequest = { };
                return badRequest;
            }
            else {
                return result;
            }
        }
    }
}


