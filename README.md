# TFE_airgap
Install TFE on Prod version External Services ( S3 + DB ) with Valid Certificate - AWS install with airgap

# Diagram

![](diagram/diagram-airgap.png)  

# Done
- [x] Create an AWS image to use with correct disk size and Docker software installed
- [x] build network according to the diagram

# Steps to do

- [ ] Create an AWS RDS PostgreSQL
- [ ] Create an AWS bucket
- [ ] Create a valid certificate to use 
- [ ] Get an Airgap software download
- [ ] create an elastic IP to attach to the instance
- [ ] create a virtual machine in a public network with public IP address.
    - [ ] firewall inbound are all from user building external ip
    - [ ] firewall outbound rules
          postgresql rds
          AWS bucket
          user building external ip
- [ ] transfer files to TFE virtual machine
      - airgap software
      - license
      - TLS certificates
      - Download the installer bootstrapper
- [ ] point dns name to public ip address
- [ ] install TFE
- [ ] create a TFE user organization and workspace to test the functionality



# notes and links
[EC2 AWS bucket access](https://aws.amazon.com/premiumsupport/knowledge-center/ec2-instance-access-s3-bucket/)