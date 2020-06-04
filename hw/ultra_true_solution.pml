
typedef CrossRoadr {
    // is it locked or not
    // false - not locked
    // true - locked
    bool locked = 0;
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
    :: (nempty(lanes[lane_numb].sygnals)) ->
            int attempt = 0; 
            lanes[lane_numb].sygnals?signal
            printf("\n[Controller №%d]: received a signal, trying to aquire all the resources", lane_numb);
            do
            ::  
                attempt = attempt + 1;
                printf("\n[Controller №%d]: attempt to aquire №%d", lane_numb, attempt);
                bool aquired;
                bool can_aquire = true;
                int idx;
                int cross;
                atomic {
                    // check if can aquire
                    idx = 0;
                    do
                    :: (idx < lanes[lane_numb].crosses_len) ->
                    cross = lanes[lane_numb].crosses[idx];
                    if
                    :: (all_crosses[cross].locked) -> can_aquire = false -> skip;
                    :: else -> skip;
                    fi
                    idx = idx + 1;
                    :: else -> 
                    break;
                    od
                    // aquire if can
                    idx = 0;
                    if
                    :: can_aquire -> 
                    printf("\n[Controller №%d]: can aquire", lane_numb)
                    do
                    :: (idx < lanes[lane_numb].crosses_len) ->
                        cross = lanes[lane_numb].crosses[idx];
                        all_crosses[cross].locked = true
                        printf("\n[Controller №%d]: cross №:%d has been aquired", lane_numb, cross);
                        idx = idx + 1;
                    :: else -> break;
                    od
                    aquired = true
                    :: else ->
                    printf("\n[Controller №%d]: could not aquire", lane_numb)
                    aquired = false
                    fi
                }
                if
                :: aquired ->
                    idx = 0;
                    atomic {
                        printf("\n[Controller №%d]: releasing locks", lane_numb)
                        do
                        :: (idx < lanes[lane_numb].crosses_len) ->
                        cross = lanes[lane_numb].crosses[idx];
                        all_crosses[cross].locked = false
                        printf("\n[Controller №%d]: cross №:%d has been released", lane_numb, cross);
                        idx = idx + 1;
                        :: else -> break;
                        od
                    }
                    break;
                :: else -> printf("\n[Controller №%d]: attempt to aquire one more time", lane_numb)
                fi
            od
    :: else -> skip
    od
}


proctype car(int car_num){
    byte lane_to_move_on;
    do
    :: 
        select (lane_to_move_on : 0 .. 4)
        if
        :: (len(lanes[lane_to_move_on].sygnals) == 0) ->
           printf("\n[Car №%d]: moving on lane №%d", car_num, lane_to_move_on)
           lanes[lane_to_move_on].sygnals ! 1
        :: else -> skip
        fi
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
    
    run car(1)
    run car(2)
    run car(3)
    run car(4)
}