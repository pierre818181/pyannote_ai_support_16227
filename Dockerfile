FROM ubuntu:22.04

# Set the default shell to bash
SHELL ["/bin/bash", "-c"]

# Install system dependencies
RUN apt-get -qq update && \
    apt-get -qq install -y python3 python3-pip python3-dev pkg-config libssl-dev wget curl ffmpeg

# Set working directory
WORKDIR /app

# Copy necessary files into the container
COPY install_onnx_runtime.sh /app/
COPY rp_handler.py /app/
COPY test_handler.py /app/
COPY sample.wav /app/

# Download the wheel package from GitHub Releases
RUN curl -L -o pyannote_ai-0.7.0-cp310-abi3-manylinux_2_28_x86_64.whl \
  https://github.com/anamikarunpod/pyannote_ai_support_16227/releases/download/assets/pyannote_ai-0.7.0-cp310-abi3-manylinux_2_28_x86_64.whl

# Download the big mp3 file
RUN curl -L -o test_5h.mp3 \
  https://github.com/anamikarunpod/pyannote_ai_support_16227/releases/download/mp3_asset/test_5h.mp3


# Install Python packages
RUN pip3 install --no-cache-dir runpod
RUN pip3 install --no-cache-dir /app/pyannote_ai-0.7.0-cp310-abi3-manylinux_2_28_x86_64.whl

# Run the ONNX runtime installation script
RUN source install_onnx_runtime.sh

# Set environment variable for ONNX runtime
ENV LD_LIBRARY_PATH=/root/onnxruntime-linux-x64-gpu-1.19.2/lib

# Run your handler script
CMD ["/bin/bash", "-c", "python3 -u rp_handler.py"]
