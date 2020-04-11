#define N 10

active proctype ARRAY() {
        int a[N];
        int i = 0;
        // 2.1
         printf("2.1:\n\n")
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

        // 2.2
        printf("\n2.2:\n\n")
        int sum_even = 0;
        i=0;
        do
                :: (i>=N) -> break
                :: else -> printf("a[%d]=%d\n", i, a[i]) -> sum_even = sum_even + a[i] -> i=i+2
        od;
        printf("sum of even elems is %d\n", sum_even)
        int sum_odd = 0;
        i=1;
        do
                :: (i>=N) -> break
                :: else -> printf("a[%d]=%d\n", i, a[i]) -> sum_odd = sum_odd + a[i] -> i=i+2
        od;
        printf("sum of odd elems is %d\n", sum_odd)
}