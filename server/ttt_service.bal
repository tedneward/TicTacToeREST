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
        io:println("GET /games/{" + value:toString(id) + "}");

        Game? game = getGame(id);
        if (game is ()) {
            return <http:NotFound>{};
        }
        else {
            return game;
        }
    }
    resource function post games(@http:Payload GamesBody payload) 
        returns http:Created|http:BadRequest|http:MethodNotAllowed
    {
        io:println("POST /games " + value:toBalString(payload));

        Game game = createGame(payload.playerOne, payload.playerTwo);

        return <http:Created>{ body:game };
    }
    resource function post games/[int  id]/move(@http:Payload Move payload)
        returns Game|http:NotFound|http:BadRequest
    {
        io:println("POST /games/" + value:toString(id) + "/move " + value:toBalString(payload));

        Game? game = getGame(id);
        if (game is ()) {
            return <http:NotFound> { body:"Game " + value:toString(id) + " is not in this service's database" };
        }
        else {
            Game|error result = makeMove(game, payload);
            if (result is error) {
                return <http:BadRequest> { body:"That move is illegal:" + error:message(result) };
            }
            else {
                return result;
            }
        }
    }
}


