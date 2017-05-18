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
//__global__ void evalJulia(double*, int*, int, int, double, double, unsigned char*, const unsigned int);
__global__ void evalJulia(const double h,

			  int max_iteration,

			  int pixel_limit,

			  double c_real,

			  double c_img,

			  unsigned char* colourBit,

			  const unsigned int img_size){

	

	int x_index = threadIdx.x + blockIdx.x*blockDim.x;

	int y_index = threadIdx.y + blockIdx.y*blockDim.y;
//	printf("%f
	//int index = x_index + (T/32)*y_index;
	double real = -2.0 + h * (double)x_index;
	double img = -2.0 + h * (double)y_index;
	//printf("%d %d \n ", x_index, y_index);
	double mod = real*real + img*img;
	double temp;
	int iter = 0;
	while (mod <= (pixel_limit*pixel_limit) && iter < max_iteration){
		temp = real*real - img*img + c_real;
		img = 2*real*img + c_img;
		real = temp;
		mod = real * real + img * img;
		iter++;}
	//__syncthreads();
	printf("%d\n", y_index);
	//update colour/*
                        /*colourBit[4 *(img_size)*y_index + 4 * x_index + 3] = 255;
                        colourBit[4 *(img_size)*y_index + 4 * x_index + 2] = 0;
                        colourBit[4 *(img_size)*y_index + 4 * x_index + 1] = (unsigned char)iter;
                        colourBit[4 *(img_size)*y_index + 4 * x_index + 0] = ((double)iter/200.0)*255;*/
	//d_iteration[index] = iter;
	__syncthreads();
}




int main()
{
	const unsigned int img_size = 2048; // Image size
	//double *range = new double[img_size]; //Stores all the values between range -2 to 2 with spacing
	//double *d_range;
	//cudaMalloc((void**)&d_range, img_size*sizeof(double));
	
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	const double spacing = 4.0 / (double)img_size; //spacing is length/image size
	const double & h = spacing;	//spacing alias
		std::cout<<h<<std::endl;
	//convert the image size to be in the range of -2 to 2
	/*for (unsigned int i = 0; i < img_size; ++i)
	{
		range[i] = -2.0 + (double)(i)*h;
	}*/
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//int tmp = img_size*sizeof(double);
	//cudaMemcpy(range, d_range, (img_size*sizeof(double)), cudaMemcpyHostToDevice);
	int pixel_limit = 12;
	double c_real = -0.8;	//constant complex real
	double c_img = 0.2; 	//constant complex imaginary
	//int* iteration = new int[img_size*img_size]; //iterations done per pixel
	//int* d_iteration;
	std::cout << "before kernel cal"<<std::endl;
	//cudaMalloc((void**)&d_iteration, (img_size*img_size*sizeof(int)));
	int iteration_limit = 50; // maximum number of iterations
	unsigned char*  colourBit = new unsigned char[img_size*img_size * 4];
	double wcTimeStart= 0.0, wcTimeEnd=0.0;
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//computuation begins here:
	wcTimeStart = getSeconds(); //Start time
	dim3 gridDim(128,128); //(64,64)
	dim3 blockDim(16,16); //16 implicitly considered (number of threads in x and y directions) (16,16)
	evalJulia<<<gridDim, blockDim>>>(h, iteration_limit, pixel_limit, c_real, c_img, colourBit, img_size);
	cudaError_t errSync  = cudaGetLastError();
	cudaError_t errAsync = cudaDeviceSynchronize();
	if (errSync != cudaSuccess) 
 		 printf("Sync kernel error: %s\n", cudaGetErrorString(errSync));
	if (errAsync != cudaSuccess)
  	printf("Async kernel error: %s\n", cudaGetErrorString(errAsync));
//	__syncthreads();
	//cudaMemcpy(d_iteration,iteration, (img_size*img_size*sizeof(int)),cudaMemcpyDeviceToHost);
	wcTimeEnd = getSeconds(); //End time
	std::cout << "Done with operations, begin image encoding!" << std::endl;
	std::cout << "Time Taken for computation: " << wcTimeEnd-wcTimeStart << " sec" << std::endl;
	encodeImage("JuliaCPU.png", colourBit, img_size, img_size);
	std::cout << "The image has been generated and is named as JuliaCPU.png" << std::endl;
	std::cout << "Time Taken for image encoding: " << (wcTimeEnd-wcTimeStart)*1e3 << " milli-sec" << std::endl;
	
	//cudaFree(d_iteration);
	//cudaFree(d_range);
	//delete(range);
	//delete(iteration);
	delete(colourBit);
	return 0;
}


