#!/bin/sh
# Override user ID lookup to cope with being randomly assigned IDs using
# the -u option to 'docker run'.
USER_ID=$(id -u)
echo "Running entrypoint-script.sh"
if [ x"$USER_ID" != x"0" ]; then
    NSS_WRAPPER_PASSWD=/tmp/passwd.nss_wrapper
    NSS_WRAPPER_GROUP=/etc/group
    cat /etc/passwd | sed -e 's/^docker:/builder:/' > $NSS_WRAPPER_PASSWD
    echo "docker:x:$USER_ID:0:Docker,,,:/home/docker:/bin/bash" >> $NSS_WRAPPER_PASSWD
    export NSS_WRAPPER_PASSWD
    export NSS_WRAPPER_GROUP
    LD_PRELOAD=/usr/lib/libnss_wrapper.so
    export LD_PRELOAD
fi
exec "$@"
