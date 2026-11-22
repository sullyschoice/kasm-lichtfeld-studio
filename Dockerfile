# Kasm base image tag. Images built on 1.20+ bases do not run on Kasm 1.19 and older.
#   1.19.0-rolling-daily -> Kasm 1.19 and older (default)
#   develop              -> Kasm 1.20 (until a 1.20 rolling base tag is published)
ARG BASE_TAG=1.19.0-rolling-daily

FROM kasmweb/core-ubuntu-noble:${BASE_TAG}
USER root

ENV HOME=/home/kasm-default-profile
ENV STARTUPDIR=/dockerstartup
ENV INST_SCRIPTS=$STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

COPY ./src/lichtfeld/install $INST_SCRIPTS/lichtfeld/
RUN bash $INST_SCRIPTS/lichtfeld/install_lichtfeld_studio.sh  && rm -rf $INST_SCRIPTS/lichtfeld/

COPY ./src/lichtfeld/scripts/custom_startup.sh $STARTUPDIR/custom_startup.sh
RUN chmod +x $STARTUPDIR/custom_startup.sh

COPY ./src/lichtfeld/scripts/launcher.sh  /opt/LichtFeld-Studio/launcher.sh
RUN chmod +x /opt/LichtFeld-Studio/launcher.sh && chown 1000:1000 /opt/LichtFeld-Studio/launcher.sh



RUN apt-get update && apt-get install -y gimp nomacs && cp /usr/share/applications/gimp.desktop $HOME/Desktop/ && chmod +x $HOME/Desktop/gimp.desktop

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME=/home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000