import ballerina/http;
import ballerina/lang.value;
import ballerina/log;

listener http:Listener ep0 = new (9090);

service / on ep0 {
    resource function get games() returns Game[] {
        log:printInfo("GET /games: ");
        Game[]|error games = getGames();
        if games is error {
            log:printError("Failed to get games", games);
            return [];
        }
        log:printInfo("Current games", count = games.length());
        return games;
    }

    resource function get games/[int id]() returns Game|http:NotFound {
        log:printInfo("GET /games/{" + value:toString(id) + "}");

        Game|error game = getGame(id);
        if game is error {
            log:printWarn("Nil || Error: NotFound");
            return <http:NotFound>{body: string `Game id:${id} is not in this service's database`};
        }
        log:printInfo("Found ", game = game);
        return game;
    }

    resource function post games(@http:Payload GamesBody payload) returns http:Created|http:BadRequest|http:MethodNotAllowed {
        log:printInfo("POST /games " + value:toBalString(payload) + ": ");

        Game|error game = createGame(payload.playerOne, payload.playerTwo);
        if game is error {
            log:printError("Error: BadRequest", game);
            return http:BAD_REQUEST;
        }
        log:printInfo("Created: " + game.toString());
        return <http:Created>{body: game};
    }

    resource function post games/[int id]/move(@http:Payload Move payload) returns Game|http:BadRequest|http:NotFound {
        log:printInfo("POST /games/" + value:toString(id) + "/move " + value:toBalString(payload) + ": ");

        Game|error game = getGame(id);
        if game is error {
            log:printError("Error: NotFound", game);
            return <http:NotFound>{body: string `Game id:${id} is not in this service's database`};
        }
        log:printInfo("Checking move; game " + game.toString());
        Game|error result = makeMove(game, payload);
        if result is error {
            return <http:BadRequest>{body: string `That move is illegal: ${result.message()}`};
        }
        log:printInfo("Moved", game = game);
        return result;
    }
}
