"""
Monte Carlo Pi Estimation — Pure Python (Single-Threaded)
Each point is randomly placed in a unit square.
If it lands inside the quarter circle, it's a "hit".
Pi ≈ 4 * (hits / total_points)
"""
import random
import time

NUM_SAMPLES = 20_000_000

def estimate_pi(n):
    hits = 0
    for _ in range(n):
        x = random.random()
        y = random.random()
        if x*x + y*y <= 1.0:
            hits += 1
    return 4.0 * hits / n

start = time.time()
pi = estimate_pi(NUM_SAMPLES)
elapsed = time.time() - start

print(f"  Pi ≈ {pi:.6f}  |  Time: {elapsed:.3f}s")
