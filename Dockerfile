FROM debian:12-slim

ENV DIST=bookworm
ENV REL=11.5

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        net-tools \
        sngrep \
        telnet \
        wget \
        gnupg \
        iproute2 \
        sed \
        linux-headers-$(dpkg --get-selections | awk '/linux-image/{gsub(/.*linux-image-([^ ]+).*/, "\1",$1); print $1; exit;}') \
        rtpengine && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/rtpengine-dfx-repo-keyring.deb https://rtpengine.dfx.at/latest/pool/main/r/rtpengine-dfx-repo-keyring/rtpengine-dfx-repo-keyring_1.0_all.deb && \
    dpkg -i /tmp/rtpengine-dfx-repo-keyring.deb && \
    rm /tmp/rtpengine-dfx-repo-keyring.deb

RUN echo "deb [signed-by=/usr/share/keyrings/dfx.at-rtpengine-archive-keyring.gpg] https://rtpengine.dfx.at/${REL} ${DIST} main" | tee /etc/apt/sources.list.d/dfx.at-rtpengine.list

COPY ./rtpengine.conf /etc/
COPY ./rtpengine.sh /rtpengine.sh
RUN chmod +x /rtpengine.sh

EXPOSE 22222/udp 22222/tcp

ENTRYPOINT ["/rtpengine.sh"]
