# TicTacToeREST
REST server for a game of tic-tac-toe, also known in the UK as "naughts and crosses". Written with an OpenAPI/Swagger 3.x interface (in `ttt.yaml`), with the intent that this is the "contract-first" form for the TTT server.

Originally this started as a Ballerina-only exercise, but I've since decided that I want it to be something that can explore other OpenAPI-based options, such as Jolie or more traditional languages+frameworks.

As such, for some of the traditional tools, I'm assuming the use of the [OpenAPI generator](https://github.com/OpenAPITools/openapi-generator) tool, `openapi-generator`, to generate the server-side bindings. (See the full syntax as used in the `Makefile` to make each binding.)

## TODO list

* [ ] Support for different board sizes: 4x4, 5x5, 6x6, 4x6, 5x7, etc; this will also probably necessitate support for 4- or 5-length winning combinations
* [ ] Refactor YAML to be a bit more sane and a bit more comprehensive
* [ ] Generated client SDKs for Java, C#, etc
* [ ] Build a few game clients (in separate repositories)
