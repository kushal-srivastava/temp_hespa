#include<iostream>
#include "lodepng.h"
#include<vector>
#include<fstream>
#include<math.h>
#include<sys/time.h>
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    __global__ void evalJulia(double *d_range, 
                              int iteration,
                              int *d_pixel
                             ){
				int x_index = threadIdx.x + 8*threadIdx.y + 64*(blockIdx.x + 
				int y_index = threadIdx.y + 
                double real =  
                double img = 
				double temp;
				double mod = d_real*d_real + d_img*d_img;
				while(mod<=200 && iter <= d_iteration_limit)
				     {
					     temp = d_real * d_real - d_img*d_img + d_c_real;
					     d_img = 2*d_real*d_img + d_c_img;
					     d_real = temp; 
					     mod = d_real * d_real + d_img * d_img;
				     	         
				     }iter++;
		   		 			
			}
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//Encode from raw pixels to disk with a single function call
//the image argument has width * height RGBA pixels or width * height * 4 bytes
void encodeImage(const char* filename, std::vector<unsigned char>& image, unsigned width, unsigned height)
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


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
int main()
{
	const unsigned int img_size = 2048; // Image size
	double *h_range = new double[img_size]; //Stores all the values between range -2 to 2 with spacing
	double *d_range;
	double *d_range;
	int *d_pixel;
	const double spacing = 4.0 / (double)img_size; //spacing is length/image size
	const double & h = spacing;	//spacing alias
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//convert the image size to be in the range of -2 to 2
	for (unsigned int i = 0; i < img_size; ++i)
	{
		range[i] = -2.0 + (double)(i)*h;
	}
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//+++passing the complex constant as pass by reference+++++++++++++++++
	double c_real = -0.8;	//constant complex real
	double c_img = 0.2; 	//constant complex imaginary
	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	int* iteration = new int[img_size*img_size]; //iterations done per pixel
	const int iteration_limit = 200; // maximum number of iterations
	const int size = 2048*2048;
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    cudaMalloc((void**)&d_range, img_size);
    cudaMalloc((void**)&d_pixel, size);
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    cudaMemcpy(d_range, range, img_size, cudaMemcpyHostToDevice);
    //cudaMemcpy(d_pixel, );
	//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    dim3 threadsPerBlock(8,8);
    dim3 numBlocks(256,256);
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//computuation begins here:
	double wcTimeStart= 0.0, wcTimeEnd=0.0;
	int h_iter = 0;// track iteration
	wcTimeStart = getSeconds(); //Start time
    
	//for (unsigned int y = 0; y < img_size; ++y){
	//	for (unsigned int x = 0; x < img_size; ++x) {
	//		real = range[x];
	//		img = range[y];
	//	}
	//}
    evalJulia<<<numBlocks,threadsPerBlock>>>(double* d_range, int *d_pixel);
        
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
	wcTimeEnd = getSeconds(); //End time
	std::cout << "Done with operations, begin image encoding!" << std::endl;
	std::cout << "Time Taken for computation: " << wcTimeEnd-wcTimeStart << " sec" << std::endl;
	//char for colourbit size pixels * 4 byte
	std::vector <unsigned char> colourbit;
	colourbit.resize(img_size*img_size * 4);
	for (unsigned int j = 0; j < img_size; j++) {
		for (unsigned int i = 0; i < img_size; i++) {
			int num = (iteration[j*img_size + i]%201)*100000;
			colourbit[4 * img_size*j + 4 * i + 3] = num % 255;
			colourbit[4 * img_size*j + 4 * i + 2] = (num >> 8)%255;
			colourbit[4 * img_size*j + 4 * i + 1] = (num >> 16)%255;
			colourbit[4 * img_size*j + 4 * i + 0] = (num >> 24)%255;
		}
	}
	wcTimeEnd = getSeconds();//Final time
	encodeImage("JuliaCPU.png", colourbit, img_size, img_size);
	std::cout << "The image has been generated and is named as JuliaCPU.png" << std::endl;
	std::cout << "Time Taken for image encoding: " << wcTimeEnd-wcTimeStart << " sec" << std::endl;

	delete(range);
	delete(iteration);
	return 0;
}
