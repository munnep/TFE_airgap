# manual steps for creating a TFE airgap installation

- make sure you have created the ubuntu image with docker you can use


## Packer ubuntu with docker installation
- go to directory packer_image_docker_installed
```
cd packer_image_docker_installed
```
- initialize packer
```
packer init .
```
- build the image
```
packer build .
```
- Check in AWS console you have the image
![](media/20220510091219.png)  

# done
- [x] Create an AWS image to use with correct disk size and Docker software installed



# To do
- [ ] build network according to the diagram
- [ ] Create an AWS bucket
- [ ] Create an AWS RDS PostgreSQL
- [ ] Create a valid certificate to use 
- [ ] Get an Airgap software download
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
