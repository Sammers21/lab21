#define N 10

active proctype ARRAY() {
        int a[N];
        int i = 0;
        do
                :: (i>=N) -> break
                :: else -> 
                        if
                                :: a[i]=0 -> i++
                                :: a[i]=1 -> i++
                                :: a[i]=2 -> i++
                                :: a[i]=3 -> i++
                                :: a[i]=4 -> i++
                                :: a[i]=5 -> i++
                        fi
        od;
        int y = 0;
        do
                :: (y>=N) -> break
                :: else -> printf("a[%d]=%d\n", y, a[y]) -> y=y+1
        od;
        
}