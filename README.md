# duplicity-backup

An opinionated wrapper around [duplicity](https://duplicity.us/) for
automated backups. By default, it will keep up to a year's worth of
backups, performing a daily incremental backup and a full backup once a
month. Currently supports AWS S3, Backblaze B2, and rsync backends.

## Setup

The repository comes with three example profiles: `s3` for AWS S3,
`b2` for Backblaze B2, and `rsync` for rsync backends.

### AWS S3/Backblaze B2

1. Ensure the `boto3` (for S3) or `b2sdk` (for B2) python package is installed
2. Create a bucket
3. Create an application key with read/write access to the bucket
4. Configure object lock on the bucket (optional, for ransomware protection)
5. Update `conf.{s3,b2}.example` with the appropriate parameters
6. Run `sudo ./install.sh {s3,b2}`

### rsync

1. Generate a ssh key with `ssh-keygen -N "" -C "duplicity@$(hostname)" -f ssh_id.example`
2. Install the ssh key on the destination machine
3. Update `conf.rsync.example` with the appropriate parameters
4. Run `sudo ./install.sh rsync`

## Configuration

Configuration lives in `/etc/duplicity/<profile>`. There are three files of interest:

- `conf`: parameters for the `duplicity` program
- `include`: list of paths to include/exclude in the backup
- `ssh_id`: ssh key for connecting to the target (when using rsync)

## Updating

To update `duplicity-backup`, just run `sudo ./install.sh` again without
passing a profile name. This will re-install just the script.

## License

MIT
