ARG GRAALVM_VERSION=latest

FROM oracle/graalvm-ce:${GRAALVM_VERSION} as graalvm

LABEL maintainer "rinx <rintaro.okamura@gmail.com>"

RUN gu install native-image
RUN curl -o /usr/bin/lein https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein \
    && chmod a+x /usr/bin/lein

RUN mkdir -p /substrate
WORKDIR /substrate

COPY project.clj project.clj

RUN lein deps

COPY src src

RUN lein uberjar

COPY native-config native-config

COPY Makefile Makefile

RUN make

FROM ubuntu:latest

LABEL maintainer "rinx <rintaro.okamura@gmail.com>"

COPY --from=graalvm /substrate/server /server

CMD ["/server"]
