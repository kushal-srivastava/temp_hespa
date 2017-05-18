#include<iostream>
#include<stdio.h>

__global__ void kern(void){
	int x = threadIdx.x + blockIdx.x*blockDim.x;
	int y = threadIdx.y + blockIdx.y*blockDim.y;
//	printf("Dim %d %d \n", blockDim.x, blockDim.y);	
	printf("%d %d %d\n", x,y, (x + 8*y));
//	__syncthreads();
	printf("Id%d %d %d\n", blockIdx.x, blockIdx.y, (x + 8*y));
//	printf("%d \n", x + 8*y);
}

int main(){
	dim3 gridDim(2,2);
	dim3 blockDim(4,4);
	kern<<<gridDim, blockDim>>>();
	cudaError_t errSync  = cudaGetLastError();
cudaError_t errAsync = cudaDeviceSynchronize();
if (errSync != cudaSuccess) 
  printf("Sync kernel error: %s\n", cudaGetErrorString(errSync));
if (errAsync != cudaSuccess)
  printf("Async kernel error: %s\n", cudaGetErrorString(errAsync));
	return 0;
}
