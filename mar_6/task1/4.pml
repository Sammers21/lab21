
init {
        int a = 1;
        int b = 20;

        do
                :: (a > b) -> break
                :: else -> a = a + 1
        od
        printf("a is %d. ", a)
 }