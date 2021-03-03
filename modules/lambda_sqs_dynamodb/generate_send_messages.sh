#! /bin/bash
# Version 2.0

QUEUE=$1

cat << EOF > /home/ubuntu/send_messages.sh
#! /bin/bash
# Version 2.0

python3 send_message.py -q $QUEUE -i 0.1

EOF