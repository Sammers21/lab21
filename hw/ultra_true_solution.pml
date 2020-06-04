
typedef CrossRoadr {
    // is it locked or not
    // 0 - not locked
    // 1 - locked
    byte locked = 0;
};

// 0 - red cross back
// 1 - green cross red
// 2 - purple cross green
// 3 - blue cross red
// 4 - blue cross green
// 5 - blue cross purple
CrossRoadr all_crosses[6];

typedef Lane {
    // indexes from all_crosses
    int crosses[3];
    // lenght of crosses array
    int crosses_len = 0;
    // channel for signals
    chan sygnals = [1] of {byte};
};

// 0 - red
// 1 - green
// 2 - black
// 3 - purple
// 4 - blue
Lane lanes[5];

proctype LaneController(int lane_numb) {
    byte signal;
    printf("\nController on lane №%d has been started. Crossroads count:%d", lane_numb, lanes[lane_numb].crosses_len);
    do
    :: nempty(lanes[lane_numb].sygnals) -> 
        lanes[lane_numb].sygnals?signal;
        printf("\n[Controller №%d]: received a signal", lane_numb);
    :: else -> skip
    od
}

init {
    // red configuration
    lanes[0].crosses_len = 3;
    lanes[0].crosses[0] = 0;
    lanes[0].crosses[1] = 1;
    lanes[0].crosses[2] = 3;
    // green configuration
    lanes[1].crosses_len = 3;
    lanes[1].crosses[0] = 1;
    lanes[1].crosses[1] = 2;
    lanes[1].crosses[2] = 4;
    // black configuration
    lanes[2].crosses_len = 1;
    lanes[2].crosses[0] = 0;
    // purple configuration
    lanes[3].crosses_len = 2;
    lanes[3].crosses[0] = 2;
    lanes[3].crosses[1] = 5;
    // blue configuration
    lanes[4].crosses_len = 3;
    lanes[4].crosses[0] = 3;
    lanes[4].crosses[1] = 4;
    lanes[4].crosses[2] = 5
    
    // start controllers
    run LaneController(0);
    run LaneController(1);
    run LaneController(2);
    run LaneController(3);
    run LaneController(4);
    
    lanes[2].sygnals ! 1;
}