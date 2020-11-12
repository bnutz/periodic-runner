# bnutz/periodic-runner
Periodically run a shell command on host machine on a cron schedule. 

DESCRIPTION:
-----------
This is primarily for host systems that don't have access to their own cron, or where the native cron is unreliable (like QNAP NAS's).

This container uses the pre-configured `crond` schedules in BusyBox to run its jobs (as discovered in [this gist comment](https://gist.github.com/andyshinn/3ae01fa13cb64c9d36e7#gistcomment-2044506))
```
bash-5.0# crontab -l
# do daily/weekly/monthly maintenance
# min   hour    day     month   weekday command
*/15    *       *       *       *       run-parts /etc/periodic/15min
0       *       *       *       *       run-parts /etc/periodic/hourly
0       2       *       *       *       run-parts /etc/periodic/daily
0       3       *       *       6       run-parts /etc/periodic/weekly
0       5       1       *       *       run-parts /etc/periodic/monthly
```

Handy if you just want to run a command at generic timeframes, and not too fussed at exactly *when* the command is run (e.g. for backup operations).


PREREQUISITE:
-------------
- Need to be able to SSH into host server using private-key authentication.


EXAMPLE USAGE:
--------------

```
docker run \
    --name=periodic-runner \
    --hostname=prunner \
    -e HOST_USERNAME="username" \
    -e COMMAND_DAILY="sh run_backup.sh" \
    -e COMMAND_HOURLY="ping www.example.com" \
    -v <path to ssh keys>:/root/.ssh \
    -d \
    bnutz/periodic-runner
```
This will set up a container that will SSH back into its own host system as `username` at the following periods:
- Once a day: Run a backup script located in the host user's home folder
- Once an hour: Ping the website `www.example.com`


DOCKER PARAMETERS:
------------------

| Default Parameters | Function |
| ------------------ | -------- |
| `-e HOST_USERNAME=""`         | Run commands as this user on the host machine. |
| `-e COMMAND_15MIN=""`         | (Optional) Run this command every 15 mins. |
| `-e COMMAND_HOURLY=""`        | (Optional) Run this command every hour.    |
| `-e COMMAND_DAILY=""`         | (Optional) Run this command every day.     |
| `-e COMMAND_WEEKLY=""`        | (Optional) Run this command every week.    |
| `-e COMMAND_MONTHLY=""`       | (Optional) Run this command every month.   |
| `-e REMOTE_ADDRESS=""`        | (Optional) If set, will try to connect and run command on this address instead of the container's own Docker host. |
| `-v /path/to/ssh/keys:/root/.ssh` | Path to ssh keys for container to authenticate into host with. |

- Any unwanted `COMMAND_*` parameter can be left blank to not use that time interval.
- Only one command per interval is supported. To run multiple commands, place them all in a script on the host machine - and have the container execute the script instead.

FIRST RUN:
----------
The first time the container is run, you will need to generate the SSH keys that it will use to authenticate back into the host machine. This will be saved to the mapped SSH keys folder to allow the auth to continue working between container updates.

1. Start the Docker container with your target parameters configured.
2. Run on host to generate the keys inside the container:
   ```bash
   docker exec -it periodic-runner ssh-keygen
   ```
   (Accept the default file location options, leave the passphrase empty)
3. Run on host to link the key inside the container to host:
   ```bash
   docker exec -it periodic-runner ./setup_key.sh
   ```
4. Container should now be setup to trigger the commands on host at the specified intervals
5. To test a command immediately:
   ```bash
   docker exec -it periodic-runner ./run_command.sh "echo hello >> ~/test.txt"
   ls -l ~/
   ```
   The `test.txt` greeting file now should appear in the home folder of your host machine.
