// colors
mtype = { red, green }

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
    mtype color = red;
    // indexes from all_crosses
    int crosses[3];
    // lenght of crosses array
    int crosses_len = 0;
    // channel for signals
    chan signals = [0] of {byte};

    bool s_received;
};

// 0 - red
// 1 - green
// 2 - black
// 3 - purple
// 4 - blue
Lane lanes[5];

// LaneControllers send its number here
chan LOCK_REQUEST = [0] of { byte }
// LaneControllers receive permission here
chan LOCKED_BY_LANE[5] = [0] of { byte }
// LaneControllers send its number here
chan UNLOCK_REQUEST = [0] of { byte }
// LaneControllers receive permission here
chan UNLOCKED_BY_LANE[5] = [0] of { byte }

proctype LockManager() {
    do 
    ::
        byte who_requested;
        LOCK_REQUEST ? who_requested;
        LOCKED_BY_LANE[who_requested] ! 1;
        UNLOCK_REQUEST ? who_requested;
        UNLOCKED_BY_LANE[who_requested] ! 1;
    od
}

proctype LaneController(int lane_numb) {
    byte signal;
    printf("\nController on lane №%d has been started. Crossroads count:%d", lane_numb, lanes[lane_numb].crosses_len);
    do
    ::
            int attempt = 0; 
            signal_received: lanes[lane_numb].signals?_ -> lanes[lane_numb].s_received = true -> lanes[lane_numb].s_received = false;
            printf("\n[Controller №%d]: received a signal, trying to aquire all the resources", lane_numb);
            do
            ::  
                attempt = attempt + 1;
                printf("\n[Controller №%d]: attempt to aquire №%d", lane_numb, attempt);
                bool aquired;
                bool can_aquire = true;
                int idx;
                int cross;
                LOCK_REQUEST!lane_numb;
                LOCKED_BY_LANE[lane_numb]?_;
                    // check if can aquire
                    for(idx: 0 .. lanes[lane_numb].crosses_len - 1) {
                        cross = lanes[lane_numb].crosses[idx];
                        if
                        :: (all_crosses[cross].locked) -> can_aquire = false -> skip;
                        :: else -> skip;
                        fi
                    }
                    // aquire if can
                    if
                    :: can_aquire -> 
                        printf("\n[Controller №%d]: can aquire", lane_numb);
                        for(idx: 0 .. lanes[lane_numb].crosses_len - 1) {
                            cross = lanes[lane_numb].crosses[idx];
                            all_crosses[cross].locked = true;
                            printf("\n[Controller №%d]: cross №:%d has been aquired", lane_numb, cross);
                        }
                        aquired = true;
                        green_turned: lanes[lane_numb].color = green;
                    :: else ->
                        printf("\n[Controller №%d]: could not aquire", lane_numb);
                        aquired = false;
                    fi
                UNLOCK_REQUEST!lane_numb;
                UNLOCKED_BY_LANE[lane_numb]?signal;
                if
                :: aquired ->
                    LOCK_REQUEST!lane_numb;
                    LOCKED_BY_LANE[lane_numb]?_;
                        printf("\n[Controller №%d]: releasing locks", lane_numb)
                        for(idx: 0 .. lanes[lane_numb].crosses_len - 1) {
                            cross = lanes[lane_numb].crosses[idx];
                            all_crosses[cross].locked = false;
                            printf("\n[Controller №%d]: cross №:%d has been released", lane_numb, cross);
                        }
                    lanes[lane_numb].color = red;             
                    UNLOCK_REQUEST!lane_numb;
                    UNLOCKED_BY_LANE[lane_numb]?_;
                    break;
                :: else -> printf("\n[Controller №%d]: attempt to aquire one more time", lane_numb);
                fi
            od
    od
}


proctype car(int car_num) {
    byte i;
    byte rnd;
    do
    :: select(rnd: 0 .. 4);
       lanes[rnd].signals ! 1;   
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
    //run lock manager
    run LockManager();
    // start controllers
    run LaneController(0);
    run LaneController(1);
    run LaneController(2);
    run LaneController(3);
    run LaneController(4);
    // trafic generation
    run car(0);
    run car(1);
}


ltl safety { 
    [] (!((lanes[0].color == green) && (lanes[2].color == green)) && // red and black
       !((lanes[0].color == green) && (lanes[1].color == green)) && // red and green
       !((lanes[0].color == green) && (lanes[4].color == green)) && // red and blue
       !((lanes[4].color == green) && (lanes[3].color == green)) && // blue and purle
       !((lanes[4].color == green) && (lanes[1].color == green)) && // blue and green
       !((lanes[3].color == green) && (lanes[1].color == green))) // purle and green
};

ltl liveness {
    [] (((lanes[0].s_received == true) -> <> (lanes[0].color == green)) &&
        ((lanes[1].s_received == true) -> <> (lanes[1].color == green)) &&
        ((lanes[2].s_received == true) -> <> (lanes[2].color == green)) &&
        ((lanes[3].s_received == true) -> <> (lanes[3].color == green)) &&
        ((lanes[4].s_received == true) -> <> (lanes[4].color == green)))
};



ltl fairness1 {
    [] ((((lanes[0].s_received == true) && (lanes[0].color == red)) -> <> (lanes[0].color == green)) &&
        (((lanes[1].s_received == true) && (lanes[1].color == red)) -> <> (lanes[1].color == green)) &&
        (((lanes[2].s_received == true) && (lanes[2].color == red)) -> <> (lanes[2].color == green)) &&
        (((lanes[3].s_received == true) && (lanes[3].color == red)) -> <> (lanes[3].color == green)) &&
        (((lanes[4].s_received == true) && (lanes[4].color == red)) -> <> (lanes[4].color == green)))
};

ltl fairness2 {
    !( [](lanes[0].color == green) ||
       [](lanes[1].color == green) ||
       [](lanes[2].color == green) ||
       [](lanes[3].color == green) ||
       [](lanes[4].color == green))
};

// #TODO ltl Сделать:
// 1. Если он светофор красный то станет зеленым
// 2. Никакой из сфетофоров не остается бесконечно зеленым
