FROM openjdk:18-jdk-alpine3.13

# Install python/pip
ENV PYTHONUNBUFFERED=1
RUN apk add python3-dev=3.8.10-r0 --repository=http://dl-cdn.alpinelinux.org/alpine/v3.13/main
RUN apk add --update --no-cache python3 py-pip python3-dev libffi-dev gcc g++ zeromq-dev && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip

# add requirements.txt, written this way to gracefully ignore a missing file
COPY . .
RUN ([ -f requirements.txt ] \
    && pip3 install --no-cache-dir -r requirements.txt --ignore-installed six)

USER root

# Download the kernel release
RUN wget https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip && \
  unzip ijava-1.3.0.zip -d ijava-kernel && \
  python ijava-kernel/install.py --sys-prefix

# Unpack and install the kernel
#RUN unzip ijava-kernel.zip -d ijava-kernel \
#  && cd ijava-kernel \
#  && python install.py --sys-prefix

# Set up the user environment

ENV NB_USER uwais
ENV NB_UID 1000
ENV HOME /home/$NB_USER

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid $NB_UID \
    $NB_USER

COPY . $HOME
RUN chown -R $NB_UID $HOME

USER $NB_USER

# Launch the notebook server
WORKDIR $HOME
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
