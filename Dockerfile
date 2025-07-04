#Dockerfile
#Requirements on host(Linux): sysctl -w net.ipv4.ip_forward=1

#Check "Testing Tibero on your own" Blog post for sysctl config and limits.

# License file requires hostname "tibero7" from now on.
#docker run -h tibero7 -it dimensigon/tibero
#docker run -h tibero7 -dt dimensigon/tibero

### Base + Prereqs

FROM rockylinux:9.3

LABEL maintainer="glorial@naver.com"

COPY prepare.bash /root/prepare.bash

COPY bash_profile_tibero /home/tibero/.bash_profile

COPY --chown=tibero:dba --chmod=755 start.bash /home/tibero/

COPY --chown=tibero:dba ./tibero7/*.gza* /home/tibero/

COPY --chown=tibero:dba ./tibero7/license.xml /home/tibero/tibero7/license/

COPY --chown=tibero:dba ./tibero7/createDatabase.sql /home/tibero/tibero7/

COPY --chown=tibero:dba ./tibero7/createDemoUser.sql /home/tibero/tibero7/

RUN bash /root/prepare.bash

ENV DISPLAY=:10.0

WORKDIR /home/tibero

RUN cat tibero.tar.gz* | tar zxvf -

RUN rm tibero.tar.gz*

RUN chown -R tibero:dba /home/tibero

ENTRYPOINT su - tibero -c 'echo $PATH && bash /home/tibero/start.bash'

EXPOSE 8629-8649

