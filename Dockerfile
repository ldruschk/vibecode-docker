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
        hcloud \
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
        argocd \
        sops \
        direnv \
    && pacman -Scc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/* /tmp/* /var/log/* && \
    useradd -m -G wheel -s /bin/bash vibecode && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

ARG CRANE_VERSION=v0.21.5
ARG HETZNER_K3S_VERSION=v2.4.9
RUN curl -fsSL https://opencode.ai/install | sh && \
    mv /root/.opencode/bin/opencode /usr/local/bin/opencode && \
    rm -rf /root/.opencode && \
    sed -i 's/opencode -s/vibecode -s/g' /usr/local/bin/opencode && \
    curl -fsSL "https://github.com/google/go-containerregistry/releases/download/${CRANE_VERSION}/go-containerregistry_Linux_x86_64.tar.gz" \
    | tar -xz -C /usr/local/bin/ crane && \
    chmod +x /usr/local/bin/crane && \
    curl -fsSL "https://github.com/vitobotta/hetzner-k3s/releases/download/${HETZNER_K3S_VERSION}/hetzner-k3s-linux-amd64" \
    -o /usr/local/bin/hetzner-k3s && \
    chmod +x /usr/local/bin/hetzner-k3s && \
    rm -rf /tmp/*

RUN mkdir -p /home/vibecode/.config/sops/age \
    /home/vibecode/.local/share/opencode \
    /home/vibecode/.local/state/opencode \
    /home/vibecode/.ssh && \
    echo 'eval "$(direnv hook bash)"' >> /home/vibecode/.bashrc && \
    chown -R vibecode:vibecode /home/vibecode

WORKDIR /workspace
USER vibecode
