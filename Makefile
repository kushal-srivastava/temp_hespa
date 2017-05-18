CXXFLAGS = #-std=c++11 -O3 -Werror -Wall -Wextra -Wshadow
CXX = nvcc

CPU_EXE = juliaCPU
CPU = cuda_Julia
LINK = lodepng.h lodepng.cpp

$(CPU): $(LINK)
	$(CXX) $(CXXFLAGS) lodepng.cpp $(CPU).cu -o $(CPU_EXE)
testc:
	./juliaCPU

clean:
	@$(RM) -rf *.o *.png $(CPU_EXE) 
