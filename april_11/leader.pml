/*
 * Le Lann, Chang and Roberts leader election algorithm for a ring of
 * N processes
 *
 */

#define N 5
#define BUFSIZE 10

mtype = { candidate, leader };
chan c[N] = [BUFSIZE] of { mtype, byte };

byte num_leaders = 0;

proctype node(chan prev, next; byte my_id)
{
    byte in_id;
    byte leader_id;

    next!candidate(my_id);

    do
        :: prev?candidate(in_id) ->
            if
                :: in_id > my_id ->
                    next!candidate(in_id);
                :: in_id < my_id ->
                    skip;
                :: else ->
                    num_leaders++;
                    printf("I am the leader! (pid: %d, id: %d)\n", _pid, my_id);
                    next!leader(my_id);
            fi
        :: prev?leader(leader_id) ->
            if
                :: leader_id > my_id ->
                    next!leader(leader_id);
                    break;
                :: else ->
                    assert(my_id == leader_id);
                    break;
            fi
    od;
    assert(num_leaders == 1);
}

init {
    byte proc;
    byte i;

    atomic {
        chan prev, next;
        byte id;
        do
            :: i < N -> i++;
            :: true -> break;
        od;
        do
            :: proc < N ->
                prev = c[proc];
                next = c[(proc+1)%N];
                id = (N+i-proc)%N;
                printf("Starting process with id %d.\n", id);
                run node(prev, next, id);
                proc++;
            :: else ->
                break;
        od
    }
}
