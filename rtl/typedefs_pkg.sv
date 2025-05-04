package typedefs_pkg;
    parameter VERSION = "1.1";
    localparam STATE_WITH = 8;
    localparam DATA_WIDTH = 2;
    localparam DIFICULTY_WIDTH = 2;
    localparam ADDR_WIDTH = 5;

        typedef enum logic [STATE_WITH-1:0] {
        IDLE,
        GET_NEXT_SEQUENCE_ITEM,
        SHOW_SEQUENCE,
        GET_PLAYER_INPUT,
        COMPARISON,
        DEFEAT,
        EVALUATE,
        VICTORY
        } state_t;

endpackage