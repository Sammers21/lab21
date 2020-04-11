byte x;

active proctype A () {
    x = 1;
    
    do
        :: select(x:0..10); 
    od;
}

ltl p1 { x == 0 };                          // valid
ltl p2 { x != 0 };                          // invalid
ltl p3 { (x == 0) -> X (x !=0) };           // valid
ltl p4 { (x == 0) -> <> (x != 0) };         // valid
ltl p5 { [] ((x == 0) -> X (x != 0)) };     // invalid
ltl p6 { [] ((x == 0) -> <> (x != 0)) };    // invalid
