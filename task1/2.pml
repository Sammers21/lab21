init {
        int a = 3;
        int b = 2;

        if
                ::(a < b) -> printf("good")
                :: else -> printf("bad")
        fi
 }