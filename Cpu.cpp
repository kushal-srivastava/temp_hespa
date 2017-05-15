#include<iostream>
#include "lodepng.h"
#include<vector>
#include<fstream>
#include<math.h>
#include<sys/time.h>

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

int main()
{
	const unsigned int img_size = 2048; // Image size
	double *range = new double[img_size]; //Stores all the values between range -2 to 2 with spacing
	const double spacing = 4.0 / (double)img_size; //spacing is length/image size
	const double & h = spacing;	//spacing alias
	// why do we need the alias? +++++++++++++++++++++ unused variable here: 
	//convert the image size to be in the range of -2 to 2
	for (unsigned int i = 0; i < img_size; ++i)
	{
		range[i] = -2.0 + (double)(i)*h;
	}

	double c_real = 0.0;	//constant complex real
	double c_img = 0.0; 	//constant complex imaginary
	int* iteration = new int[img_size*img_size]; //iterations done per pixel
	double mod = 0.0; // absolute value
	const int iteration_limit = 200; // maximum number of iterations
	//computuation begins here:
	double wcTimeStart= 0.0, wcTimeEnd=0.0;
	double real = 0.0, img = 0.0, temp = 0.0;// real and imaginary part of complex number, temp tp eliminate data dependency
	int iter = 0;// track iteration
	wcTimeStart = getSeconds(); //Start time
	for (unsigned int y = 0; y < img_size; ++y){
		for (unsigned int x = 0; x < img_size; ++x) {
			mod = 0.0;
			
			//set initial value
			real = range[x];
			img = range[y];
			
			//calculate absolute value
			mod = real*real + img*img;   // it has to be real)2 - imag)2
			//double temp=0.0; //temp value to eliminate data dependency
//			int iter = 0; //track iteration
			c_real = -0.8;
			c_img = 0.2;
			while (mod<=100 && iter<= iteration_limit)
			{
				//z_new = z_old^2+c
				temp = real*real - img*img + c_real;
				img = 2*real*img + c_img;
				real = temp;
				//calcutate absolute value
				mod = real*real + img*img;
				++iter;
			}
			iteration[y*img_size + x] = iter;
		
		real = 0.0; img = 0.0; temp = 0.0; iter = 0;
		}
		
	}
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