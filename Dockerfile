FROM alpine:3

RUN apk add --no-cache bash openssh-client

SHELL ["/bin/bash", "-c"]

WORKDIR /root

VOLUME /root/.ssh

ENV HOST_USERNAME=""
ENV REMOTE_ADDRESS=""

# Filenames of script to run at the given interval (located on host, not in container)
ENV COMMAND_15MIN=""
ENV COMMAND_HOURLY=""
ENV COMMAND_DAILY=""
ENV COMMAND_WEEKLY=""
ENV COMMAND_MONTHLY=""

# Reference https://gist.github.com/andyshinn/3ae01fa13cb64c9d36e7#gistcomment-2044506
COPY run_15 /etc/periodic/15min/run_15
COPY run_hourly /etc/periodic/hourly/run_hourly
COPY run_daily /etc/periodic/daily/run_daily
COPY run_weekly /etc/periodic/weekly/run_weekly
COPY run_monthly /etc/periodic/monthly/run_monthly

RUN chmod +x /etc/periodic/15min/run_15
RUN chmod +x /etc/periodic/hourly/run_hourly
RUN chmod +x /etc/periodic/daily/run_daily
RUN chmod +x /etc/periodic/weekly/run_weekly
RUN chmod +x /etc/periodic/monthly/run_monthly

COPY setup_key.sh .
RUN chmod +x setup_key.sh

COPY run_command.sh .
RUN chmod +x run_command.sh

# # Reference: https://unix.stackexchange.com/q/412805
# CMD crond -l 2 -f

# For debugging
CMD tail -f /dev/null