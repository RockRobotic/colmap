# build the docker image from the Dockerfile in the current directory
docker build -t="colmap:latest2" --build-arg CUDA_ARCHITECTURES=86 --progress=plain -f colmap/docker/Dockerfile . && \
# In some cases, you may have to explicitly specify the compute architecture:
#   docker build -t="colmap:latest" --build-arg CUDA_ARCHITECTURES=75 .
docker container create --name colmap_cache_container colmap:latest2  && \
docker cp colmap_cache_container:/colmap/build_docker/ colmap_build_docker/  && \
docker rm colmap_cache_container
