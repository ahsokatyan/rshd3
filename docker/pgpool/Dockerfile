FROM debian:bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends pgpool2 postgresql-client ca-certificates \
  && rm -rf /var/lib/apt/lists/*

EXPOSE 9999

CMD ["pgpool", "-n", "-f", "/etc/pgpool2/pgpool.conf", "-a", "/etc/pgpool2/pool_hba.conf"]
