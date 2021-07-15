# Packer Templates for Building AWS Cloud Images on Teamcity (modded templates)

## Prerequisite

- AWS client profile with the correct IAM policies attached within TeamCity

- Verify AWSToolsforPowershell is installed and working on the build agent

```powershell
Install-Module -Name AWSPowerShell
```

## Supported Operation Systems

- Ubuntu Server 16.04 LTS
- Ubuntu Server 18.04 LTS
- Ubuntu Server 20.04 LTS

## Usage

Using teacmity you can add the environemnt variables as follows:

env:AWS_PROFILE
env:AWS_REGION
env:AWS_VPC
env:AWS_SUBNET
env:AWS_SECGROUP

Please make sure the build agent has the AWS client profile also (see FAQ)

### Build Amazon Machine Image (AMI)

```powershell
New-AWSCredential -ProfileName

Copy-Item -Path "variables/example.json" -Destination "variables/myprofile.json"

Set-AWSCredential -ProfileName $env:AWS_PROFILE

packer build -var-file variables/myprofile.json templates/aws/ubuntu-server-16-04.json
packer build -var-file variables/myprofile.json templates/aws/ubuntu-server-18-04.json
packer build -var-file variables/myprofile.json templates/aws/ubuntu-server-20-04.json
```

## FAQ
- [Setting up TeamCity for Amazon EC2](https://www.jetbrains.com/help/teamcity/setting-up-teamcity-for-amazon-ec2.html#Preparing+Image+with+Installed+TeamCity+Agent)
- [Setting up TeamCity for vSphere and vCenter](https://www.jetbrains.com/help/teamcity/setting-up-teamcity-for-vmware-vsphere-and-vcenter.html)
- [Amazon Builder FAQ](https://www.packer.io/docs/builders/amazon/#troubleshooting)

