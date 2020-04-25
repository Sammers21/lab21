chan monkey_channel = [0] of {byte};
#define QUOTE_SIZE 13

bool terminate = false;

active[26] proctype Monkey(){
    byte symbol = 'a' + _pid;
    do 
        :: !terminate ->
            monkey_channel!symbol
        :: else -> break;
    od
}

active proctype Reviewer(){
    
    byte check_seq[QUOTE_SIZE] = {'t', 'o', 'b', 'e', 'o', 'r', 'n', 'o', 't', 't', 'o', 'b', 'e'};
    byte check_i = 0;
    byte symbol;
    int i;
    do
        :: !terminate -> 
            if
                ::  monkey_channel?symbol -> 
                    printf("\nreceived:%c, check_i:%d", symbol, check_i)
                    if
                        :: symbol == check_seq[check_i] ->
                            if
                                :: check_i == QUOTE_SIZE - 1 -> terminate = true;
                                :: else -> check_i = check_i + 1
                            fi
                        :: else -> check_i = 0;
                    fi
            fi
        :: else -> break
    od
}

ltl p1 { [] (tearminate = false) };
