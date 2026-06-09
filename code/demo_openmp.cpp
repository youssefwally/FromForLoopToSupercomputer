/*
 * Monte Carlo Pi Estimation — C++ with OpenMP
 *
 * Key OpenMP directives used:
 *   #pragma omp parallel for   — splits loop iterations across threads
 *   reduction(+:hits)          — safely accumulates hits from all threads
 *   omp_get_max_threads()      — queries thread count at runtime
 *
 * Compile with:  g++ -fopenmp -O2 -o demo_omp demo_omp.cpp
 * Run with:      ./demo_omp
 * Set threads:   OMP_NUM_THREADS=4 ./demo_omp
 */
#include <iostream>
#include <chrono>
#include <omp.h>

const long long NUM_SAMPLES = 20'000'000;

int main() {
    long long hits = 0;
    int num_threads = omp_get_max_threads();

    auto start = std::chrono::high_resolution_clock::now();

    // Each thread gets its own seed to avoid race conditions
    #pragma omp parallel reduction(+:hits)
    {
        unsigned int seed = 42 + omp_get_thread_num();
        long long local_hits = 0;

        #pragma omp for schedule(static)
        for (long long i = 0; i < NUM_SAMPLES; i++) {
            double x = (double)rand_r(&seed) / RAND_MAX;
            double y = (double)rand_r(&seed) / RAND_MAX;
            if (x*x + y*y <= 1.0) local_hits++;
        }
        hits += local_hits;
    }

    double pi = 4.0 * hits / NUM_SAMPLES;
    auto end = std::chrono::high_resolution_clock::now();
    double elapsed = std::chrono::duration<double>(end - start).count();

    std::cout << "  Pi ≈ " << pi << "  |  Time: " << elapsed
              << "s  |  Threads: " << num_threads << std::endl;
    return 0;
}
