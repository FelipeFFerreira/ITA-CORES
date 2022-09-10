/*
 * Generates a sinus table.
 * Do not try compiling this one on the femtoRV !
 */

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

void main(int argc, char** argv) {
   int NB = 64;
   int factor = 256;
   
   if(argc == 2) {
      factor = atoi(argv[1]);
   }
   
   printf("int sintab[%d] = {",NB);
   for(int i=0; i<NB; ++i) {
      double alpha = 2.0*M_PI*(double)i/(double)NB;
      printf("%d",(int)(factor*sin(alpha)));
      if(i != NB-1) {
	 printf(",");
      }
   }
   printf("};\n");
}
