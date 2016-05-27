# https://github.com/tork-a/hakuto/blob/master/tetris_launch/doc/sysadmin.rst
FROM tork/indigo
MAINTAINER Kei Okada kei.okada@gmail.com

USER tork
WORKDIR /home/tork/

# install hakuto package
RUN sudo apt-get install -y ros-indigo-hakuto
RUN sudo rm /bin/sh && sudo ln -s /bin/bash /bin/sh # http://stackoverflow.com/questions/20635472/using-the-run-instruction-in-a-dockerfile-with-source-does-not-work

# setup moon
RUN source /opt/ros/indigo/setup.bash && \
    cd /usr/share/gazebo-2.2/media/skyx/ && \
    sudo cp `rospack find tetris_gazebo`/worlds/earth_from_moon_20071113_kaguya_03l.png . && \
    sudo cp SkyX_Moon.png SkyX_Moon.png.org && \
    sudo ln -sf earth_from_moon_20071113_kaguya_03l.png SkyX_Moon.png

# setup gzweb http://gazebosim.org/gzweb#install-collapse-0
RUN sudo apt-get install -y libjansson-dev nodejs npm libboost-dev imagemagick libtinyxml-dev mercurial cmake build-essential libgts-dev
RUN hg clone https://bitbucket.org/osrf/gzweb && \
    cd ~/gzweb && \
    hg up gzweb_1.2.0

# FIX ME
RUN sudo ln -sf /usr/bin/nodejs /usr/bin/node ## ./deploy.sh requires node command
RUN mkdir -p ~/gzweb/http/client/assets       ## ./webify_models_v2.py requirs

# deply
RUN cd ~/gzweb && \
    ./deploy.sh -m local -c

# We need a small hack to realize lunar surface on gzweb. 
RUN source /opt/ros/indigo/setup.bash && \
    cd ~/gzweb/http/client/assets && \
    cp -r `rospack find tetris_description`/models/tetris/ . && \
    ln -fs `rospack find tetris_gazebo`/models/apollo15_landing_site_1000x1000 .

RUN cd ~/gzweb && \
    ./coarse_meshes.sh 50 http/client/assets/tetris/

# supervisor (https://docs.docker.com/engine/admin/using_supervisord/)
USER root
WORKDIR /root
RUN sudo apt-get install -y openssh-server apache2 supervisor
RUN sudo mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor

# setup joystick
#RUN source /opt/ros/indigo/setup.bash && cp `rospack find tetris_launch`/www/joystick.html /var/www/
RUN wget https://raw.githubusercontent.com/tork-a/hakuto/0.1.6/tetris_launch/www/joystick.html -O /var/www/html/joystick.html
RUN sed -i 's@54.199.141.230@127.0.0.1@'  /var/www/html/joystick.html

RUN sudo apt-get install -y telnet # for debug

# hot fix
## https://github.com/tork-a/hakuto/pull/63
RUN wget https://raw.githubusercontent.com/tork-a/88_tools/master/hotfixer/hot_fix.sh
RUN yes | bash ./hot_fix.sh tork-a/hakuto 57
RUN yes | bash ./hot_fix.sh tork-a/hakuto 58
RUN yes | bash ./hot_fix.sh tork-a/hakuto 63 /opt/ros/indigo/share 1 0
RUN yes | bash ./hot_fix.sh tork-a/hakuto 63 /opt/ros/indigo/share 1 1
RUN yes | bash ./hot_fix.sh tork-a/hakuto 63 /opt/ros/indigo/share 1 3
RUN yes | bash ./hot_fix.sh tork-a/hakuto 63 /opt/ros/indigo/share 1 4

# setup supervisor
# access current status from http://<ip address>:9001/
COPY server.conf   /etc/supervisor/conf.d/server.conf
COPY run_gazebo.conf  /etc/supervisor/conf.d/run_gazebo.conf
COPY run_gzweb.conf   /etc/supervisor/conf.d/run_gzweb.conf
COPY apache2.conf   /etc/supervisor/conf.d/apache2.conf
RUN sudo touch /var/log/run_gazebo.log && sudo chmod a+rw /var/log/run_gazebo.log
RUN sudo touch /var/log/run_gzweb.log && sudo chmod a+rw /var/log/run_gzweb.log

##
RUN /bin/echo -e "#!/bin/bash -x\n\
sleep 5\n\
sed -i \"s@ROS_IP=127.0.0.1@ROS_IP=\`ifconfig eth0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*'\`@\" /etc/supervisor/conf.d/*\n\
/usr/bin/supervisord -n -e debug -c /etc/supervisor/supervisord.conf\n\
" > ./entrypoint.sh && chmod a+x ./entrypoint.sh
CMD ["/root/entrypoint.sh"]
