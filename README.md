# Host-Backup-GCS
A simple bash script for backing up your files to Google Cloud Storage.

It basically sends all files under the directories you choose to a bucket and sorts them under a new path structure derived from hostnames and basenames. Since it uses `rsync` functionality of `gsutil`, it actually mirrors your local directories to Google Cloud Storage, more like Unix `rsync` than a blind FTP upload. Especially if you choose to use `-d` parameter while synchronizing, which can be set through the settings file. Check [settings.conf.sample](settings.conf.sample) for the set of parameters I use for my transfers.

Though it can be triggered manually, the script is designed to run as a daily cron job. You can exclude particular directories or file types via regex. Again, please check [settings.conf.sample](settings.conf.sample) for details.

### Usage
- Clone the repo to your server, wherever you like. Preferably at `/root/`.
- Copy [settings.conf.sample](settings.conf.sample) to `settings.conf` at the script directory and edit it with your credentials and preferences.
- Set a daily cron and if everything works, you'll start receiving daily backup reports.

### Requirements
Needs [gsutil Tool](https://cloud.google.com/storage/docs/gsutil) for synchronizing to Google Cloud Storage and a [Postmark](https://postmarkapp.com/) account for sending notification emails. Tested only on High Sierra but should work on Linux as well.

### License
This script is licensed under MIT License, which allows you to freely use or modify it as you see fit, without guaranteeing any results. Please read [LICENSE](LICENSE) file for details.

### To-do's
- Interactively create the settings file.
- Create buckets while creating the settings file.