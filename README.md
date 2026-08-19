# PCOM - BRC - Postgres-Backup

**Base Runtime Component: Postgres Backup** — a PostgreSQL 16 client image for
backup jobs on the Nubo Native Platform (NNP), with kubectl, SSH and mail
tooling (mutt + msmtp).

## Image

Published to Docker Hub on every push to `main`:

```
docker.io/nubons/pcom-brc-postgres-backup:16
docker.io/nubons/pcom-brc-postgres-backup:latest
```

Architecture: `linux/amd64`.

## Included

- **PostgreSQL 16** client tooling (from `postgres:16`)
- **kubectl**, `openssh-client`
- **mutt** + **msmtp** for notification email

## SMTP credentials

Credentials are **not** baked into the image. The shipped
`/root/.config/msmtp/config` is a template (host `in-v3.mailjet.com`, port 587)
with empty user/password. Provide credentials at runtime by mounting a
completed config, for example:

```bash
docker run --rm \
  -v $PWD/msmtp.config:/root/.config/msmtp/config:ro \
  docker.io/nubons/pcom-brc-postgres-backup:16 ...
```

## CI/CD

`.github/workflows/build.yml` is a thin caller for the shared
[`PCOM-CICD`](https://github.com/NNP-Platform-Components-PCOM/PCOM-CICD)
reusable pipeline: build with Buildx, publish to **Docker Hub** with SBOM +
provenance, sign with **cosign keyless** (OIDC), and scan with Trivy and Grype
(results in the **Security** tab). Pull requests build and scan without
publishing.
