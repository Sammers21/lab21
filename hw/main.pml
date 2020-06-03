// true - green, false - red
bool trafic_lights [5] = {false, false, false, false, true};
// true - movement requested, false - none
bool requested_senses [5] = {true, false, false, false, true}; 

init {
    run black_tl(0)
}

proctype black_tl(byte id) {
    byte sense;
    do
        :: requested_senses[id] ->
            if 
                :: trafic_lights[id] -> 
                    requested_senses[id] = false;
                    printf("Машина проехала\n");
                :: !trafic_lights[id] -> 
                    trafic_lights[id] = true;
                    printf("Машина есть - зеленый\n")
                    requested_senses[id] = false;
                    printf("Машина проехала\n");
            fi;
        :: !requested_senses[id] ->
            trafic_lights[id] = false;
            printf("Машины нет - красный\n");
        :: select(sense: 0 .. 1) ->
            requested_senses[id] = sense;
    od;
}
