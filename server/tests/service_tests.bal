import ballerina/io;
import ballerina/log;
import ballerina/http;
import ballerina/test;

http:Client testClient = check new ("http://localhost:9090/games");

@test:Config {}
function testServiceListAllGames() returns error? {
    http:Response response = check testClient->get("/");
    string payload = check response.getTextPayload();
    log:printInfo(payload);
    test:assertEquals(response.statusCode, 200);
}

@test:Config {}
function testServiceCreateGame() returns error? {
    http:Response response = 
        check testClient->post("/", message={ playerOne: "Wilma", playerTwo: "Betty" });
    test:assertEquals(response.statusCode, 201);
    string payload = check response.getTextPayload();
    io:println("Payload: " + payload);
}
