FROM debian:stretch
RUN apt-get update \
  && apt-get install -y openjdk-8-jdk cmake curl wget git unzip python

ARG ZCASHD_USER=zcashd
ARG ZCASHD_UID=2001
ARG ANDROID_COMPILE_SDK=29
ARG ANDROID_BUILD_TOOLS=
ARG ANDROID_SDK_TOOLS=4333796 
ARG ANDROID_NDK_TOOLS=21.1.6352462
RUN useradd --home-dir /srv/$ZCASHD_USER \
            --shell /bin/bash \
            --create-home \
            --uid $ZCASHD_UID\
            $ZCASHD_USER
USER $ZCASHD_USER
WORKDIR /srv/zcashd

RUN wget --quiet --output-document=/tmp/sdk-tools-linux.zip https://dl.google.com/android/repository/sdk-tools-linux-$ANDROID_SDK_TOOLS.zip \
    && unzip /tmp/sdk-tools-linux.zip -d $HOME/.android \
    && mkdir -p $HOME/.android \ 
    && touch $HOME/.android/repositories.cfg \
    && mkdir $HOME/.android/licenses \
    && echo y | $HOME/.android/tools/bin/sdkmanager "ndk;$ANDROID_NDK_TOOLS" >/dev/null \
    && echo y | $HOME/.android/tools/bin/sdkmanager "platform-tools" "platforms;android-$ANDROID_COMPILE_SDK" >/dev/null \
    && echo y | $HOME/.android/tools/bin/sdkmanager "system-images;android-$ANDROID_COMPILE_SDK;default;x86" >/dev/null 

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y \
    && . $HOME/.cargo/env 

ENV ANDROID_HOME=/srv/$ZCASHD_USER/.android
ENV ANDROID_SDK_ROOT=/srv/$ZCASHD_USER/.android
ENV PATH=/srv/$ZCASHD_USER/.cargo/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:~/.android/platform-tools

ENV RUSTUP_HOME=/srv/$ZCASHD_USER/.cargo/bin/
ENV CARGO_HOME=/srv/$ZCASHD_USER/.cargo

WORKDIR /srv/zcashd

RUN . /srv/$ZCASHD_USER/.cargo/env \
    && rustup install stable \
    && rustup default stable \
    && rustup target add armv7-linux-androideabi \
    && rustup target add aarch64-linux-android \
    && rustup target add i686-linux-android \
    && rustup target add x86_64-linux-android
