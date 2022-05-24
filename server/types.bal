public type GamesBody record {
    string playerOne?;
    string playerTwo?;
};

public type Game record {
    # id
    int id;
    # playerOne
    string playerOne;
    # playerTwo
    string playerTwo;
    # winner
    string winner?;
    # board
    anydata[] board;
    # playerToMove
    string playerToMove?;
    # createdAt
    string createdAt?;
};

public type Move record {
    # player
    string player?;
    # boardPosition
    int boardPosition?;
};
