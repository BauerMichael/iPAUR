// ###
// ###
// ### Practical Course: GPU Programming in Computer Vision
// ###
// ###
// ### Technical University Munich, Computer Vision Group
// ### Summer Semester 2015, September 7 - October 6
// ###
// ###
// ### Thomas Moellenhoff, Robert Maier, Caner Hazirbas
// ###
// ###
// ###
// ### THIS FILE IS SUPPOSED TO REMAIN UNCHANGED
// ###
// ###


#include "aux.h"
#include <iostream>
#include <stdio.h>
using namespace std;

#define PI 3.14159265359

// uncomment to use the camera
// #define CAMERA

inline __device__ float add(float x1, float x2) {
    return x1 + x2;
}

__global__ void addArray(float* out, float* in1, float* in2, int size) {
    int index = threadIdx.x + blockDim.x * blockIdx.x;
    if (index < size) {
        out[index] = add(in1[index], in2[index]);
    }
}

__global__ void compute_matrix(float* m11, float* m12, float* m22, float* in_x, float* in_y, int width, int height, int channel) {
    int x = threadIdx.x + blockDim.x * blockIdx.x;
    int y = threadIdx.y + blockDim.y * blockIdx.y;
    int index = x + width * y;
    float sum_m11 = 0.0;
    float sum_m12 = 0.0;
    float sum_m22 = 0.0;
    if (x < width && y < height) {
        for (int i = 0; i < channel; i++) {
            sum_m11 += pow(in_x[index + i * height * width], 2);
            sum_m12 += in_x[index + i * height * width] * in_y[index + i * height * width];
            sum_m22 += pow(in_y[index + i * height * width], 2);
        }
        m11[index] = sum_m11;
        m12[index] = sum_m12;
        m22[index] = sum_m22;
    }
}

__global__ void compute_G(float* m11, float* m12, float* m22, float* e1X, float* e1Y, float* e2X, float* e2Y, float* l1, float* l2, float alpha, float C, int width, int height, int channel) {
    int x = threadIdx.x + blockDim.x * blockIdx.x;
    int y = threadIdx.y + blockDim.y * blockIdx.y;
    int index = x + width * y;
    float mu1 = alpha;
    float mu2 = 0.f;
    if (x < width && y < height) {
        float lambda1 = l1[index];
        float lambda2 = l2[index];
        float value = alpha + (1.f - alpha) * exp(-C/((lambda1 - lambda2)*(lambda1 - lambda2)));
        mu2 = (lambda1 == lambda2) ? alpha : value;
        m11[index] = (mu1 * e2X[index] * e2X[index] + mu2 * e1X[index] * e1X[index]);
        m22[index] = (mu1 * e2Y[index] * e2Y[index] + mu2 * e1Y[index] * e1Y[index]);
        m12[index] = (mu1 * e2X[index] * e2Y[index] + mu2 * e1X[index] * e1Y[index]);
    }
}

__global__ void apply_G(float* outX, float* outY, float* inX, float* inY, float* m11, float* m12, float* m22, int width, int height, int channel) {
    int x = threadIdx.x + blockDim.x * blockIdx.x;
    int y = threadIdx.y + blockDim.y * blockIdx.y;
    int index = x + width * y;
    float x1 = 0.f;
    float x2 = 0.f;
    if (x < width && y < height) {
        for (int i = 0; i < channel; i++) {
            x1 = m11[index] * inX[index + i * height * width] + m12[index] * inY[index + i * width * height];
            x2 = m22[index] * inY[index + i * height * width] + m12[index] * inX[index + i * width * height];
            outX[index + i * width * height] = x1;
            outY[index + i * width * height] = x2;
        }
    }
}

__global__ void make_update(float* u_nPlusOne, float* u_n, float* div, float tau, int width, int height, int channel) {
    int x = threadIdx.x + blockDim.x * blockIdx.x;
    int y = threadIdx.y + blockDim.y * blockIdx.y;
    int index = x + width * y;
    if (x < width && y < height) {
        for (int i = 0; i < channel; i++) {
            u_nPlusOne[index + i * height * width] = u_n[index + i * height * width] + tau * div[index + i * height * width];
        }
    }
}

__global__ void eigenvalue(float* lambda1, float* lambda2, float* ev1x, float* ev1y, float* ev2x, float* ev2y, float* m11, float* m12, float* m22, int width, int height) {
    int x = threadIdx.x + blockDim.x * blockIdx.x;
    int y = threadIdx.y + blockDim.y * blockIdx.y;
    int index = x + width * y;
    float l1 = 0.f;
    float l2 = 0.f;
    if (x < width && y < height) {
        float T = m11[index] + m22[index];
        float D = m11[index] * m22[index] - m12[index] * m12[index];
        l1 = T / 2.f + sqrtf((T*T) / 4.f - D);
        l2 = T / 2.f - sqrtf((T*T) / 4.f - D);
        if (l1 > l2) {
            lambda1[index] = l2;
            lambda2[index] = l1;
        } else {
            lambda1[index] = l1;
            lambda2[index] = l2;
        }
        if (m12[index] == 0){
            ev1x[index] = 1.f;
            ev1y[index] = 0.f;
            ev2x[index] = 0.f;
            ev2y[index] = 1.f;
        } else {
            float ex1 = lambda1[index] - m22[index];
            float ex2 = lambda2[index] - m22[index];
            float ey = m12[index];
            float l21 = sqrtf(ex1*ex1 + ey*ey);
            float l22 = sqrtf(ex2*ex2 + ey*ey);
            ev1x[index] = ex1 / l21;
            ev1y[index] = ey / l21;
            ev2x[index] = ex2 / l22;
            ev2y[index] = ey / l22;
        }
        // ev1x[index] = l21 == 0 ? 0 : ex1 / l21;
        // ev1y[index] = l21 == 0 ? 0 : ey / l21;
        // ev2x[index] = l22 == 0 ? 0 : ex2 / l22;
        // ev2y[index] = l22 == 0 ? 0 : ey / l22;
    }
}

// __global__ void eigenvalue(float* lambda1, float* lambda2, float* m11, float* m12, float* m22, int width, int height) {
//     int x = threadIdx.x + blockDim.x * blockIdx.x;
//     int y = threadIdx.y + blockDim.y * blockIdx.y;
//     int index = x + width * y;
//     float l1 = 0.f;
//     float l2 = 0.f;
//     if (x < width && y < height) {
//         float T = m11[index] + m22[index];
//         float D = m11[index] * m22[index] - m12[index] * m12[index];
//         l1 = T / 2.f + sqrtf((T*T) / 4.f - D);
//         l2 = T / 2.f - sqrtf((T*T) / 4.f - D);
//         if (l1 > l2) {
//             lambda1[index] = l2;
//             lambda2[index] = l1;
//         } else {
//             lambda1[index] = l1;
//             lambda2[index] = l2;
//         }
//     }
// }

__global__ void eigenvector(float* e1, float* e2, float* c, float* d, float* ev, int width, int height) {
    int x = threadIdx.x + blockDim.x * blockIdx.x;
    int y = threadIdx.y + blockDim.y * blockIdx.y;
    int index = x + width * y;
    if (x < width && y < height) {
        // e1[index] = 255;
        // e2[index] = 255;
        int ex = ev[index] - d[index];
        int ey = c[index];
        int l2 = sqrtf(ex*ex + ey*ey);
        e1[index] = l2 == 0 ? 0 : ex / l2;
        e2[index] = l2 == 0 ? 0 : ey / l2;
    }
}

// __global__ void eigenvector(float* ev1X, float* ev1Y, float* ev2X, float* ev2Y, float* m12, float* m22, float* l1, float* l2, int width, int height) {
//     int x = threadIdx.x + blockDim.x * blockIdx.x;
//     int y = threadIdx.y + blockDim.y * blockIdx.y;
//     int index = x + width * y;
//     if (x < width && y < height) {
//         int m12_val = m12[index];
//         int m22_val = m22[index];
//         if (m12_val > 0 || m12_val < 0) {
//             int e1x = l1[index] - m22_val;
//             int e2x = l2[index] - m22_val;
//             int l2_1 = sqrtf(e1x*e1x + m22_val*m22_val);
//             int l2_2 = sqrtf(e2x*e2x + m22_val*m22_val);
//             ev1X[index] = e1x / l2_1;
//             ev1Y[index] = m12_val / l2_1;
//             ev2X[index] = e2x / l2_2;
//             ev2Y[index] = m12_val / l2_2;
//         } else {
//             ev1X[index] = 1.f;
//             ev1Y[index] = 0.f;
//             ev2X[index] = 0.f;
//             ev2Y[index] = 1.f;
//         }
//     }
// }

__global__ void del_x_plus(float* out, float* in, int width, int height) {
    int x = threadIdx.x + blockDim.x * blockIdx.x;
    int y = threadIdx.y + blockDim.y * blockIdx.y;
    int c = threadIdx.z + blockDim.z * blockIdx.z;
    int index = x + width * y + width * height * c;
    if (x < width && y < height) {
        out[index] = x < width + 1 ? in[x+1 + width * y + width * height * c] - in[index] : 0.f;
    }
}

__global__ void del_y_plus(float* out, float* in, int width, int height) {
    int x = threadIdx.x + blockDim.x * blockIdx.x;
    int y = threadIdx.y + blockDim.y * blockIdx.y;
    int c = threadIdx.z + blockDim.z * blockIdx.z;
    int index = x + width * y + width * height * c;
    if (x < width && y < height) {
        out[index] = y < height + 1 ? in[x + width * (y+1) + width * height * c] - in[index] : 0.f;
    }
}

__global__ void del_x_minus(float* out, float* in, int width, int height) {
    int x = threadIdx.x + blockDim.x * blockIdx.x;
    int y = threadIdx.y + blockDim.y * blockIdx.y;
    int c = threadIdx.z + blockDim.z * blockIdx.z;
    int index = x + width * y + width * height * c;
    if (x < width && y < height) {
        out[index] = x > 0 ? in[index] - in[x-1 + y * width + width * height * c] : in[index];
    }
}

__global__ void del_y_minus(float* out, float* in, int width, int height) {
    int x = threadIdx.x + blockDim.x * blockIdx.x;
    int y = threadIdx.y + blockDim.y * blockIdx.y;
    int c = threadIdx.z + blockDim.z * blockIdx.z;
    int index = x + width * y + width * height * c;
    if (x < width && y < height) {
        out[index] = y > 0 ? in[index] - in[x + (y-1) * width + width * height * c] : in[index];
    }
}

__global__ void convolute(float* out, float* in , float* kernel, int radius, int width, int height, int channel) {
    int x = threadIdx.x + blockDim.x * blockIdx.x;
    int y = threadIdx.y + blockDim.y * blockIdx.y;
    int c = threadIdx.z + blockDim.z * blockIdx.z;
    int index = x + width * y + c * width * height;
    float con_sum = 0.f;
    int diam = 2 * radius + 1;
    if (x < width && y < height) {
        for (int i = -radius; i <= radius; i++) {
            for (int j = -radius; j <= radius; j++) {
                int xc = fmax(fmin((float)(width-1), (float)(x+j)), 0.f);
                int yc = fmax(fmin((float)(height-1), (float)(y+i)), 0.f);
                con_sum += in[xc + yc * width + c * width * height] * kernel[(j+radius) + (i+radius) * diam];
            }
        }
        out[index] = con_sum;
    }
}

void gaussian_kernel(float* kernel, float sigma, int radius, int diameter) {
    int i, j;
    float sum = 0.f;
    float denom = 2.0 * sigma * sigma;
    float e = 0.f;
    for (i = -radius; i <= radius; i++) {
        for (j = -radius; j <= radius; j++) {
            e = pow(j, 2) + pow(i, 2);
            kernel[(j + radius) + (i + radius) * diameter] = exp(-e / denom) / (denom * PI);
            sum += kernel[(j + radius) + (i + radius) * diameter];
        }
    }
    for (i = 0; i < diameter*diameter; i++) {
        kernel[i] /= sum;
    }
}

int main(int argc, char **argv)
{
    // Before the GPU can process your kernels, a so called "CUDA context" must be initialized
    // This happens on the very first call to a CUDA function, and takes some time (around half a second)
    // We will do it right here, so that the run time measurements are accurate
    cudaDeviceSynchronize();  CUDA_CHECK;

    // Reading command line parameters:
    // getParam("param", var, argc, argv) looks whether "-param xyz" is specified, and if so stores the value "xyz" in "var"
    // If "-param" is not specified, the value of "var" remains unchanged
    //
    // return value: getParam("param", ...) returns true if "-param" is specified, and false otherwise

#ifdef CAMERA
#else
    // input image
    string image = "";
    bool ret = getParam("i", image, argc, argv);
    if (!ret) cerr << "ERROR: no image specified" << endl;
    if (argc <= 1) { cout << "Usage: " << argv[0] << " -i <image> [-repeats <repeats>] [-gray]" << endl; return 1; }
#endif
    
    // number of computation repetitions to get a better run time measurement
    int repeats = 1;
    getParam("repeats", repeats, argc, argv);
    cout << "repeats: " << repeats << endl;
    
    // load the input image as grayscale if "-gray" is specifed
    bool gray = false;
    getParam("gray", gray, argc, argv);
    cout << "gray: " << gray << endl;

    // load the input image as grayscale if "-gray" is specifed
    float alpha = 0.01;
    getParam("alpha", alpha, argc, argv);
    cout << "alpha: " << alpha << endl;

    // load the input image as grayscale if "-gray" is specifed
    float C = 5.f * pow(10, -6);
    getParam("C", C, argc, argv);
    cout << "C: " << C << endl;

    // load the input image as grayscale if "-gray" is specifed
    float tau = 0.25;
    getParam("tau", tau, argc, argv);
    cout << "tau: " << tau << endl;

    // load the input image as grayscale if "-gray" is specifed
    float eps = 1.f;
    getParam("eps", eps, argc, argv);
    cout << "eps: " << eps << endl;

    // load the input image as grayscale if "-gray" is specifed
    int kind = 1;
    getParam("kind", kind, argc, argv);
    cout << "kind: " << kind << endl;
    
    // load the input image as grayscale if "-gray" is specifed
    float sigma = 0.5;
    getParam("sigma", sigma, argc, argv);
    cout << "sigma: " << sigma << endl;
    int radius = ceil(3 * sigma);
    int diameter = 2 * radius + 1;

    // load the input image as grayscale if "-gray" is specifed
    float rho = 3.f;
    getParam("rho", rho, argc, argv);
    cout << "rho: " << rho << endl;
    int radius_rho = ceil(3 * rho);
    int diameter_rho = 2 * radius_rho + 1;

    // Init camera / Load input image
#ifdef CAMERA

    // Init camera
    cv::VideoCapture camera(0);
    if(!camera.isOpened()) { cerr << "ERROR: Could not open camera" << endl; return 1; }
    int camW = 640;
    int camH = 480;
    camera.set(CV_CAP_PROP_FRAME_WIDTH,camW);
    camera.set(CV_CAP_PROP_FRAME_HEIGHT,camH);
    // read in first frame to get the dimensions
    cv::Mat mIn;
    camera >> mIn;
    
#else
    
    // Load the input image using opencv (load as grayscale if "gray==true", otherwise as is (may be color or grayscale))
    cv::Mat mIn = cv::imread(image.c_str(), (gray? CV_LOAD_IMAGE_GRAYSCALE : -1));
    // check
    if (mIn.data == NULL) { cerr << "ERROR: Could not load image " << image << endl; return 1; }
    
#endif

    // convert to float representation (opencv loads image values as single bytes by default)
    mIn.convertTo(mIn,CV_32F);
    // convert range of each channel to [0,1] (opencv default is [0,255])
    mIn /= 255.f;
    // get image dimensions
    int w = mIn.cols;         // width
    int h = mIn.rows;         // height
    int nc = mIn.channels();  // number of channels
    int size = w * h * nc;
    int nbyte = size * sizeof(float);
    cout << "image: " << w << " x " << h << endl;

    // Set the output image format
    // ###
    // ###
    // ### TODO: Change the output image format as needed
    // ###
    // ###
    cv::Mat mOut(h,w,mIn.type());  // mOut will have the same number of channels as the input image, nc layers
    cv::Mat M11(h,w,CV_8UC1);  // mOut will have the same number of channels as the input image, nc layers
    cv::Mat M12(h,w,CV_8UC1);  // mOut will have the same number of channels as the input image, nc layers
    cv::Mat M22(h,w,CV_8UC1);  // mOut will have the same number of channels as the input image, nc layers
    //cv::Mat mOut(h,w,CV_32FC3);    // mOut will be a color image, 3 layers
    //cv::Mat mOut(h,w,CV_32FC1);    // mOut will be a grayscale image, 1 layer
    // ### Define your own output images here as needed

    // Allocate arrays
    // input/output image width: w
    // input/output image height: h
    // input image number of channels: nc
    // output image number of channels: mOut.channels(), as defined above (nc, 3, or 1)

    // allocate raw input image array
    // allocate raw output array (the computation result will be stored in this array, then later converted to mOut for displaying)
    float *h_imgIn  = new float[(size_t)size];
    float *h_kernel = new float[diameter*diameter];
    float *h_kernel_rho = new float[diameter_rho*diameter_rho];
    float *h_imgOut = new float[(size_t)w*h*mOut.channels()];
    float *h_conv = new float[(size_t)w*h*mOut.channels()];
    float *h_m11 = new float[(size_t)w*h];
    float *h_m12 = new float[(size_t)w*h];
    float *h_m22 = new float[(size_t)w*h];

    // allocate raw input image for GPU
    float* d_imgIn;
    float* d_imgOut;
    float* d_kernel;
    float* d_kernel_rho;
    float* d_conv;
    float* d_delX;
    float* d_delY;
    float* d_delX2;
    float* d_delY2;
    float* d_ev1X;
    float* d_ev1Y;
    float* d_ev2X;
    float* d_ev2Y;
    float* d_divX;
    float* d_divY;
    float* d_divergence;
    float* d_m11;
    float* d_m12;
    float* d_m22;
    float* d_m11conv;
    float* d_m12conv;
    float* d_m22conv;
    float* d_lambda1;
    float* d_lambda2;

    // alloc GPU memory
    cudaMalloc(&d_imgIn, nbyte);
    CUDA_CHECK;
    cudaMalloc(&d_imgOut, nbyte);
    CUDA_CHECK;
    cudaMalloc(&d_conv, nbyte);
    CUDA_CHECK;
    cudaMalloc(&d_delX, nbyte);
    CUDA_CHECK;
    cudaMalloc(&d_delY, nbyte);
    CUDA_CHECK;
    cudaMalloc(&d_delX2, nbyte);
    CUDA_CHECK;
    cudaMalloc(&d_delY2, nbyte);
    CUDA_CHECK;
    cudaMalloc(&d_divX, nbyte);
    CUDA_CHECK;
    cudaMalloc(&d_divY, nbyte);
    CUDA_CHECK;
    cudaMalloc(&d_divergence, nbyte);
    CUDA_CHECK;
    cudaMalloc(&d_kernel, diameter*diameter*sizeof(float));
    CUDA_CHECK;
    cudaMalloc(&d_kernel_rho, diameter_rho*diameter_rho*sizeof(float));
    CUDA_CHECK;
    cudaMalloc(&d_m11, w*h*sizeof(float));
    CUDA_CHECK;
    cudaMalloc(&d_m12, w*h*sizeof(float));
    CUDA_CHECK;
    cudaMalloc(&d_m22, w*h*sizeof(float));
    CUDA_CHECK;
    cudaMalloc(&d_m11conv, w*h*sizeof(float));
    CUDA_CHECK;
    cudaMalloc(&d_m12conv, w*h*sizeof(float));
    CUDA_CHECK;
    cudaMalloc(&d_m22conv, w*h*sizeof(float));
    CUDA_CHECK;
    cudaMalloc(&d_lambda1, w*h*sizeof(float));
    CUDA_CHECK;
    cudaMalloc(&d_lambda2, w*h*sizeof(float));
    CUDA_CHECK;
    cudaMalloc(&d_ev1X, w*h*sizeof(float));
    CUDA_CHECK;
    cudaMalloc(&d_ev1Y, w*h*sizeof(float));
    CUDA_CHECK;
    cudaMalloc(&d_ev2X, w*h*sizeof(float));
    CUDA_CHECK;
    cudaMalloc(&d_ev2Y, w*h*sizeof(float));
    CUDA_CHECK;

    // For camera mode: Make a loop to read in camera frames
#ifdef CAMERA
    // Read a camera image frame every 30 milliseconds:
    // cv::waitKey(30) waits 30 milliseconds for a keyboard input,
    // returns a value <0 if no key is pressed during this time, returns immediately with a value >=0 if a key is pressed
    while (cv::waitKey(30) < 0)
    {
    // Get camera image
    camera >> mIn;
    // convert to float representation (opencv loads image values as single bytes by default)
    mIn.convertTo(mIn,CV_32F);
    // convert range of each channel to [0,1] (opencv default is [0,255])
    mIn /= 255.f;
#endif

    // Init raw input image array
    // opencv images are interleaved: rgb rgb rgb...  (actually bgr bgr bgr...)
    // But for CUDA it's better to work with layered images: rrr... ggg... bbb...
    // So we will convert as necessary, using interleaved "cv::Mat" for loading/saving/displaying, and layered "float*" for CUDA computations
    convert_mat_to_layered (h_imgIn, mIn);

    gaussian_kernel(h_kernel, sigma, radius, diameter);
    gaussian_kernel(h_kernel_rho, rho, radius_rho, diameter_rho);
    // copy host memory
    cudaMemcpy(d_imgIn, h_imgIn, nbyte, cudaMemcpyHostToDevice);
    CUDA_CHECK;
    cudaMemcpy(d_kernel, h_kernel, diameter*diameter*sizeof(float), cudaMemcpyHostToDevice);
    CUDA_CHECK;
    cudaMemcpy(d_kernel_rho, h_kernel_rho, diameter_rho*diameter_rho*sizeof(float), cudaMemcpyHostToDevice);
    CUDA_CHECK;

    // launch kernel
    dim3 block = dim3(32, 8, nc);
    dim3 grid = dim3((w + block.x - 1) / block.x, (h + block.y - 1) / block.y, (nc + block.z - 1) / block.z);
    dim3 block_sum_up = dim3(256, 1, 1);
    dim3 grid_sum_up = dim3((size + block_sum_up.x - 1) / block_sum_up.x, 1, 1);
    dim3 block_matrix = dim3(32, 8, 1);
    dim3 grid_matrix = dim3((w + block.x - 1) / block.x, (h + block.y - 1) / block.y, 1);

    convolute <<<grid, block>>> (d_conv, d_imgIn, d_kernel, radius, w, h, nc);
    del_x_plus <<<grid, block>>> (d_delX, d_conv, w, h);
    del_y_plus <<<grid, block>>> (d_delY, d_conv, w, h);
    compute_matrix <<<grid_matrix, block_matrix>>> (d_m11, d_m12, d_m22, d_delX, d_delY, w, h, nc);
    convolute <<<grid_matrix, block_matrix>>> (d_m11conv, d_m11, d_kernel_rho, radius_rho, w, h, 1);
    convolute <<<grid_matrix, block_matrix>>> (d_m12conv, d_m12, d_kernel_rho, radius_rho, w, h, 1);
    convolute <<<grid_matrix, block_matrix>>> (d_m22conv, d_m22, d_kernel_rho, radius_rho, w, h, 1);
    eigenvalue <<<grid_matrix, block_matrix>>> (d_lambda1, d_lambda2, d_ev1X, d_ev1Y, d_ev2X, d_ev2Y, d_m11conv, d_m12conv, d_m22conv, w, h);
    // eigenvector <<<grid_matrix, grid_matrix>>> (d_ev1X, d_ev1Y, d_m12conv, d_m22conv, d_lambda1, w, h);
    // eigenvector <<<grid_matrix, grid_matrix>>> (d_ev2X, d_ev2Y, d_m12conv, d_m22conv, d_lambda2, w, h);
    // eigenvector <<<grid_matrix, grid_matrix>>> (d_ev1X, d_ev1Y, d_ev2X, d_ev2Y, d_m12conv, d_m22conv, d_lambda1, d_lambda2, w, h);
    compute_G <<<grid_matrix, block_matrix>>> (d_m11, d_m12, d_m22, d_ev1X, d_ev1Y, d_ev2X, d_ev2Y, d_lambda1, d_lambda2, alpha, C, w, h, nc);
    
    Timer timer; timer.start();
    for (int i = 1; i <= repeats; i++) {
        del_x_plus <<<grid, block>>> (d_delX, d_imgIn, w, h);
        del_y_plus <<<grid, block>>> (d_delY, d_imgIn, w, h);
        apply_G <<<grid_matrix, block_matrix>>> (d_delX2, d_delY2, d_delX, d_delY, d_m11, d_m12, d_m22, w, h, nc);
        del_x_minus <<<grid, block>>> (d_divX, d_delX2, w, h);
        del_y_minus <<<grid, block>>> (d_divY, d_delY2, w, h);
        addArray <<<grid_sum_up, block_sum_up>>> (d_divergence, d_divX, d_divY, size);
        if (i == repeats) {
            make_update <<<grid_matrix, block_matrix>>> (d_imgOut, d_imgIn, d_divergence, tau, w, h, nc);
        } else {
            make_update <<<grid_matrix, block_matrix>>> (d_imgIn, d_imgIn, d_divergence, tau, w, h, nc);
        }
    }

    timer.end();  float t = timer.get();  // elapsed time in seconds
    cout << "time: " << t*1000 << " ms" << endl;

    cudaMemcpy(h_imgOut, d_imgOut, nbyte, cudaMemcpyDeviceToHost);
    CUDA_CHECK;
    cudaMemcpy(h_m11, d_ev1X, w*h*sizeof(float), cudaMemcpyDeviceToHost);
    CUDA_CHECK;
    cudaMemcpy(h_m12, d_ev1Y, w*h*sizeof(float), cudaMemcpyDeviceToHost);
    CUDA_CHECK;
    cudaMemcpy(h_m22, d_ev2X, w*h*sizeof(float), cudaMemcpyDeviceToHost);
    CUDA_CHECK;

    for (int i = 0; i < h; i++) {
        for (int j = 0; j < w; j++) {
            M11.at<uchar>(i, j) = h_m11[j + i * w] * 1000;
            M12.at<uchar>(i, j) = h_m12[j + i * w] * 1000;
            M22.at<uchar>(i, j) = h_m22[j + i * w] * 1000;
            // if (i < 20 && j < 20) {
            //     cout << h_m11[j + i * w] << "  ";
            // }
        }
        // if (i < 20) {
        //     cout << endl;
        // }
    }

    // free GPU memory
    cudaFree(d_imgIn);
    CUDA_CHECK;
    cudaFree(d_imgOut);
    CUDA_CHECK;
    cudaFree(d_conv);
    CUDA_CHECK;
    cudaFree(d_kernel);
    CUDA_CHECK;
    cudaFree(d_kernel_rho);
    CUDA_CHECK;
    cudaFree(d_delX);
    CUDA_CHECK;
    cudaFree(d_delY);
    CUDA_CHECK;
    cudaFree(d_delX2);
    CUDA_CHECK;
    cudaFree(d_delY2);
    CUDA_CHECK;
    cudaFree(d_ev1X);
    CUDA_CHECK;
    cudaFree(d_ev1Y);
    CUDA_CHECK;
    cudaFree(d_ev2X);
    CUDA_CHECK;
    cudaFree(d_ev2Y);
    CUDA_CHECK;
    cudaFree(d_divX);
    CUDA_CHECK;
    cudaFree(d_divY);
    CUDA_CHECK;
    cudaFree(d_divergence);
    CUDA_CHECK;
    cudaFree(d_m11);
    CUDA_CHECK;
    cudaFree(d_m12);
    CUDA_CHECK;
    cudaFree(d_m22);
    CUDA_CHECK;
    cudaFree(d_m11conv);
    CUDA_CHECK;
    cudaFree(d_m12conv);
    CUDA_CHECK;
    cudaFree(d_m22conv);
    CUDA_CHECK;
    cudaFree(d_lambda1);
    CUDA_CHECK;
    cudaFree(d_lambda2);
    CUDA_CHECK;

    // show input image
    showImage("Input", mIn, 100, 100);  // show at position (x_from_left=100,y_from_above=100)

    // show output image: first convert to interleaved opencv format from the layered raw array
    convert_layered_to_mat(mOut, h_imgOut);
    showImage("Diffusion", mOut, 100+w+40, 100);
    showImage("M11", M11, 100+w+w+80, 100);
    showImage("M12", M12, 100, 100+h+40);
    showImage("M22", M22, 100+w+40, 100+h+40);

    // ### Display your own output images here as needed

#ifdef CAMERA
    // end of camera loop
    }
#else
    // wait for key inputs
    cv::waitKey(0);
#endif

    // save input and result
    cv::imwrite("image_input.png",mIn*255.f);  // "imwrite" assumes channel range [0,255]
    cv::imwrite("image_result.png",mOut*255.f);  // "imwrite" assumes channel range [0,255]
    cv::imwrite("image_M11.png",M11);
    cv::imwrite("image_M12.png",M12);
    cv::imwrite("image_M22.png",M22);

    // free allocated arrays
    delete[] h_imgIn;
    delete[] h_imgOut;
    delete[] h_conv;
    delete[] h_kernel;
    delete[] h_kernel_rho;
    delete[] h_m11;
    delete[] h_m12;
    delete[] h_m22;

    // close all opencv windows
    cvDestroyAllWindows();
    return 0;
}