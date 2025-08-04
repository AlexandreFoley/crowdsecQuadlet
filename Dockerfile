

FROM docker.io/crowdsecurity/crowdsec:latest-debian AS AutoRegister

COPY docker_start.sh /

ENTRYPOINT ["/bin/bash", "docker_start.sh"]

