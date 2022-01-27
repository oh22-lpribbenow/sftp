# SFTP Server with Azure Blob Storage mount support

## Securely share your files

Easy to use SFTP ([SSH File Transfer Protocol](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol)) server with [OpenSSH](https://en.wikipedia.org/wiki/OpenSSH).

Added support for mounting Azure Blob Storage Containers.

### References

[Forked Repository - atmoz/sftp](https://github.com/atmoz/sftp)

[Parent Image - Ubuntu 20.04](https://hub.docker.com/_/ubuntu)

[Github - Blobfuse](https://github.com/Azure/azure-storage-fuse)

[How to mount Blob storage as a file system with blobfuse](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-how-to-mount-container-linux)

### Requirements

#### Fuse Device

In order to use Blobfuse, you need to pass the fuse device `/dev/fuse` to the container.

*docker run*

```text
--device=/dev/fuse:/dev/fuse
```

*docker-compose*

```text
devices:
  - "/dev/fuse:/dev/fuse"
```

#### SYS_ADMIN capability

For `mount` to work, you need to run the container with the SYS_ADMIN capability turned on.

*docker run*

```text
--cap-add SYS_ADMIN 
```

*docker-compose*

```text
cap_add:
  - "SYS_ADMIN"
```

#### Environment variables

The following environment variables need to be set.

| Name                            | Description                         |
|---------------------------------|-------------------------------------|
| AZURE_STORAGE_ACCOUNT           | Name of the azure storage account   |
| AZURE_STORAGE_ACCESS_KEY        | Access key of the storage account   |
| AZURE_STORAGE_SAS_TOKEN         | SAS token of the storage account    |
| AZURE_STORAGE_ACCOUNT_CONTAINER | Name of the blob storage container  |
| AZURE_MOUNT_POINT               | Blobfuse mount point                |
| SFTP_USERS                      | Username and Password               |

Notes:

- You can either provide `AZURE_STORAGE_ACCESS_KEY` or `AZURE_STORAGE_SAS_TOKEN`. Providing both will result in an error.
- The syntax for `SFTP_USERS` is `username:password`
- The mount point `AZURE_MOUNT_POINT` should be set to a directory inside the user's home directory.
  - Example: If you create a user called `foo` you should set `AZURE_MOUNT_POINT` to `/home/foo/<directory name>`.
  
### Example - docker run

*PowerShell*

```powershell
docker run `
    --cap-add SYS_ADMIN `
    --device=/dev/fuse:/dev/fuse `
    -p 2222:22 `
    -e AZURE_STORAGE_ACCOUNT="<Storage Account Name>" `
    -e AZURE_STORAGE_ACCESS_KEY="<Storage Account Access Key>" `
    -e AZURE_STORAGE_ACCOUNT_CONTAINER="<Storage Account Container>" `
    -e AZURE_MOUNT_POINT="/home/foo/mount" `
    -e SFTP_USERS="foo:password" `
    -d "oh22/sftp-blobfuse:latest"
```

*Bash*

```bash
docker run \
    --cap-add SYS_ADMIN \
    --device=/dev/fuse:/dev/fuse \
    -p 2222:22 \
    -e AZURE_STORAGE_ACCOUNT="<Storage Account Name>" \
    -e AZURE_STORAGE_ACCESS_KEY="<Storage Account Access Key>" \
    -e AZURE_STORAGE_ACCOUNT_CONTAINER="<Storage Account Container>" \
    -e AZURE_MOUNT_POINT="/home/foo/mount" \
    -e SFTP_USERS="foo:password" \
    -d "oh22/sftp-blobfuse:latest"
```

### Example - docker-compose

```text
version: "3.8"

services:
  sftp-blobfuse:
    image: oh22/sftp-blobfuse:latest
    restart: always
    container_name: sftp-blobfuse
    security_opt:
      - apparmor:unconfined
    cap_add:
      - "SYS_ADMIN"
    devices:
      - "/dev/fuse:/dev/fuse"
    ports:
      - "2222:22/tcp"
    environment:
      - AZURE_STORAGE_ACCOUNT="<Storage Account Name>"
      - AZURE_STORAGE_ACCESS_KEY="<Storage Account Access Key>"
      - AZURE_STORAGE_ACCOUNT_CONTAINER="<Storage Account Container>"
      - AZURE_MOUNT_POINT="/home/foo/mount"
      - SFTP_USERS="foo:password"
```
