#include "../femtostdlib.h"

/* 
 * Needed to prevent the compiler from recognizing memcpy in the
 * body of memcpy and replacing it with a call to memcpy
 * (infinite recursion) 
 */ 
#pragma GCC optimize ("no-tree-loop-distribute-patterns")

void* memcpy(void * dst, void const * src, size_t len) {
   uint32_t * plDst = (uint32_t *) dst;
   uint32_t const * plSrc = (uint32_t const *) src;

   // If source and destination are aligned,
   // copy 32s bit by 32 bits.
   if (!((uint32_t)src & 3) && !((uint32_t)dst & 3)) {
      while (len >= 4) {
	 *plDst++ = *plSrc++;
	 len -= 4;
      }
   }

   uint8_t* pcDst = (uint8_t *) plDst;
   uint8_t const* pcSrc = (uint8_t const *) plSrc;
   
   while (len--) {
      *pcDst++ = *pcSrc++;
   }
   
   return dst;
}


/*
 * Equivalent (slower) version
void* memcpy(void* dest, const void* src, size_t n) {
   char *csrc  = (char *)src; 
   char *cdest = (char *)dest; 
   for (size_t i=0; i<n; i++) {
      cdest[i] = csrc[i];
   }
}
 */

