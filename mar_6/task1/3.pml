init {
        int a;
        int b = 2;
        int c = 7;

        if
                :: (b > c) -> a = b
                :: else -> a = c
        fi
        printf("C is %d. ", c)
 }