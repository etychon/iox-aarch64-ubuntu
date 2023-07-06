FROM multiarch/qemu-user-static:x86_64-aarch64 as qemu
FROM arm64v8/ubuntu:20.04

COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin

ARG DEBIAN_FRONTEND=noninteractive
ADD VERSION .

ADD idle.sh /idle.sh

RUN apt-get update && apt-get install -y joe

CMD ["bash", "/idle.sh"]

