# FromFor-LoopToSupercomputer
A Hands-On Introduction to Parallel Computing with OpenMP and MPI

# Description

Most research code starts the same way: a for-loop over a dataset, processing one item at a time. This tutorial shows how to break that bottleneck — step by step, from a single CPU core all the way to a distributed HPC cluster.

Starting from a plain Python loop (SISD — Single Instruction, Single Data), we walk through Flynn's Taxonomy to build intuition about why parallelism works, then implement the same workload four different ways: Python multiprocessing, C++ (sequential), C++ with OpenMP, and C++ with MPI. Each version comes with live benchmarks so attendees can see the speedup for themselves. 

By the end of the session, attendees will understand:
1. The difference between shared-memory (OpenMP) and distributed-memory (MPI) parallelism
2. When to reach for each tool and when not to
3. The key OpenMP pragma that can parallelise a loop in one line
4. How MPI coordinates work across multiple machines, and why it scales to thousands of nodes

All code is provided as ready-to-run scripts. No prior parallel programming experience is required, just basic familiarity with Python and/or C++. In this repository you will find an example for running a [Monte Carlo Pi Estimation](https://www.geeksforgeeks.org/dsa/estimating-value-pi-using-monte-carlo/) using 20,000,000 random points implemented in:

1. [Baseline Sequential Python](https://github.com/youssefwally/FromForLoopToSupercomputer/blob/main/code/demo_python.py)
2. [C++](https://github.com/youssefwally/FromForLoopToSupercomputer/blob/main/code/demo_cpp.cpp)
3. [Multiprocess Python](https://github.com/youssefwally/FromForLoopToSupercomputer/blob/main/code/demo_multiprocessing.py)
4. [OpenMP](https://github.com/youssefwally/FromForLoopToSupercomputer/blob/main/code/demo_openmp.cpp)
5. [MPI](https://github.com/youssefwally/FromForLoopToSupercomputer/blob/main/code/demo_mpi.cpp)

# Quick start:

```
git clone git@github.com:youssefwally/FromForLoopToSupercomputer.git
cd FromForLoopToSupercomputer/code
chmod +x run_demo.sh && ./run_demo.sh
```
