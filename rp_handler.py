import os
import runpod
from pyannote_ai import Pipeline


def handler(event):
    # Extract input data
    path = event["input"].get("url")
    print(f"Creating pipeline object")
    pipeline = Pipeline("pyannote/speaker-diarization", batch_size=8, debug=True)
    print("Diarizing audio file")
    result = pipeline.diarize(path)
    print("Diarization complete")
    print(result)
    return result

# Start the Serverless function when the script is run
if __name__ == '__main__':
    runpod.serverless.start({'handler': handler })