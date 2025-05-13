# duplicity-backup

An opinionated wrapper around [duplicity](https://duplicity.us/) for
automated backups. By default, it will keep up to a year's worth of
backups, performing a daily incremental backup and a full backup once a
month. Currently supports Backblaze B2 and rsync backends.

## Setup

The repository comes with two example profiles, `b2` for Backblaze B2 and
`rsync` for rsync backends.

### Backblaze B2

1. Ensure the `boto3` python package is installed on your machine
2. Create a B2 bucket
3. Create an application key with read/write access to the bucket
4. Enable "list all bucket names" option
5. Configure object lock on the bucket (optional, for ransomware protection)
6. Update `conf.b2.example` with the appropriate parameters
7. Run `install.sh b2`

### rsync

1. Generate a ssh key with `ssh-keygen -N "" -C "duplicity@$(hostname)" -f ssh_id.example`
2. Install the ssh key on the destination machine
3. Update `conf.rsync.example` with the appropriate parameters
4. Run `install.sh rsync`

## Configuration

Configuration lives in `/etc/duplicity/<profile>`. There are three files of interest:

- `conf`: parameters for the `duplicity` program
- `include`: list of paths to include/exclude in the backup
- `ssh_id`: ssh key for connecting to the target (when using rsync)

## License

MIT
