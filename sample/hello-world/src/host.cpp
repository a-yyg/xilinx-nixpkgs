#/*
#Copyright (C) 2023, Advanced Micro Devices, Inc. All rights reserved.
#SPDX-License-Identifier: X11
#*/

//#include "cmdlineparser.h"
#include <iostream>
#include <cstring>
#include <time.h>

// XRT includes
// #include "xrt/xrt_bo.h"
// #include "xrt/xrt_device.h"
// #include "xrt/xrt_kernel.h"
#include <experimental/xrt_xclbin.h>
#include <experimental/xrt_bo.h>
#include <experimental/xrt_device.h>
#include <experimental/xrt_kernel.h>

#define DATA_SIZE 4096

int main(int argc, char** argv) {

    std::cout << "argc = " << argc << std::endl;
	for(int i=0; i < argc; i++){
	    std::cout << "argv[" << i << "] = " << argv[i] << std::endl;
	}

    // Read settings
    std::string binaryFile = "./vadd.xclbin";
    int device_index = 0;

    std::cout << "Open the device" << device_index << std::endl;
    auto device = xrt::device(device_index);
    std::cout << "Load the xclbin " << binaryFile << std::endl;
    auto uuid = device.load_xclbin("./vadd.xclbin");

    int data_size = DATA_SIZE;
    if (argc > 1) {
        data_size = atoi(argv[1]);
    }

    size_t vector_size_bytes = sizeof(int) * data_size;

    //auto krnl = xrt::kernel(device, uuid, "vadd");
    auto krnl = xrt::kernel(device, uuid, "vadd", xrt::kernel::cu_access_mode::exclusive);

    std::cout << "Allocate Buffer in Global Memory: " << vector_size_bytes << std::endl;
    auto boIn1 = xrt::bo(device, vector_size_bytes, krnl.group_id(0)); //Match kernel arguments to RTL kernel
    auto boIn2 = xrt::bo(device, vector_size_bytes, krnl.group_id(1));
    auto boOut = xrt::bo(device, vector_size_bytes, krnl.group_id(2));

    // Map the contents of the buffer object into host memory
    auto bo0_map = boIn1.map<int*>();
    auto bo1_map = boIn2.map<int*>();
    auto bo2_map = boOut.map<int*>();
    std::fill(bo0_map, bo0_map + data_size, 0);
    std::fill(bo1_map, bo1_map + data_size, 0);
    std::fill(bo2_map, bo2_map + data_size, 0);

    // Create the test data
    int bufReference[data_size];
    for (int i = 0; i < data_size; ++i) {
        bo0_map[i] = i;
        bo1_map[i] = i;
    }

    uint64_t cpu = 0, fpga = 0;

    struct timeval start, end;
    gettimeofday(&start, 0);
    for (int i = 0; i < data_size; ++i) {
        bufReference[i] = bo0_map[i] + bo1_map[i]; //Generate check data for validation
    }
    gettimeofday(&end, 0);
    cpu = (end.tv_sec * 1000000 + end.tv_usec) - (start.tv_sec * 1000000 + start.tv_usec);

    gettimeofday(&start, 0);
    // Synchronize buffer content with device side
    std::cout << "synchronize input buffer data to device global memory\n";
    boIn1.sync(XCL_BO_SYNC_BO_TO_DEVICE);
    boIn2.sync(XCL_BO_SYNC_BO_TO_DEVICE);

    std::cout << "Execution of the kernel\n";
    auto run = krnl(boIn1, boIn2, boOut, data_size); //data_size=size
    run.wait();

    // Get the output;
    std::cout << "Get the output data from the device" << std::endl;
    boOut.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
    gettimeofday(&end, 0);
    fpga = (end.tv_sec * 1000000 + end.tv_usec) - (start.tv_sec * 1000000 + start.tv_usec);

    std::cout << "CPU time: " << cpu << " us" << std::endl;
    std::cout << "FPGA time: " << fpga << " us" << std::endl;
    std::cout << "Speed up: " << (float)cpu / (float)fpga << " x" << std::endl;


    // Validate results
    if (std::memcmp(bo2_map, bufReference, vector_size_bytes))
        throw std::runtime_error("Value read back does not match reference");

    std::cout << "TEST PASSED\n";
    return 0;
}
