package typedefs_pkg;
    parameter VERSION = "1.1";
    localparam DEFAULT_WORD_W = 8;
    localparam OPCODE_WITH = 8;
    localparam STATE_WITH = 8;
   

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