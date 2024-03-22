OPENAPIGEN=openapi-generator generate -i ttt.yaml

all: ballerina jolie kotlin ruby

ballerina: ttt.yaml
	cd ballerinaserver
	bal build

jolie: ttt.yaml
	echo Jolie doesn't yet support OpenAPI 3.0 specs!

kotlin: ttt.yaml
	mkdir kotlingen
	$(OPENAPIGEN) kotlin-server -o kotlingen

ruby: ttt.yaml
	mkdir rubygen
	$(OPENAPIGEN) ruby-sinatra -o rubygen

clean:
	rm -r kotlingen
	rm -r rubygen

