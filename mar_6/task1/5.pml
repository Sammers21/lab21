
init {
        int i = 0;
        do
                :: (i < 100) ->  printf("i = %d ", i) -> i = i + 1
                :: else -> break
        od 
 }