# docker pull colmap/colmap:latest
ARG1=${1:-"/media/ml2_nvme/colorization/slam/alexstreet/Alex's Street Held High 10.10.2024/Cam1/nerfstudio/alexhouse2_full_equi2_level5/colmap"}
docker run --gpus all -w /working -v "$ARG1":/working -it colmap:latest2 bash
