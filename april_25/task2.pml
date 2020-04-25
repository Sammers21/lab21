int sum = 0;

active proctype stuck() {
    byte v = 0;
    do
        :: select(v: 1 .. 3) ->
            if
                :: sum > 0 -> sum = sum - v -> printf("\nSum: %d\n", sum)
                :: sum <= 0 -> sum = sum + v -> printf("\nSum: %d\n", sum)
            fi
    od
}

ltl p1 { [] ((sum != 0) -> <> (sum == 0)) };
ltl p2 { [] ((sum <= 3) && (sum >= -3)) };
ltl p3 { [] (((sum > 0) -> <> (sum < 0)) && ((sum < 0) -> <> (sum > 0))) };
ltl p3_fixed { [] (((sum > 0) -> <> (sum <= 0)) && ((sum <= 0) -> <> (sum > 0))) };
