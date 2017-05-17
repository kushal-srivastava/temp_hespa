#include "utils.h"

int main(int argc, char **argv) {
	float *h_x, *d_x; // host and device
	int nblocks = 2, nthreads = 8, nsize = 16;

	j_x = (float *)malloc(nsize*sizeof(float));
	
