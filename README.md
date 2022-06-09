# AndroidBuildPipeline
Proxmox Packer build template for Jenkins
1:23
1b. install all pre-reqs, Openjdk 11, Jenkins (via their apt repo) and any Android Components
1:24
2. Add terraform script to deploy jenkins to Proxmonster 4
1:26
(my job - get static IP and Mac from OTS)
1:27
3. Configure job pipeline   to clone Repository (use illinoistech-itm) upon new code submission or at an hourly time period
1:27
3b. Part of configuring the service will be to have the gradle project execute and build
1:28
3c.  Add units tests for Android
1:28
3d. 3c. Link Github and github-release tool so that built APKs (that pass tests) will be deployed to the release tab for downloading (sideloading)
