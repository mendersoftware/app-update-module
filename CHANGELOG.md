---
## 1.1.1 - 2024-10-16


### Bug Fixes


- Fix stopping of previously installed artifact ([77ac083](https://github.com/mendersoftware/app-update-module/commit/77ac083e073e9df9bb8afa7449ca7d1e2f994899))  by @paulkre
  This commit addresses a bug that was causing installation failures when
  installing a new artifact. The issue stemmed from attempting to stop the
  previously installed artifact by checking for the existence of its "manifests"
  directory. However, if the previous installation failed before creating the
  "manifests" directory, the `STOP` operation would fail. This commit modifies
  the condition for executing the `STOP` operation to now check for the existence
  of the "manifests" directory itself, rather than its parent directory. This
  adjustment ensures that the `STOP` operation is only performed when the
  "manifests" directory actually exists.




## 1.1.0 - 2024-09-17


### Features


- Oci images deep delta support([MEN-7033](https://northerntech.atlassian.net/browse/MEN-7033)) ([4c6e975](https://github.com/mendersoftware/app-update-module/commit/4c6e975ef6fa832982ded74c34b6ea243c0c2f17))  by @merlin-northern
- Automatic image extraction from docker-compose file ([9c46cdb](https://github.com/mendersoftware/app-update-module/commit/9c46cdba380b8959a7387c47298ad348a88f23a3))  by @GoethalsRobbe




## 1.0.0 - 2024-01-03


### Bug Fixes


- Bash test framework: cleanup phase, and misc.([MEN-6366](https://northerntech.atlassian.net/browse/MEN-6366)) ([79a13a9](https://github.com/mendersoftware/app-update-module/commit/79a13a9024671c45434a4a1f22f20b5302bfab0f))  by @merlin-northern
  misc fixes:
  * local variable (bt framework)
  * license in config file
  * misspell (in tests)
- Create modules directory if does not exist during install([MEN-6196](https://northerntech.atlassian.net/browse/MEN-6196)) ([11e827a](https://github.com/mendersoftware/app-update-module/commit/11e827a0d41bcedd184923b11e77d511f0424440))  by @merlin-northern
- Pass mode properly to install ([f9b69e5](https://github.com/mendersoftware/app-update-module/commit/f9b69e555bc502e97cc1d3bd5ef76387c82d362e))  by @merlin-northern
- DESTDIR and prefix support in the Makefile ([2049e62](https://github.com/mendersoftware/app-update-module/commit/2049e626eb4719de582b6232a25572a7eb959707))  by @merlin-northern
- Missing default declarations of `k8s_ctr_address` and `k8s_namespace` ([bd069fe](https://github.com/mendersoftware/app-update-module/commit/bd069fe6d4cf0bb44d7bda7315fa1f48945b7dad))  by @tranchitella




### Documentation


- *(compose)* Add documentation to compose configuration
- Basic readme content ([5647a62](https://github.com/mendersoftware/app-update-module/commit/5647a62affb7d63e13016daadadc36631cee1860))  by @0lmi




### Features


- App update module generator generator.([MEN-6080](https://northerntech.atlassian.net/browse/MEN-6080)) ([31c843c](https://github.com/mendersoftware/app-update-module/commit/31c843c04a74912cb9d0d335098cd2f06dedf156))  by @merlin-northern
- App Update Module.([MEN-6076](https://northerntech.atlassian.net/browse/MEN-6076)) ([4d4c36e](https://github.com/mendersoftware/app-update-module/commit/4d4c36ee03aafa19fc8c56d5ad0416c8f18238d8))  by @merlin-northern
- Deep delta support: binary delta between image layers.([MEN-6081](https://northerntech.atlassian.net/browse/MEN-6081)[MEN-6195](https://northerntech.atlassian.net/browse/MEN-6195)) ([f23d554](https://github.com/mendersoftware/app-update-module/commit/f23d5545189d9b320224bdd12bf29263ff46edf1))  by @merlin-northern
  We can significantly reduce the binary delta size by taking
  into account corresponding layers inside the image.
  
  * add support for the generation of delta between layer.tar files
  * modify LOAD operation in the docker-compose orchestrator sub-module
- Bash test framework([MEN-6082](https://northerntech.atlassian.net/browse/MEN-6082)) ([69951a4](https://github.com/mendersoftware/app-update-module/commit/69951a4359333d84f73bbe54650b21337e2c6c58))  by @merlin-northern
- Detecting composition errors and handling([MEN-6367](https://northerntech.atlassian.net/browse/MEN-6367)) ([3f2a6b6](https://github.com/mendersoftware/app-update-module/commit/3f2a6b643cfee01adba355f4b0f4bd20bcfaadbc))  by @merlin-northern
- Configuration for orchestrator sub modules([MEN-6366](https://northerntech.atlassian.net/browse/MEN-6366)) ([7ed8099](https://github.com/mendersoftware/app-update-module/commit/7ed809977f8ae0ef7dd5186b36bdcf6717370479))  by @merlin-northern
- Requirements check.([MEN-6368](https://northerntech.atlassian.net/browse/MEN-6368)) ([add40cd](https://github.com/mendersoftware/app-update-module/commit/add40cd29cd8f78e8b45ee5e67e43fdace9241c3))  by @merlin-northern
- K8s support([MEN-6194](https://northerntech.atlassian.net/browse/MEN-6194)) ([e1bb1eb](https://github.com/mendersoftware/app-update-module/commit/e1bb1ebb27dab628fdf6cb32ac461dd413db55df))  by @merlin-northern
- Cleanup, save, rollback.([MEN-6077](https://northerntech.atlassian.net/browse/MEN-6077)) ([4538e3c](https://github.com/mendersoftware/app-update-module/commit/4538e3c8472d8a9ffd19ac42a3430136b555fb5a))  by @merlin-northern




### Refac


- *(app)* Refactor assert_requirements to only check status code




---
