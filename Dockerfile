FROM ubuntu:22.04

# Set the default shell to bash
SHELL ["/bin/bash", "-c"]

RUN apt-get -qq update && \
    apt-get -qq install -y python3 python3-pip python3-dev pkg-config libssl-dev wget curl ffmpeg

WORKDIR /app
COPY install_onnx_runtime.sh /app/
COPY rp_handler.py /app/
COPY test_5h.mp3 /app/
COPY sample.wav /app/

RUN curl -O <link to pyannote_ai wheel from some external storage>

RUN pwd
RUN ls -lah
RUN pip3 install --no-cache-dir runpod
RUN pip3 install --no-cache-dir pyannote_ai-0.7.0-cp310-abi3-manylinux_2_28_x86_64.whl

RUN source install_onnx_runtime.sh
ENV LD_LIBRARY_PATH=/root/onnxruntime-linux-x64-gpu-1.19.2/lib

CMD ["/bin/bash", "-c", "python3 -u rp_handler.py"]