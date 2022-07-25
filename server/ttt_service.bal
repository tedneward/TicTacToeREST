import ballerina/http;
import ballerina/log;

listener http:Listener ep0 = new (9090, config = {host: "localhost"});

service / on ep0 {
    resource function get games() returns Game[]
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
    resource function get games/[int  id]() returns Game|http:NotFound 
    {
        log:printInfo(string `GET /games/${id}`);

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
    resource function post games(@http:Payload GamesBody payload) returns http:Created|http:BadRequest|http:MethodNotAllowed
    {
        log:printInfo(string `POST /games ${payload.toBalString()}: `);

        Game|error game = createGame(payload.playerOne, payload.playerTwo);
        if game is error {
            log:printError("Error: BadRequest", game);
            return <http:BadRequest>{};
        }
        else {
            log:printInfo(string `Created: ${game.toString()}`);
            return <http:Created>{ body:game };
        }
    }
    resource function post games/[int  id]/move(@http:Payload Move payload) returns Game|http:NotFound|http:BadRequest
    {
        log:printInfo(string `POST /games/${id}/move ${payload.toBalString()}: `);

        Game?|error game = getGame(id);
        if (game is ()) {
            log:printWarn("    Error: NotFound");
            return <http:NotFound> { body: string `Game ${id} is not in this service's database` };
        }
        else if (game is error) {
            log:printError("    Error: BadRequest", game);
            return <http:BadRequest> {};
        }
        else {
            log:printInfo(string `Checking move; game ${game.toString()}`);
            Game|error result = makeMove(game, payload);
            if (result is error) {
                log:printError(string `    Error: Illegal move: ${result.toBalString()}`, result);
                return <http:BadRequest> { body: string `That move is illegal:${result.toBalString()}` };
            }
            else {
                log:printInfo("    Moved", game=game);
                return result;
            }
        }
    }
}
