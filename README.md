# TicTacToeREST
REST server for a game of tic-tac-toe, also known in the UK as "naughts and crosses".

## Architecture
Classic box-arrow-box-arrow-cylinder architecture.

HTTP API layer calls into a "business layer" in which all the domain logic is implemented. Business layer in turn uses an embedded RDBMS ([H2](https://www.h2database.com), in this case) to store all data, in this case, the current games going on. Whole thing will live inside of a Docker container for easy cloud deployment. I choose an embedded database because that keeps this all entirely to one process, and I don't really expect to need to scale.

(Hey, it's deliberately designed to be simple--the goal here is to show off Ballerina, not to show how many boxes and arrows and cylinders I can cram into a single JPEG.)

As little hand-written code as possible the closer we get to the API layer; I want to let Ballerina show off what it can/cannot do as much as possible. Similarly, as few Java libraries as possible at the API layer. (Currently the only explicit JAR dependency is the H2 jar, and that's managed within Ballerina's build file.)

## Code organization
HTTP API, described by [this OpenAPI YAML](./ttt.yaml) (which could use some refactoring of its own; I deliberately went out and found a spec I didn't write just to be a bit of a test against the Ballerina OpenAPI-generating codebase), is used to generate the [ttt_service.bal](./server/ttt_service.bal) service endpoints, which then call into [functions.bal](./server/functions.bal) where the "real work" gets done. This mimics the basic idea that an API layer should really do as little as possible beyond parameter validation and HTTP-I/O, and allow the work to be done elsewhere.

Inside of [functions.bal](./server/functions.bal), I implement a set of TicTacToe module-level functions (hence the name of the file) which create games, retrieve a game from the database, list all the games in the database, and make moves. Because checking for winners and "cats" games is a little non-trivial, I broke those out into their own functions.

These functions in turn make use of a table data gateway I call [GameDB](./server/gamedb.bal) and implemented as a class--mostly to show that many of our classic OO patterns are available if/when we choose to use them. Were this a more production-focused project, I'd be tempted to bundle the GameDB code into the functions, mostly because I don't anticipate I'd ever want a different storage layer.

The board is represented as a string array, with each square denoting ownership by putting the player's name there. There's more terse ways to do it, but this is the easiest, and again, I'm not planning on needing to scale this out. (Besides, drive space is cheap.)

## TODO list

* [X] Basic CRUD and logic
* [X] Database persistence
* [X] Unit and module tests
* [ ] Build to Docker
* [ ] CI/CD to DockerHub, then to cloud (Azure)
* [ ] Ballerina-style markup docs
* [ ] Support for different board sizes: 4x4, 5x5, 6x6, 4x6, 5x7, etc; this will also probably necessitate support for 4- or 5-length winning combinations
* [ ] AI players, using Java interop to call into some kind of Java-centric decision-making engine
* [ ] Refactor YAML to be a bit more sane and a bit more comprehensive
* [ ] Generated client SDKs for Java, C#, etc
* [ ] Build a few game clients (in separate repositories)
