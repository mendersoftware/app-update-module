---
## 1.1.1 - 2025-05-06


### Bug Fixes


- Fix stopping of previously installed artifact
 ([77ac083](https://github.com/mendersoftware/app-update-module/commit/77ac083e073e9df9bb8afa7449ca7d1e2f994899))  by @paulkre


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


- Oci images deep delta support ([MEN-7033](https://northerntech.atlassian.net/browse/MEN-7033)) ([4c6e975](4c6e975ef6fa832982ded74c34b6ea243c0c2f17))
- Automatic image extraction from docker-compose file  ([9c46cdb](9c46cdba380b8959a7387c47298ad348a88f23a3))




### Testing


- Acceptance tests dind version bind  ([fd28475](fd284757bbda93b1eb49fc1e768fc5a887e92b65))




## 1.0.0 - 2024-01-03

* First release of app-update-module

---
