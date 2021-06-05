FROM debian:buster-slim as builder

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt and install packages
RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    #
    # Verify git, process tools, lsb-release (common in install instructions for CLIs) installed
    && apt-get -y install git iproute2 procps apt-transport-https gnupg2 curl lsb-release rsync


    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support for the non-root user
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME

    # Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y curl libcurl4 build-essential zlib1g-dev libssl-dev libxml2
RUN curl -fsS -o /tmp/install.sh https://dlang.org/install.sh

ENV COMPILER_LDC=ldc-1.26.0
ENV COMPILER_DMD=dmd-2.097.0

RUN bash /tmp/install.sh -p /dlang install "${COMPILER_LDC}"
RUN bash /tmp/install.sh -p /dlang install "${COMPILER_DMD}"

#RUN rm /tmp/install.sh \
# && apt-get auto-remove -y curl build-essential \
# && apt-get install -y gcc cmake \
# && rm -rf /var/cache/apt /dlang/${COMPILER}-*/lib32 /dlang/dub-1.0.0/dub.tar.gz

ENV PATH=/dlang/${COMPILER_DMD}/linux/bin64:/dlang/${COMPILER_LDC}/bin:${PATH} \
    LD_LIBRARY_PATH=/dlang/${COMPILER_DMD}/lib:/dlang/${COMPILER_LDC}/lib:${LD_LIBRARY_PATH} \
    LIBRARY_PATH=/dlang/${COMPILER_DMD}/lib:/dlang/${COMPILER_LDC}/lib:${LIBRARY_PATH}

RUN chown -R vscode:vscode /dlang

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
