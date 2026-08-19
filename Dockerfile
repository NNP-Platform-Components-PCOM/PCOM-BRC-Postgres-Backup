# syntax=docker/dockerfile:1.7
#
# PCOM - BRC - Postgres-Backup
# ----------------------------
# PostgreSQL 16 client image for backup jobs on the Nubo Native Platform (NNP):
# adds kubectl, SSH, and mail tooling (mutt + msmtp) so backup jobs can archive
# to a cluster and send notification email.
#
# SMTP credentials are NOT baked into the image. Provide them at runtime by
# mounting a completed /root/.config/msmtp/config (or supplying your own).
#
# Build:
#   docker build -t pcom-brc-postgres-backup:16 .

FROM postgres:16

# --- OCI image metadata (populated by CI, overridable at build time) ---------
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION="16"

LABEL org.opencontainers.image.title="pcom-brc-postgres-backup" \
      org.opencontainers.image.description="PostgreSQL 16 client for NNP backup jobs (kubectl, ssh, mutt/msmtp)." \
      org.opencontainers.image.vendor="Nubo Native Platform" \
      org.opencontainers.image.source="https://github.com/NNP-Platform-Components-PCOM/PCOM-BRC-Postgres-Backup" \
      org.opencontainers.image.url="https://github.com/NNP-Platform-Components-PCOM/PCOM-BRC-Postgres-Backup" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.created="${BUILD_DATE}"

# Install mail tooling, SSH client and kubectl.
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl openssh-client mutt msmtp ca-certificates \
    && curl -fsSLO "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl && mv kubectl /usr/local/bin/kubectl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Ship the msmtp configuration template (no credentials baked in).
RUN mkdir -p /root/.config/msmtp
COPY msmtp.conf /root/.config/msmtp/config
RUN chmod 600 /root/.config/msmtp/config

# Use msmtp as the mailer for mutt.
ENV MAILRC=/root/.muttrc
RUN echo 'set sendmail="/usr/bin/msmtp -a default"' > /root/.muttrc

WORKDIR /root

# Default kubeconfig location.
ENV KUBECONFIG=/root/.kube/config
RUN mkdir -p /root/.kube
