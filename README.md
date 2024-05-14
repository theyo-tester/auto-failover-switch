# Purpose 

A bash script that will check internet connectivity and, if needed, will switch to the "backup" or back to "main" ISP if main is available meanwhile.
It was only tested on a debian system, but should similarly work on other linux based systems.
# Install

1. copy this script on your linux machine (tested on debian only!)
2. Change the first part of the script, where you specify the correct interfaces and IPs used for main and backup.
3. You can call it periodically with crontab. For example, if you want to check the connectivity every 20 seconds, you can achieve this by adding this cron entries (edit with `crontab -e`):

```
* * * * * /home/<user>/failover/failover.sh
* * * * * sleep 20; /home/<user>/failover/failover.sh
* * * * * sleep 40; /home/<user>/failover/failover.sh
```
       
# To Do
- Add possibility to specify a hookup, generically (script or command), for main->backup & backup->main switch-over
- Make configuration external, f.i. with an .env file
- Create a installation script, with a default way of setting things up. 
       
    
