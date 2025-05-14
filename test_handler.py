import time
from rp_handler import handler

# Simulate the RunPod event input
test_event = {
    "input": {
        "url": "test_5h.mp3"
    }
}

if __name__ == "__main__":
    start_time = time.time()

    result = handler(test_event)

    end_time = time.time()
    elapsed_seconds = end_time - start_time

    # Format into hh:mm:ss
    hours, remainder = divmod(int(elapsed_seconds), 3600)
    minutes, seconds = divmod(remainder, 60)

    print("Handler result:")
    print(result)

    print(f"\nExecution time: {hours}h {minutes}m {seconds}s")
