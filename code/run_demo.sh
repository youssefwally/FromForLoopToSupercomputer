#!/usr/bin/env bash
# =============================================================================
#  OpenMP & MPI Tutorial Demo — Monte Carlo Pi Estimation
#  Task: Estimate Pi using 20,000,000 random points
#  Run:  chmod +x run_demo.sh && ./run_demo.sh
# =============================================================================

# ── Colors ────────────────────────────────────────────────────────────────────
BOLD='\033[1m'; RESET='\033[0m'
CYAN='\033[1;36m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'
BLUE='\033[1;34m'; MAGENTA='\033[1;35m'
WHITE='\033[1;37m'; DIM='\033[2m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# ── Detect OS & set compiler / OpenMP flags ───────────────────────────────────
# macOS ships clang++ which needs Homebrew libomp for OpenMP.
# Linux g++ supports -fopenmp natively.
CXX="${CXX:-g++}"
OMP_FLAGS="-fopenmp"
OMP_INSTALL_HINT=""

if [[ "$(uname)" == "Darwin" ]]; then
    # Strategy 1: find any Homebrew g++ (g++-15, 14, 13, 12, ...)
    BREW_GXX=$(ls "$(brew --prefix)/bin/g++-"* 2>/dev/null | sort -V | tail -1)
    if [[ -x "$BREW_GXX" ]]; then
        CXX="$BREW_GXX"
    # Strategy 2: clang++ + Homebrew libomp
    elif LIBOMP="$(brew --prefix libomp 2>/dev/null)"; then
        OMP_FLAGS="-Xpreprocessor -fopenmp -I${LIBOMP}/include -L${LIBOMP}/lib -lomp"
        OMP_INSTALL_HINT="  (clang++ + Homebrew libomp)"
    else
        OMP_FLAGS=""
        OMP_INSTALL_HINT="install via: brew install gcc  or  brew install libomp"
    fi
    NUM_CORES=$(sysctl -n hw.logicalcpu 2>/dev/null || echo 2)
else
    NUM_CORES=$(nproc 2>/dev/null || echo 2)
fi

# ── Header ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║${WHITE}      🧮  Monte Carlo Pi Estimation — Parallelism Demo        ${CYAN}║${RESET}"
echo -e "${CYAN}║${DIM}      Estimate π using 20,000,000 random (x,y) points         ${CYAN}║${RESET}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${DIM}  Algorithm: Drop random points in a unit square."
echo -e "  If x² + y² ≤ 1  →  point is inside the quarter circle."
echo -e "  π ≈ 4 × (hits / total)${RESET}"
echo ""

# ── Compile C++ files ─────────────────────────────────────────────────────────
echo -e "${YELLOW}▶ Compiling C++ programs...  (compiler: ${CXX}, OpenMP flags: ${OMP_FLAGS:-none})${RESET}"

CPP_OK=false; OMP_OK=false; MPI_OK=false

if $CXX -O2 -o demo_cpp demo_cpp.cpp 2>/dev/null; then
    echo -e "  ${GREEN}✔${RESET} demo_cpp compiled"
    CPP_OK=true
else
    echo -e "  ${YELLOW}✘${RESET} demo_cpp failed to compile"
fi

if [[ -n "$OMP_FLAGS" ]]; then
    # shellcheck disable=SC2086
    if $CXX -O2 $OMP_FLAGS -o demo_openmp demo_openmp.cpp 2>/dev/null; then
        echo -e "  ${GREEN}✔${RESET} demo_openmp compiled (OpenMP)${OMP_INSTALL_HINT}"
        OMP_OK=true
    else
        echo -e "  ${YELLOW}✘${RESET} demo_openmp failed — try: brew install libomp  or  brew install gcc"
    fi
else
    echo -e "  ${YELLOW}✘${RESET} OpenMP unavailable — ${OMP_INSTALL_HINT}"
fi

if command -v mpic++ &>/dev/null; then
    if mpic++ -O2 -o demo_mpi demo_mpi.cpp 2>/dev/null; then
        echo -e "  ${GREEN}✔${RESET} demo_mpi compiled (MPI)"
        MPI_OK=true
    fi
else
    echo -e "  ${DIM}✘ mpic++ not found — MPI skipped  (brew install open-mpi  |  sudo apt install mpich)${RESET}"
fi
echo ""

# ── Helpers ───────────────────────────────────────────────────────────────────
# Portable time extractor: no grep -P (not on macOS)
extract_time() {
    echo "$1" | grep -oE 'Time: [0-9]+\.[0-9]+' | grep -oE '[0-9]+\.[0-9]+'
}

# Runs a command, prints colored box to STDERR (so it shows live),
# and echoes just the time value to STDOUT (so it can be captured).
run_and_capture() {
    local label="$1"; local color="$2"; shift 2
    echo -e "${color}┌─ ${label}${RESET}" >&2
    local output
    output=$("$@" 2>&1)
    echo -e "${color}│${RESET}  $output" >&2
    echo -e "${color}└──────────────────────────────────────────────${RESET}" >&2
    echo "" >&2
    extract_time "$output"   # → stdout only, captured by caller
}

# ── Run all benchmarks ────────────────────────────────────────────────────────
echo -e "${BOLD}${WHITE}━━━  Running Benchmarks  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "π ≈ 3.141592653"
echo ""

TIME_py=$(run_and_capture    "🐍 Python         (single-threaded)" "$BLUE"    python3 demo_python.py)
TIME_py_mp=$(run_and_capture "🐍 Python         (multiprocessing)" "$BLUE"    python3 demo_multiprocessing.py)

TIME_cpp="N/A"; TIME_omp="N/A"; TIME_mpi="N/A"
$CPP_OK && TIME_cpp=$(run_and_capture "⚙️  C++            (single-threaded)" "$GREEN"   ./demo_cpp)
$OMP_OK && TIME_omp=$(run_and_capture "⚡ C++ + OpenMP   (shared memory)"    "$MAGENTA" ./demo_openmp)
$MPI_OK && TIME_mpi=$(run_and_capture "🌐 C++ + MPI      (distributed)"      "$CYAN"    mpirun -np "$NUM_CORES" ./demo_mpi)

# ── Summary Table ─────────────────────────────────────────────────────────────
echo -e "${BOLD}${WHITE}━━━  Results Summary  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "${WHITE}  ┌──────────────────────────────────────────┬───────────┬───────────┐${RESET}"
echo -e "${WHITE}  │  Method                                  │   Time    │  Speedup  │${RESET}"
echo -e "${WHITE}  ├──────────────────────────────────────────┼───────────┼───────────┤${RESET}"

BASE="$TIME_py"

print_row() {
    local label="$1"; local t="$2"; local color="$3"
    local speedup="—"
    if [[ -n "$t" && "$t" != "N/A" && -n "$BASE" && "$BASE" != "N/A" ]]; then
        speedup=$(python3 -c "print(f'{float(${BASE})/float(${t}):.2f}x')" 2>/dev/null || echo "—")
    fi
    local display_t="${t:-N/A}"
    [[ "$display_t" != "N/A" ]] && display_t="${display_t}s"
    printf "  │  ${color}%-40s${RESET}${WHITE}│  %-9s│  %-9s│${RESET}\n" \
           "$label" "$display_t" "$speedup"
}

print_row "Python (single-threaded)"  "$TIME_py"    "$BLUE"
print_row "Python (multiprocessing)"  "$TIME_py_mp" "$BLUE"
$CPP_OK && print_row "C++ (single-threaded)"     "$TIME_cpp"   "$GREEN"
$OMP_OK && print_row "C++ + OpenMP"              "$TIME_omp"   "$MAGENTA"
$MPI_OK && print_row "C++ + MPI"                 "$TIME_mpi"   "$CYAN"

echo -e "${WHITE}  └──────────────────────────────────────────┴───────────┴───────────┘${RESET}"
echo ""
echo -e "${DIM}  Speedup is relative to Python single-threaded baseline.${RESET}"
echo ""

# ── Key Takeaways ─────────────────────────────────────────────────────────────
echo -e "${BOLD}${WHITE}━━━  Key Takeaways  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  ${YELLOW}●${RESET} ${BOLD}Python vs C++${RESET}        Compiled code is dramatically faster even"
echo -e "                         without any parallelism."
echo ""
echo -e "  ${YELLOW}●${RESET} ${BOLD}Multiprocessing${RESET}      Python sidesteps the GIL by spawning separate"
echo -e "                         OS processes. Good for CPU-bound tasks."
echo ""
echo -e "  ${YELLOW}●${RESET} ${BOLD}OpenMP${RESET}               Shared-memory threading — one machine, multiple"
echo -e "                         cores. Minimal code changes (#pragma omp)."
echo ""
echo -e "  ${YELLOW}●${RESET} ${BOLD}MPI${RESET}                  Distributed memory — can run across MULTIPLE"
echo -e "                         MACHINES. Each rank has its own memory space."
echo -e "                         Scales to thousands of nodes in HPC clusters."
echo ""
echo -e "  ${DIM}Source files: demo_python.py | demo_multiprocessing.py |"
echo -e "               demo_cpp.cpp | demo_openmp.cpp | demo_mpi.cpp${RESET}"
echo ""
