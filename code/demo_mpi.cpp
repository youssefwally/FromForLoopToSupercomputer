/*
 * Monte Carlo Pi Estimation — C++ with MPI
 *
 * Key MPI concepts demonstrated:
 *   MPI_Init / MPI_Finalize     — boot and teardown the MPI runtime
 *   MPI_Comm_size               — total number of processes
 *   MPI_Comm_rank               — this process's ID (0 = root)
 *   MPI_Reduce                  — gather results from all processes to root
 *
 * Unlike OpenMP (shared memory, same machine),
 * MPI works across MULTIPLE MACHINES in a cluster.
 *
 * Compile with:  mpic++ -O2 -o demo_mpi demo_mpi.cpp
 * Run with:      mpirun -np 4 ./demo_mpi
 * Run on nodes:  mpirun -np 16 --hostfile hosts.txt ./demo_mpi
 */
#include <iostream>
#include <mpi.h>
#include <cstdlib>

const long long NUM_SAMPLES = 20'000'000;

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int world_size, world_rank;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);  // total processes
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);  // this process's ID

    // Each process handles its own chunk of samples
    long long chunk = NUM_SAMPLES / world_size;
    unsigned int seed = 42 + world_rank;
    long long local_hits = 0;

    double start = MPI_Wtime();

    for (long long i = 0; i < chunk; i++) {
        double x = (double)rand_r(&seed) / RAND_MAX;
        double y = (double)rand_r(&seed) / RAND_MAX;
        if (x*x + y*y <= 1.0) local_hits++;
    }

    // Gather all local_hits into total_hits on rank 0
    long long total_hits = 0;
    MPI_Reduce(&local_hits, &total_hits, 1, MPI_LONG_LONG, MPI_SUM, 0, MPI_COMM_WORLD);

    // Only the root process (rank 0) prints the result
    if (world_rank == 0) {
        double pi = 4.0 * total_hits / (chunk * world_size);
        double elapsed = MPI_Wtime() - start;
        std::cout << "  Pi ≈ " << pi << "  |  Time: " << elapsed
                  << "s  |  Processes: " << world_size << std::endl;
    }

    MPI_Finalize();
    return 0;
}
