# Applications updates

Application update module (App Update Module), being the regular Mender Update Module,
contains and implements all the logic behind the deployment of any _installable_
application to a device. As of the moment of writing this the first implementation
takes care of containers-based applications. "Installable" restricts the broad class
of software to a subset that can be deployed using the following set of abstract operations
(listed with examples for a container and python cases):

* LOAD
  * load given element
  * Examples: in case of container-based applications, it 
  is the image import operation, in case of python application it maps
  to `pip install image_being_a_package_name.tar.gz`
* SAVE
  * export given element
  * Examples: in case of containers it means exporting of an image,
  in case of python it copies the currently running package in a form
  understood by pip install.
* LIST
  * lists the building blocks fo the application
  * Examples: for containers it is a list of images (the manifests are listed
  in the EXPORT_MANIFESTS), for python it is the list of packages
  that make the deployment
* DELETE
  * removes constituents of the application
  * Examples: in the case of containers it is the image removal operation, for python based software
  it is the removal of a package `pip install image_being_a_package_name.tar.gz`
* ROLLOUT
  * deploy and start the application
  * Examples: for container-based software it means starting all containers (`kubectl apply`, `docker-compose up`)
  for other it maybe as simple as starting one or more daemons
* ROLLBACK
  * stop any currently running instances of the application and perform ROLLOUT for last working state
* PURGE
  * remove all elements installed with the application
  * Examples: for containers this means calling DELETE on every image, and removal of every config map
  or any other part of the deployment, in case of python application it is a complete removal
  of all installed packages and files
* STOP
  * stop the application
  * Examples: means stopping all the pods/containers running or stopping every process that belong
  to the application
* START
  * start the application
  * Examples: starting pods/containers or starting every process that the application needs
* ALIVE
  * query for the state of the application, see if it is running
  * Examples: in the container case this is the liveness probe, for python applications
  it can be: checking for the existence of a process 
* HEALTHY
  * query for the state of the application, see if it is running and working properly
  * Examples: in the container case this is the readiness probe, for python applications
    it can be: calling user-provided executable to verify that the application works

There are many ways to deploy an application to a device. One of them is: containers.
There is a number of available solutions which allow you to declare what images
constitute your deployment and how to assemble it, these we will call _orchestrators_
and all the declarations needed _manifests_. Among the most popular orchestrators
we have kubernetes and docker compose. We will refer to them as _k8s_ and _docker-compose_,
respectively. In both cases there is a common set of operations and common logic behind
them required for the applications updates to happen. We implement it in the general `app`
update module, and provide the so-called orchestrator sub-module API to delegate
the orchestrator specific implementations to separate modules. We will refer to them as
_sub-module API_ and sub-modules respectively. The API reflects the above operations
from the _installable application_ class.

## Orchestrator sub-module API

The Mender App Update Module reads the given artifact. Using `orchestrator` field it calls
a sub-module by name, for a predefined location:

```shell
 # tree /usr/share/mender/app-modules/v1/
/usr/share/mender/app-modules/v1/
├── docker-compose
└── k8s
...
 # tree /usr/share/mender/modules/v3/
/usr/share/mender/modules/v3/
├── app
├── deb
├── directory
├── docker
├── mender-configure
...
```

The above figure shows the App Update Module (`/usr/share/mender/modules/v3/app`) and sub-modules
located in `/usr/share/mender/app-modules/v1/`. File names in the latter directory
are the orchestrators names.

### API reference
In the following we use the definitions:

* _component_: a part of an application: it can be an image if we are using containers, a package or am executable
* _manifest_: all data needed to deploy an application: it can be a set of kubernetes manifests, docker-compose yaml files, systemd service config files, or custom configuration

#### EXPORT_MANIFEST
Allows to save the currently running application, in the form that allows to call ROLLOUT
with it, and also in the same form that it comes from the upstream (with the arifact).
We need this to perform the ROLLBACK, and it means that we must store the [manifest(s) somewhere](#persistent-storage-and-configuration).

Parameters: 
* `application_name` -- application name
* `output_directory` -- a directory that will contain the manifest

#### SAVE component
Allows saving a component of the application to a file

Parameters: 
* `application_name` -- application name
* `url` -- identifier of a component; for containers it is image URL. May contain the sha256 (or other sum)
  after `@` sign, in which case we check if the sums match. For other orchestrator sub-modules
  it maybe a path, or some other resource handler.
* `path` -- path to an output file

#### LOAD component
Allows loading of a component from a file (e.g.: docker load < image.tar)

Parameters: 
* `application_name` -- application name
* `url` -- identifier of a component; for containers it is image URL. May contain the sha256 (or other sum)
  after `@` sign, in which case we check if the sums match. For other orchestrator sub-modules
  it maybe a path, or some other resource handler.
* `path` -- path to a file holding the data
* `current_url` -- in case of [deep deltas](#deep-binary-delta-of-images) we need the current url to apply them

#### LS_COMPONENTS
Allows listing components of a given application. It will output a list of components,
containing the following data:

* type
  * describes the component type
  * values: `image` for containers, `binary` for raw executables, `deb-package` for Debian package
* url
  * identifies the component
  * values: for containers it is the url of an image, e.g.: `docker.io/library/debian:10`, for others it can be a path to an executable
* additional_data
  * extra data returned by the sub-module

In case an application is a docker composition consisting of two services, the output
can look like the following:

```json
[
  {
    "type": "image",
    "url": "docker.io/library/postgres:15.0"
  },
  {
    "type": "image",
    "url": "docker.io/library/debian:10"
  }
]
```

Parameters:
* `application_name` -- application name

#### DELETE component
Allows removal of given component

Parameters:
* `url` -- identifier of a component; for containers it is image URL. May contain the sha256 (or other sum)
  after `@` sign, in which case we check if the sums match. For other orchestrator sub-modules
  it maybe a path, or some other resource handler.
* `application_name` -- application name

#### ROLLOUT directory
Deploys the given composition

Parameters: 
* `application_name` -- application name
* `source_directory` -- directory containing the manifests. In case of k8s
it is a directory where we run apply, or docker-compose up in case of docker-compose.

#### ROLLBACK
Rolls back the composition to a previous working state

Parameters:
* `application_name` -- application name
* `source_directory` -- directory containing the manifests. In case of k8s
  it is a directory where we run apply, or docker-compose up in case of docker-compose.

#### PURGE 
Removes every component of the application

Parameters:
* `application_name` -- application name

#### STOP
Stops the application

Parameters:
* `application_name` -- application name
* `source_directory` -- directory containing the manifests. In case of k8s
  it is a directory where we run apply, or docker-compose up in case of docker-compose.

#### START
Starts the application

Parameters:
* `application_name` -- application name
* `source_directory` -- directory containing the manifests. In case of k8s
  it is a directory where we run apply, or docker-compose up in case of docker-compose.

#### ALIVE
Returns true if application is live

Parameters:
* `application_name` -- application name

#### HEALTHY
Returns true if application is healthy and ready to use

Parameters:
* `application_name` -- application name

### Additional settings

If we think about {{k8s}} we can imagine elements of an application running in different
namespaces, or requiring some mangling of contexts, or authorization. Instead of creating
a set of non-portable arguments to, e.g., [ROLLBACK](#rollback) call, we can pass
the required data in variables, providing them in environment when we call sub-modules.
When and if needed, we can provide it in the artifact metadata (for non-confidential),
or inside the artifact in an encrypted manner, using device private key, for instance.
All this would require some modifications, but is doable, and maybe considered
for next iterations.

### Persistent storage and configuration

App Update Module needs to store the manifests, both for future reference
([START](#start)/[STOP](#stop) operations) and [ROLLBACK](#rollback).
To this end we introduce a `mender-app.conf` in the default location
`/etc/mender/mender-app.conf`, which will hold all the configuration
for the update module, and as of the moment of writing this holds
one setting:
```
# cat /etc/mender/mender-app.conf
persistent_store=/data/mender-app
```

### App Artifact

#### App Artifact metadata

The Artifact as created by the generator, carries a certain amount of metadata, used to properly
handle all the above calls.

```json
{
  "version": "1.0",
  "platform": "linux/arm/v7",
  "application_name": "myapp0",
  "images": [
    "14ffa9942d15a7c4f94660c4d196e7078f218af612cab9a15025dd3b056ed6bd",
    "a94cd7c7d58f483affd5937853ad4d24caa18cd7c2ec9ef65a9e528dfbc5eb07"
  ],
  "orchestrator": "docker-compose"
}
```

where

* `version` stands for the update module version, it is used 
for compatibility reasons it is filled with the generator,
should not be set by the user, unless she knows what she's doing.
Initial version is 1.0, and it corresponds to /usr/share/mender/app-modules/**v1**/.
If a need comes we can extend the main App Update Module to handle
more exotic installations (e.g.: kernel) by introducing a new version
of both main and sub-modules.
* `platform` provided by user when generating artifacts, denotes
the hardware platform for which the application is targeted.
* `application_name` is the reference name of the application, needed
to distinguish between many possibly running compositions, deployments,
daemons, or standalone executables. Think of the need to save the manifests
in order to start/stop/recreate a docker-composition: you need an identifier
to reference and find something that is running on a device
* `images` is an array of identifiers of binary parts that constitute
the application. In case of container-based deployments it is identical
to the list of sha256sums of images, and in other cases it can hold
an array of sums of packages, or executables. It corresponds to the entries
inside the images.tar.gz archive

#### App Artifact data structure

Complementing the metadata, the core information of needed to perform
the deployment is carried in the data section of the artifact.
Decompressed it has the form:

```bash
data/
|-- 0000.tar.gz
|-- images
|   |-- 14ffa9942d15a7c4f94660c4d196e7078f218af612cab9a15025dd3b056ed6bd
|   |   |-- image.img
|   |   |-- sums-current.txt
|   |   |-- sums-new.txt
|   |   |-- url-current.txt
|   |   `-- url-new.txt
|   `-- a94cd7c7d58f483affd5937853ad4d24caa18cd7c2ec9ef65a9e528dfbc5eb07
|       |-- image.img
|       |-- sums-current.txt
|       |-- sums-new.txt
|       |-- url-current.txt
|       `-- url-new.txt
|-- images.tar.gz
|-- manifests
|   |-- docker-compose-dev.yml
|   `-- docker-compose.yml
`-- manifests.tar.gz
```

where we have unpacked both `0000.tar.gz` and `images.tar.gz`,
`manifests.tar.gz` which the main tar archive one contains.

##### Checksums and URLs

`sums-current.txt` amd `sums-new.txt` files contain the checksums of the components.
In case of container-based applications they reflect the sha256sum of the image currently present
on a device and the new image, respectively. They correspond to `url-current.txt` and `url-new.txt`.
The latter pair is used with the [LOAD](#load-component)/[SAVE](#save-component) calls,
but also to determine if `image.img` contains complete data of the component, or a binary delta.
If the two urls differ, it means that the latter is the case, and the mani App Update Module
will use [SAVE](#save-component) to get the current image, apply delta, and then [LOAD](#load-component)
the new one.

When `image.img` contains complete component data, both `url-current.txt` and `url-new.txt` have
the same content.

The names of directories in `images` folder are always checksums of the new component.

#### Deep binary delta of images

