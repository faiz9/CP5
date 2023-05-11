/*
Vector Addition code taken from Mark Harris: 

https://developer.nvidia.com/blog/even-easier-introduction-cuda/

Modified problem size to N=1<<26 (64M) 
*/

#include <iostream>
#include <math.h>

// Kernel function to add the elements of two arrays
__global__
void add(int n, float *x, float *y)  //global runs on gpu
{
  for (int i = 0; i < n; i++)
      y[i] = x[i] + y[i];
}

int main(void)
{
  int N = 1<<26; // 64M elements
  float *x, *y;

  // Allocate Unified Memory – accessible from CPU or GPU
  cudaMallocManaged(&x, N*sizeof(float));
  cudaMallocManaged(&y, N*sizeof(float));


 // initialize x and y arrays on the host
  for (int i = 0; i < N; i++) {
    x[i] = 1.0f;
    y[i] = 2.0f;
  }

  /* timer code here taken from Benchmark.cpp
  std::chrono::time_point<std::chrono::high_resolution_clock> start_time = std::chrono::high_resolution_clock::now();
  */

  // Run kernel on 1M elements on the CPU
  add<<<1, 1>>>(N, x, y);

  /* timer code here taken from Benchmark.cpp
  std::chrono::time_point<std::chrono::high_resolution_clock> end_time = std::chrono::high_resolution_clock::now();
  std::chrono::duration<double> elapsed = end_time - start_time;
  std::cout << "Elapsed time is: " << elapsed.count() << " seconds" << std::endl;
  */

  // Wait for GPU to finish before accessing on host
  cudaDeviceSynchronize();

  // Check for errors (all values should be 3.0f)
  float maxError = 0.0f;
  for (int i = 0; i < N; i++)
    maxError = fmax(maxError, fabs(y[i]-3.0f));
  std::cout << "Max error: " << maxError << std::endl;
  
 // Free memory
  cudaFree(x);
  cudaFree(y);

  return 0;
}