FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        base-devel \
        git \
        curl \
        wget \
        openssh \
        gnupg \
        sudo \
        ca-certificates \
        jq \
        go-yq \
        kubectl \
        helm \
        kustomize \
        github-cli \
        nodejs \
        npm \
        python \
        uv \
        ripgrep \
        fzf \
        tmux \
        vim \
        unzip \
        go \
        openssl \
        age \
        direnv \
    && pacman -Scc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/* /tmp/* /var/log/* && \
    useradd -m -G wheel -s /bin/bash vibecode && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

ARG CRANE_VERSION=v0.21.5
RUN curl -fsSL https://opencode.ai/install | sh && \
    mv /root/.opencode/bin/opencode /usr/local/bin/opencode && \
    rm -rf /root/.opencode && \
    curl -fsSL "https://github.com/google/go-containerregistry/releases/download/${CRANE_VERSION}/go-containerregistry_Linux_x86_64.tar.gz" \
    | tar -xz -C /usr/local/bin/ crane && \
    chmod +x /usr/local/bin/crane && \
    rm -rf /tmp/*

WORKDIR /workspace
USER vibecode
