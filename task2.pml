#DEFINE N 10

active proctype ARRAY() {
        int a[N];
        int i = 0;
        do
                :: (i>=N) -> break
                :: else -> a[i]=3; i++
        od;
        /*your code*/
}