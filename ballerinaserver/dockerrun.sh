#!/bin/sh
echo Running generated Docker image
docker run -d -p 9090:9090 tedneward/tictactoe:v1.0.0

