public type GamesBody record {
    string playerOne;
    string playerTwo;
};

public type Game record {
    # id
    readonly int id;
    # playerOne
    string playerOne;
    # playerTwo
    string playerTwo;
    # board
    string[] board;
    # message
    string message;
    # winner
    string winner?;
    # playerToMove
    string playerToMove?;
    # createdAt
    string createdAt?;
};

public type Move record {
    # player
    string player;
    # boardPosition
    int boardPosition;
};
