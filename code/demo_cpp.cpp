/*
 * Monte Carlo Pi Estimation — C++ (Single-Threaded)
 * Same algorithm as Python version, but compiled native code.
 * Shows the raw speed difference between interpreted vs compiled.
 */
#include <iostream>
#include <cstdlib>
#include <ctime>
#include <chrono>

const long long NUM_SAMPLES = 20'000'000;

int main() {
    srand(42);
    long long hits = 0;

    auto start = std::chrono::high_resolution_clock::now();

    for (long long i = 0; i < NUM_SAMPLES; i++) {
        double x = (double)rand() / RAND_MAX;
        double y = (double)rand() / RAND_MAX;
        if (x*x + y*y <= 1.0) hits++;
    }

    double pi = 4.0 * hits / NUM_SAMPLES;
    auto end = std::chrono::high_resolution_clock::now();
    double elapsed = std::chrono::duration<double>(end - start).count();

    std::cout << "  Pi ≈ " << pi << "  |  Time: " << elapsed << "s" << std::endl;
    return 0;
}
