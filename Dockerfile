# For more information, please refer to https://aka.ms/vscode-docker-python
ARG PYTORCH="1.9.0"
ARG CUDA="11.1"
ARG CUDNN="8"

FROM pytorch/pytorch:${PYTORCH}-cuda${CUDA}-cudnn${CUDNN}-devel

ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0 8.0 8.6"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"
ENV CUDA_HOME=/usr/local/cuda
ENV FORCE_CUDA="1"
ENV WITH_CUDA="1"
ENV NVIDIA_VISIBLE_DEVICES="all"
ENV NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute
ENV QT_X11_NO_MITSHM 1


#FROM datadrone/deeplearn_minimal:cuda-11.1-base

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

ENV CONDA_PREFIX=/opt/conda

## add conda to the path so we can execute it by name
ENV PATH=${CONDA_PREFIX}/bin:${PATH}

RUN conda create --name fiftyone-env --clone base

COPY ./environment.yml /tmp/environment.yml
RUN conda env update  --file /tmp/environment.yml

RUN /opt/conda/bin/conda clean -ya

# #This is now  replaced with conda gdal but kept here temporarily
# # install GDAL - this is needed here as its currebtly unknown how to pass the options in the environment.yml file
# RUN pip install GDAL==$(gdal-config --version) --global-option=build_ext --global-option="-I/usr/include/gdal"

# the specific env
ENV CONDA_DEFAULT_ENV=fiftyone-env

# Configure .bashrc to drop into a conda env and immediately activate our TARGET env
RUN CONDA_DEFAULT_ENV=fiftyone-env conda init && echo 'conda activate "${CONDA_DEFAULT_ENV:-base}"' >>  ~/.bashrc

RUN apt-get update -y && apt-get install -y curl libcurl4

RUN /opt/conda/bin/conda clean -ya

#  PATH into conda environment
ENV PATH=/opt/conda/envs/$CONDA_DEFAULT_ENV/bin:$PATH

# set pythonpath
ENV PYTHONPATH=/workspaces/fiftyone-env:${PYTHONPATH}

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
# RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
# USER appuser
ARG USERNAME=vscode
ARG USER_UID=1001
ARG USER_GID=$USER_UID

# Create a non-root user
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  # [Optional] Add sudo support for the non-root user - this is ok for development dockers only
  && apt-get update \
  && apt-get install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  # Cleanup
  && rm -rf /var/lib/apt/lists/* 

WORKDIR /workspaces/fiftyone-examples

# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
CMD ["python", "./src/startserver.py"]
