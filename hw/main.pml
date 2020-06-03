// true - green, false - red
bool trafic_lights [5] = {false, true, false, false, false};
// true - movement requested, false - none
bool requested_senses [5] = {true, false, false, false, false}; 

byte BLACK = 0;
byte RED = 1;

init {
    run black_tl(BLACK)
    run red_tl(RED)
}


proctype black_tl(byte id) {
    byte sense;
    if
        :: requested_senses[id] ->
            if 
                :: trafic_lights[id] -> requested_senses[id] = false -> printf("BLA: Машина проехала сразу\n");
                :: !trafic_lights[id] -> 
                    atomic {
                        if
                            :: trafic_lights[RED] -> printf("BLA: RED был зеленым\n") -> skip
                            :: !trafic_lights[RED] ->
                                trafic_lights[id] = true -> printf("BLA: Машина есть - зеленый\n")
                                requested_senses[id] = false -> printf("BLA: Машина проехала\n");                                
                        fi;
                    }
            fi;
        :: !requested_senses[id] ->
            atomic {
                if
                    :: trafic_lights[id] -> 
                        trafic_lights[id] = false -> printf("BLA: Машин нет - красный\n")
                    :: !trafic_lights[id] -> skip
                fi;
            }
    fi;
}

proctype red_tl(byte id) {
    if
        :: requested_senses[id] ->
            if 
                :: trafic_lights[id] -> requested_senses[id] = false -> printf("RED: Машина проехала сразу\n");
                :: !trafic_lights[id] ->
                    atomic {    
                        if
                            :: trafic_lights[BLACK] -> printf("RED: BLA был зеленым\n") -> skip
                            :: !trafic_lights[BLACK] ->
                                trafic_lights[id] = true -> printf("RED: Машина есть - зеленый\n")
                                requested_senses[id] = false -> printf("RED: Машина проехала\n");
                        fi;
                    }
            fi;
        :: !requested_senses[id] ->
            atomic {
                if
                    :: trafic_lights[id] -> 
                        trafic_lights[id] = false -> printf("RED: Машин нет - красный\n")
                    :: !trafic_lights[id] -> skip
                fi;
            }
    fi;
}
