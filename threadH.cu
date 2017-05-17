#include<iostream>
#include<stdio.h>
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    __global__ void evalJulia(double *d_pixel, 
                              double *d_temp){
        
				int x_index = threadIdx.x + 2*threadIdx.y + 4*(blockIdx.x + blockIdx.y);
				d_temp[x_index] = d_pixel[x_index];
		   		 			
			}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
int main()
{

	double *d_pixel;
	double *d_temp;
	const int size = 16*16;
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    double *temp = new double(size);
    double *h_temp = new double(size);
    for (int y=0;y<16;y++)
        for(int x=0;x<16;x++)
        {
            temp[x + 16*y] = x + 16*y;
            std::cout<<temp[x+16*y]<<std::endl;
        }
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	std::cout<<"test begins"<<std::endl;
    dim3 threadsPerBlock(2,2);
    dim3 numBlocks(8,8);
    cudaMalloc((void**)&d_pixel, size);
    cudaMalloc((void**)&d_temp, size);
    //cudaMemcpy(temp, d_pixel, size, cudaMemcpyHostToDevice);
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //evalJulia<<<numBlocks,threadsPerBlock>>>(d_pixel, d_temp);
    //cudaMemcpy(h_temp, d_temp, size, cudaMemcpyDeviceToHost);
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
/*    for (int y=0;y<2048;y++)
        for(int x=0;x<2048;x++)
        {std::cout<<temp[x+2048*y]<<std::endl;}*/
    std::cout<<"last kernel thread printed"<<std::endl;
    cudaFree(d_pixel);
    cudaFree(d_temp);
    delete(h_temp);
    delete(temp);
	return 0;
}
