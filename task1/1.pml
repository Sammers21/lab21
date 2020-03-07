init {
        int a = 1;
        int b = 2;

        if
                ::(a < b) -> printf("good")
                :: else -> skip
        fi
 }