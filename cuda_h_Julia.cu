#include<iostream>
#include "lodepng.h"
#include<vector>
#include<fstream>
//#include<math.h>
#include<sys/time.h>


#define T 1024 //number of threads/block(32,32)
#define N 64 //number of blocks per grid (256,256)
//Encode from raw pixels to disk with a single function call
//he image argument has width * height RGBA pixels or width * height * 4 bytes
void encodeImage(const char* filename, unsigned char const* image, unsigned width, unsigned height)
{
	//Encode the image
	unsigned error = lodepng::encode(filename, image, width, height);
	//if there's an error, display it
	if (error) std::cout << "encoder error " << error << ": " << lodepng_error_text(error) << std::endl;
}

double getSeconds()
{
	struct timeval tp;
	gettimeofday(&tp, NULL);
	return ((double)tp.tv_sec + (double)tp.tv_usec * 1e-6);
}

__global__ void evalJulia(float h,

			  unsigned int max_iteration,

			  float pixel_limit,

			  float c_real,

			  float c_img,

			  unsigned char* colourBit,

			  long img_size){

	
	//printf("%f %d %d %f %f %d\n", h, max_iteration, pixel_limit, c_real, c_img, img_size);
	long id = threadIdx.x + blockIdx.x*blockDim.x;
	long x_index = id%img_size;
	long y_index = id/img_size;
	//long y_index = threadIdx.y + blockIdx.y*blockDim.y;
	float real = -2.0 + h * (id%img_size);
	float img = -2.0 + h * (id/img_size);
	float mod = real*real + img*img;
	float temp=0;
	int iter = 0;
	printf("%d %d\n", id, int(id/img_size));
	while ((mod <= (pixel_limit*pixel_limit)) && (iter < max_iteration))
		{
		//printf("real img mod %f %f %f %d\n", real, img, mod, iter);
		temp = (real*real) - (img*img) + 0.0000;
		img = 2.0*real*img - 0.800;
		real = temp;
		mod = (real * real) + (img * img);
		//printf("real img mod %f %f %f %d\n", real, img, mod, iter);
		iter = iter + 1;
		}
	//printf("inside the loop %d %d %f %f %d\n", x_index, y_index, real, img, iter);	
		//printf("pixel value %d\n", int((iter/200.0)*255));
	//update colour
                        colourBit[4 *(img_size)*y_index + 4 * x_index + 3] = 255;
                        colourBit[4 *(img_size)*y_index + 4 * x_index + 2] = 0;
                        colourBit[4 *(img_size)*y_index + 4 * x_index + 1] = 0;//(unsigned char)iter;
                        colourBit[4 *(img_size)*y_index + 4 * x_index + 0] = int(iter/200.0)*255; 
	
		
}




int main()
{
	long img_size = 2048; // Image size(64x64)
		
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//std::cout<<"//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"<<std::endl;
	float spacing = 4.0 / (double)img_size; //spacing is length/image size
	//std::cout<<"spacing "<<spacing<<std::endl;	
	float pixel_limit = 20;
	float c_real = 0.0;	//constant complex real
	float c_img = 0.8; 	//constant complex imaginary
	//std::cout << "before kernel cal"<<std::endl;
	unsigned int iteration_limit = 100; // maximum number of iterations
	unsigned char*  colourBit = new unsigned char[img_size*img_size * 4];
	unsigned char* d_colourBit;
	cudaMalloc((void**)&d_colourBit, (img_size*img_size*4*sizeof(unsigned char)));
	double wcTimeStart= 0.0, wcTimeEnd=0.0;
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//computuation begins here:
	wcTimeStart = getSeconds(); //Start time
	//dim3 gridDim(128,128); //(64,64)
	//dim3 blockDim(16,16); //16 implicitly considered (number of threads in x and y directions) (16,16)
	long threads_Block = 1024;
	long blocks = (2048*2048)/threads_Block;
	//long len = 2048;
	evalJulia<<<blocks, threads_Block>>>(spacing, iteration_limit, pixel_limit, c_real, c_img, d_colourBit, img_size);
	cudaError_t errSync  = cudaGetLastError();
	cudaError_t errAsync = cudaDeviceSynchronize();
	if (errSync != cudaSuccess) 
 		 printf("Sync kernel error: %s\n", cudaGetErrorString(errSync));
	if (errAsync != cudaSuccess)
  	printf("Async kernel error: %s\n", cudaGetErrorString(errAsync));
	cudaMemcpy(colourBit,d_colourBit, (img_size*img_size*sizeof(unsigned char)),cudaMemcpyDeviceToHost);
	wcTimeEnd = getSeconds(); //End time
	std::cout << "Done with operations, begin image encoding!" << std::endl;
	std::cout << "Time Taken for computation: " << wcTimeEnd-wcTimeStart << " sec" << std::endl;
	encodeImage("JuliaCPU.png", colourBit, img_size, img_size);
	std::cout << "The image has been generated and is named as JuliaCPU.png" << std::endl;
	std::cout << "Time Taken for image encoding: " << (wcTimeEnd-wcTimeStart)*1e3 << " milli-sec" << std::endl;
	cudaFree(d_colourBit);
	delete(colourBit);
	return 0;
}


