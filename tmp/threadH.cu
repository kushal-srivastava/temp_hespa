#include<iostream>
//#include<stdio.h>
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    __global__ void evalJulia(int *d_pixel, 
                              int *d_temp){
        
				int x_index = threadIdx.x + blockIdx.x*blockDim.x;
				int y_index = threadIdx.y + blockIdx.y*blockDim.y;
				int tmp = x_index + 2*y_index;
				d_temp[tmp] = d_pixel[tmp];
		   		 			
			}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#define N 64
int main()
{

	int *d_pixel;
	int *d_temp;

	int size = N * sizeof(int);
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	int *temp = new int[N];
    	int *h_temp = new int[N];
    	for (int y=0;y<8;y++)
        	for(int x=0;x<8;x++)
        	{
            		temp[x + 8*y] = x + 8*y;
            		std::cout<<temp[x+8*y]<<std::endl;
        	}
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	std::cout<<"test begins"<<std::endl;
    	dim3 gridDim(4,4);
    	dim3 blockDim(2,2);
    	cudaMalloc((void**)&d_pixel, size);
    	cudaMalloc((void**)&d_temp, size);
    	cudaMemcpy(temp, d_pixel, size, cudaMemcpyHostToDevice);
    	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    	evalJulia<<<gridDim,blockDim>>>(d_pixel, d_temp);
    	cudaMemcpy(h_temp, d_temp, size, cudaMemcpyDeviceToHost);
    	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
   	for (int y=0;y<8;y++)
        	for(int x=0;x<8;x++)
        	{
			std::cout<<temp[x+8*y]<<std::endl;}
    	std::cout<<"last kernel thread printed"<<std::endl;
    	cudaFree(d_pixel);
    	cudaFree(d_temp);
    	delete(h_temp);
    	delete(temp);
	return 0;
}
