chan pillar_channels[5] = [0] of {bool};

bool gate_opened = false;
bool states[5] = {false, true, false, true, true};

init {
    run ControlPillar(0)
    run ControlPillar(1)
    run ControlPillar(2)
    run ControlPillar(3)
    run ControlPillar(4)
}

proctype ControlPillar(byte id) {
    bool command = true;
    printf("\nid: %d\n", id);
    byte i;
    do
        :: !gate_opened -> 
            :: pillar_channels[id]?command -> 
                atomic {
                    int left = (id - 1 + 5) % 5;
                    int right = (id + 1 + 5) % 5;
                    states[id] = !states[id];
                    states[left] = !states[left];
                    states[right] = !states[right];
                    bool all_opened = true;
                    for (i: 0 .. 4) {
                        if 
                            :: states[i] == false -> all_opened = false;
                            :: states[i] == true -> skip;
                        fi
                    }
                    // printf("Set gate to %d", all_opened)
                    gate_opened = all_opened;
                }

        :: gate_opened -> printf("\nControlPillar №%d exit\n", id) -> break;
    od
}

active proctype Commander() {
    int pillar_id = 0;
    do
        :: !gate_opened ->
            :: select(pillar_id: 0 .. 4);
                printf("\nSent signal to gate %d\n", pillar_id)
                pillar_channels[pillar_id]!true;
        :: gate_opened -> printf("\nCommander exit\n") -> break;
    od
}

ltl p1 {[] (gate_opened == false)};
