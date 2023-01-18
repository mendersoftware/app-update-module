## Description

The Application Update Module: deploy applications to devices.

Example use-cases:

* deploy containers to your devices.

### Specification

|||
| --- | --- |
|Module name| reboot |
|Supports rollback|no|
|Requires restart|no|
|Artifact generation script|yes|
|Full system updater|no|
|Source code|[Update Module](https://github.com/mendersoftware/mender-update-modules/tree/master/reboot/module/reboot), [Artifact Generator](https://github.com/mendersoftware/app-update-module/blob/master/gen/app-gen)|

### Install the Update Module

Download the latest version of this Update Module by running:

```
mkdir -p /usr/share/mender/modules/v3 && wget -P /usr/share/mender/modules/v3 https://raw.githubusercontent.com/mendersoftware/app-update-module/master/src/app && chmod +x /usr/share/mender/modules/v3/app
```

### Create artifact

To download `app-gen`, run the following:

```
wget https://raw.githubusercontent.com/mendersoftware/app-update-module/master/gen/app-gen && chmod +x app-gen
```

Generate Mender Artifacts using the following command:

```
ARTIFACT_NAME="my-update-1.0"
DEVICE_TYPE="my-device-type"
./app-gen --artifact-name ${ARTIFACT_NAME} \
          --device-type ${DEVICE_TYPE} \ 
          --output-path app-001.mender
          --image docker.io/library/debian:11,docker.io/library/debian:latest
          --image docker.io/library/postgres:15.1
          --platform linux/arm/v7
          --orchestrator docker-compose
          --manifests-dir myapp/docker/compose/files                      
 
```

### Maintainer

The author and maintainer of this Update Module is:

- Peter Grzybowski - <peter@northern.tech>

Always include the original author when suggesting code changes to this update module.
