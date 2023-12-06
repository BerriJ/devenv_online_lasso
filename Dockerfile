FROM ubuntu:jammy@sha256:2b7412e6465c3c7fc5bb21d3e6f1917c167358449fecac8176c6e496e5c1f05f

SHELL ["/bin/bash", "-c"]

ENV DISPLAY=:0 \
    TZ=Europe/Berlin

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG DEBIAN_FRONTEND=noninteractive

# Add non root user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -rm -d /home/$USERNAME -s /bin/bash -g root --uid $USER_UID --gid $USER_GID $USERNAME \
    && addgroup $USERNAME staff

# Create folders to mount extensions
RUN mkdir -p /home/$USERNAME/.vscode-server/extensions \
    /home/$USERNAME/.vscode-server-insiders/extensions \
    workspaces \
    && chown -R $USERNAME \
    /home/$USERNAME/.vscode-server \
    /home/$USERNAME/.vscode-server-insiders \
    workspaces

# Ubuntu Setup
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections &&\
    apt-get update &&\
    apt-get -y --no-install-recommends install \
    ca-certificates \
    git \
    build-essential \
    pkg-config \
    cmake \
    ninja-build \
    ccache \
    gfortran \
    # netbase \
    zip \
    unzip \
    curl \
    # xclip \
    zsh \
    # gnupg2 \
    nano \
    gdb \
    # ssh-client \
    # fontconfig \
    # ttf-mscorefonts-installer \
    locales && \
    locale-gen en_US.UTF-8 &&\
    locale-gen de_DE.UTF-8 &&\
    update-locale LANG=en_US.UTF-8 &&\
    git clone --depth=1 https://github.com/sindresorhus/pure.git /home/$USERNAME/.zsh/pure \
    && rm -rf /home/$USERNAME/.zsh/pure/.git \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*

ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

# Install vcpkg C++ dependency manager
RUN git clone --depth=1 https://github.com/Microsoft/vcpkg /usr/local/vcpkg \
    && rm -rf /usr/local/vcpkg/.git \
    && cd /usr/local/vcpkg \
    && ./bootstrap-vcpkg.sh \
    && ./vcpkg integrate install \
    && /usr/local/vcpkg/vcpkg install armadillo \
    && /usr/local/vcpkg/vcpkg install pybind11 \
    && chown --recursive $USERNAME:$USERNAME /usr/local/vcpkg

ENV PATH="/usr/local/vcpkg:${PATH}"

# Install Python CARMA
RUN git clone --depth=1 https://github.com/RUrlus/carma.git /usr/local/carma \
    && rm -rf /usr/local/carma/.git \
    && cd /usr/local/carma \
    && mkdir build \
    && cd build \
    && cmake -DCARMA_INSTALL_LIB=ON .. \
    && cmake --build . --config Release --target install \
    && rm -rf /usr/local/carma

# Install Python
COPY package_lists/python_packages.txt /package_lists/python_packages.txt

RUN apt-get update &&\
    apt-get -y --no-install-recommends install \
    python3-pip  \
    python3-dev && \
    # Python packages
    pip3 install -U --no-cache-dir \
    $(grep -o '^[^#]*' package_lists/python_packages.txt | tr '\n' ' ')  \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*

# Set PATH for user installed python packages
ENV PATH="/home/vscode/.local/bin:${PATH}"

COPY --chown=$USERNAME .misc/.zshrc /home/$USERNAME/.

RUN mkdir /home/$USERNAME/.ccache && chown -R $USERNAME /home/$USERNAME/.ccache
COPY --chown=$USERNAME .misc/ccache.conf /home/$USERNAME/.ccache/.

RUN chown -R $USERNAME /usr/local/lib
RUN chown -R $USERNAME /usr/local/include

# Switch to non-root user
USER $USERNAME

# Start zsh
CMD [ "zsh" ]