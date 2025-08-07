FROM multiarch/qemu-user-static:x86_64-aarch64 as qemu
FROM --platform=linux/arm64 ubuntu:latest

COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin

ARG DEBIAN_FRONTEND=noninteractive
ADD VERSION .

ADD idle.sh /idle.sh

RUN apt-get update && apt-get install -y joe

CMD ["bash", "/idle.sh"]

