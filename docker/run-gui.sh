xhost +local:root
ARG1=${1:-"/media/ml2_nvme/colorization/slam/alexstreet/Alex's Street Held High 10.10.2024/Cam1/nerfstudio/alexhouse2_omni"}
export LIBGL_ALWAYS_INDIRECT=1
docker run \
    --net=host \
    --volume="$HOME/.Xauthority:/root/.Xauthority:rw" \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --gpus all \
    --privileged \
    -v "$ARG1":/working \
    -it colmap:latest2 \
    colmap gui
