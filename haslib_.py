import hashlib
import multiprocessing
import time

def hardware_worker(shared_counter):
    # This calls the C/Assembly code that uses your SHA-NI hardware
    h = hashlib.sha256
    data = b"\x00" * 64
    local_count = 0
    while True:
        h(data).digest()
        local_count += 1
        # Batch update to reduce overhead
        if local_count >= 100000:
            with shared_counter.get_lock():
                shared_counter.value += local_count
            local_count = 0

if __name__ == "__main__":
    counter = multiprocessing.Value('Q', 0)
    # Spawn 12 processes for your 12 logical cores
    for _ in range(12):
        multiprocessing.Process(target=hardware_worker, args=(counter,), daemon=True).start()

    last = 0
    while True:
        time.sleep(1)
        curr = counter.value
        print(f"\rHardware-Accelerated Python: {(curr - last) / 1_000_000:.2f} MH/s", end="")
        last = curr