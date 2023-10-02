ARG CFX_NUM=6736
ARG CFX_VER=6736-7b52ed0fbe8fa0e0ded4a8458d68a8d858afe58d
ARG DATA_VER=0e7ba538339f7c1c26d0e689aa750a336576cf02

FROM alpine as builder
ARG CFX_VER
ARG DATA_VER

WORKDIR /output
USER root
RUN wget -O- http://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${CFX_VER}/fx.tar.xz \
        | tar xJ --strip-components=1 \
            --exclude alpine/dev --exclude alpine/proc \
            --exclude alpine/run --exclude alpine/sys \
 && mkdir -p /output/opt/cfx-server-data \
 && wget -O- http://github.com/citizenfx/cfx-server-data/archive/${DATA_VER}.tar.gz \
        | tar xz --strip-components=1 -C opt/cfx-server-data
RUN apk -p $PWD add tini tzdata

ADD entrypoint usr/bin/entrypoint
RUN chmod +x /output/usr/bin/entrypoint

# ================ #

FROM scratch
ARG CFX_NUM

LABEL org.label-schema.name="FiveM" \
	org.label-schema.version=${CFX_NUM}

COPY --from=builder /output/ /

WORKDIR /config

EXPOSE 30120

CMD [""]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/entrypoint"]
