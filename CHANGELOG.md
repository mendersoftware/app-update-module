---
## 1.1.0 - 2024-09-17


### Features


- Oci images deep delta support ([MEN-7033](https://northerntech.atlassian.net/browse/MEN-7033)) ([4c6e975](4c6e975ef6fa832982ded74c34b6ea243c0c2f17))
- Automatic image extraction from docker-compose file  ([9c46cdb](9c46cdba380b8959a7387c47298ad348a88f23a3))




### Testing


- Acceptance tests dind version bind  ([fd28475](fd284757bbda93b1eb49fc1e768fc5a887e92b65))




## 1.0.0 - 2024-01-03


### Bug Fixes


- Bash test framework: cleanup phase, and misc. ([MEN-6366](https://northerntech.atlassian.net/browse/MEN-6366)) ([79a13a9](79a13a9024671c45434a4a1f22f20b5302bfab0f))
  misc fixes:
  * local variable (bt framework)
  * license in config file
  * misspell (in tests)
- Create modules directory if does not exist during install ([MEN-6196](https://northerntech.atlassian.net/browse/MEN-6196)) ([11e827a](11e827a0d41bcedd184923b11e77d511f0424440))
- Pass mode properly to install  ([f9b69e5](f9b69e555bc502e97cc1d3bd5ef76387c82d362e))
- DESTDIR and prefix support in the Makefile  ([2049e62](2049e626eb4719de582b6232a25572a7eb959707))
- Missing default declarations of `k8s_ctr_address` and `k8s_namespace`  ([bd069fe](bd069fe6d4cf0bb44d7bda7315fa1f48945b7dad))




### Documentation


- *(compose)* Add documentation to compose configuration
- Basic readme content  ([5647a62](5647a62affb7d63e13016daadadc36631cee1860))




### Features


- App update module generator generator. ([MEN-6080](https://northerntech.atlassian.net/browse/MEN-6080)) ([31c843c](31c843c04a74912cb9d0d335098cd2f06dedf156))
- App Update Module. ([MEN-6076](https://northerntech.atlassian.net/browse/MEN-6076)) ([4d4c36e](4d4c36ee03aafa19fc8c56d5ad0416c8f18238d8))
- Deep delta support: binary delta between image layers. ([MEN-6081](https://northerntech.atlassian.net/browse/MEN-6081)[MEN-6195](https://northerntech.atlassian.net/browse/MEN-6195)) ([f23d554](f23d5545189d9b320224bdd12bf29263ff46edf1))
  We can significantly reduce the binary delta size by taking
  into account corresponding layers inside the image.
  
  * add support for the generation of delta between layer.tar files
  * modify LOAD operation in the docker-compose orchestrator sub-module
- Bash test framework ([MEN-6082](https://northerntech.atlassian.net/browse/MEN-6082)) ([69951a4](69951a4359333d84f73bbe54650b21337e2c6c58))
- Detecting composition errors and handling ([MEN-6367](https://northerntech.atlassian.net/browse/MEN-6367)) ([3f2a6b6](3f2a6b643cfee01adba355f4b0f4bd20bcfaadbc))
- Configuration for orchestrator sub modules ([MEN-6366](https://northerntech.atlassian.net/browse/MEN-6366)) ([7ed8099](7ed809977f8ae0ef7dd5186b36bdcf6717370479))
- Requirements check. ([MEN-6368](https://northerntech.atlassian.net/browse/MEN-6368)) ([add40cd](add40cd29cd8f78e8b45ee5e67e43fdace9241c3))
- K8s support ([MEN-6194](https://northerntech.atlassian.net/browse/MEN-6194)) ([e1bb1eb](e1bb1ebb27dab628fdf6cb32ac461dd413db55df))
- Cleanup, save, rollback. ([MEN-6077](https://northerntech.atlassian.net/browse/MEN-6077)) ([4538e3c](4538e3c8472d8a9ffd19ac42a3430136b555fb5a))




### Testing


- App-gen smoke test ([MEN-6079](https://northerntech.atlassian.net/browse/MEN-6079)) ([c812e1f](c812e1f2832de0be5bec2d58c6ee9530711cab64))
- Update module ArtifactInstall test. ([MEN-6079](https://northerntech.atlassian.net/browse/MEN-6079)) ([3a3b944](3a3b94410b8a1a30e3bb2c195bd89ba33fe57532))
- Fixing the expected shasums mechanism  ([b6d41da](b6d41daa0baf0eba36af3a5161e9fe5447aaa359))
- Acceptance test. ([MEN-6082](https://northerntech.atlassian.net/browse/MEN-6082)) ([2055a31](2055a3136c8c73f6823875db7f3e08ab81bd8463))
- Verify that no pulling appeared ([MEN-6556](https://northerntech.atlassian.net/browse/MEN-6556)) ([45ba921](45ba9214fd12a8fee74f9cf1750176bd3aadc384))




### Refac


- *(app)* Refactor assert_requirements to only check status code




---
