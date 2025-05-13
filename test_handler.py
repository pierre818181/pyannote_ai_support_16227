from rp_handler import handler

# Simulate the RunPod event input
test_event = {
    "input": {
        "url": "test_5h.mp3"
    }
}

# Call the handler function
if __name__ == "__main__":
    result = handler(test_event)
    print("Handler result:")
    print(result)
