import ballerina/log;
import ballerina/sql;
import ballerina/time;
import ballerina/lang.value;
import ballerinax/java.jdbc;

isolated class GameDB {
    private final jdbc:Client jdbcClient;

    function init(string file) returns error? {
        self.jdbcClient = check new ("jdbc:h2:file:./" + file, username, password);

        // Turn on tracing
        _ = check self.jdbcClient->execute(`SET TRACE_LEVEL_SYSTEM_OUT 1`);

        // Runs the prerequisite setup for the example.
        _ = check self.jdbcClient->execute(CREATE_TABLE_QUERY);

        log:printInfo("Initialization completed");
    }

    function raw() returns jdbc:Client {
        return self.jdbcClient;
    }

    function insert(string playerOne, string playerTwo) returns int|error {
        log:printInfo("GameDB::insert");

        time:Utc createdAt = time:utcNow();
        sql:ParameterizedQuery query = `INSERT INTO Games (playerOne, playerTwo, board, playerToMove, createdAt)
             VALUES (${playerOne},${playerTwo}, ${INITIAL_BOARD}, ${playerOne}, ${createdAt})`;
        sql:ExecutionResult result = check self.jdbcClient->execute(query);
        log:printInfo("SQL RESULT: " + result.toString());
        (int|string)? insertId = result.lastInsertId;
        return insertId is int ? insertId : -1;
    }

    function game(int id) returns Game|error {
        log:printInfo("GameDB::game(" + id.toString() + ")");
        Game result = check self.jdbcClient->queryRow(`SELECT * FROM Games where id = ${id}`);
        log:printDebug("result: " + value:toBalString(result));
        return result;
    }

    function retrieve(string? clause = ()) returns Game[]|error {
        sql:ParameterizedQuery query = `SELECT * FROM Games`;
        if clause is string {
            query = `SELECT * FROM Games WHERE ${clause}`;
        }
        stream<Game, error?> results = self.jdbcClient->query(query);
        Game[]? games = check from Game game in results
            select game;

        return games is Game[] ? games : [];
    }

    function update(Game game) returns error? {
        log:printInfo("GameDB::update(" + game.toString() + ")");
        sql:ParameterizedQuery query =
            `UPDATE Games SET playerToMove=${game.playerToMove}, 
             board = ${game.board} WHERE id = ${game.id}`;
        _ = check self.jdbcClient->execute(query);
    }

    function delete(int id) returns error? {
        log:printInfo("GameDB::delete(" + id.toString() + ")");
        _ = check self.jdbcClient->execute(`DELETE FROM Games WHERE id = ${id}`);
    }

    function drop() returns error? {
        _ = check self.jdbcClient->execute(`DROP TABLE Games`);
    }

    function close() returns error? {
        check self.jdbcClient.close();
    }
}
