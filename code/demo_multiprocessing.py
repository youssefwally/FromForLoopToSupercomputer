"""
Monte Carlo Pi Estimation — Python Multiprocessing
Splits work across all CPU cores using multiprocessing.Pool.
Each worker estimates pi independently, results are averaged.
"""
import random
import time
import multiprocessing as mp

NUM_SAMPLES = 20_000_000

def worker_estimate(n):
    """Run by each worker process independently."""
    hits = 0
    for _ in range(n):
        x = random.random()
        y = random.random()
        if x*x + y*y <= 1.0:
            hits += 1
    return hits

def estimate_pi_parallel(n, num_workers):
    chunk = n // num_workers
    with mp.Pool(processes=num_workers) as pool:
        results = pool.map(worker_estimate, [chunk] * num_workers)
    total_hits = sum(results)
    return 4.0 * total_hits / (chunk * num_workers)

if __name__ == "__main__":
    num_cores = mp.cpu_count()
    start = time.time()
    pi = estimate_pi_parallel(NUM_SAMPLES, num_cores)
    elapsed = time.time() - start

    print(f"  Pi ≈ {pi:.6f}  |  Time: {elapsed:.3f}s  |  Workers: {num_cores}")
