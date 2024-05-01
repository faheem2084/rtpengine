# First stage: Set up environment and install dependencies
FROM debian:12-slim AS builder

ENV DIST=bookworm \
    REL=11.5

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        net-tools \
        wget \
        gnupg \
        iproute2 \
        sed \
        && rm -rf /var/lib/apt/lists/*

# Second stage: Install rtpengine and cleanup
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        linux-headers-$(dpkg --get-selections | awk '/linux-image/{gsub(/.*linux-image-([^ ]+).*/, "\1",$1); print $1; exit;}') \
        rtpengine \
        && rm -rf /var/lib/apt/lists/*

# Third stage: Install repository keyring and configure repository
RUN wget -O /tmp/rtpengine-dfx-repo-keyring.deb https://rtpengine.dfx.at/latest/pool/main/r/rtpengine-dfx-repo-keyring/rtpengine-dfx-repo-keyring_1.0_all.deb && \
    dpkg -i /tmp/rtpengine-dfx-repo-keyring.deb && \
    rm /tmp/rtpengine-dfx-repo-keyring.deb

RUN echo "deb [signed-by=/usr/share/keyrings/dfx.at-rtpengine-archive-keyring.gpg] https://rtpengine.dfx.at/${REL} ${DIST} main" | tee /etc/apt/sources.list.d/dfx.at-rtpengine.list

# Final stage: Copy configuration and scripts, set permissions, and expose ports
FROM debian:12-slim

COPY --from=builder /etc/ /etc/
COPY ./rtpengine.sh /rtpengine.sh

RUN chmod +x /rtpengine.sh

EXPOSE 22222/udp 22222/tcp

ENTRYPOINT ["/rtpengine.sh"]
