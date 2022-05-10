# manual steps for creating a TFE airgap installation

## image with docker software
- make sure you have created the ubuntu image with docker you can use 

## network related
- Create a VPC with cidr block 10.233.0.0/16
![](media/20220510091839.png)    
- Create 2 subnets. 1 public subnets and 1 private subnet
patrick-public1-subnet (ip: 10.233.1.0/24 availability zone: eu-north-1a)
patrick-private-subnet (ip: 10.233.11.0/24 availability zone: eu-north-1a)
patrick-private2-subnet (ip: 10.233.11.0/24 availability zone: eu-north-1b)
![](media/20220510092408.png)      
![](media/20220510092442.png)   
- create an internet gateway
![](media/20220510092528.png)    
![](media/20220510092604.png)    
- create routing table for public
 ![](media/20220510092733.png)    
- add the route to the subnet
![](media/20220510092853.png)    
- create a security group that allows ssh, https,replicated admin portal and postgresql 5432 from your own machine
![](media/20220510094855.png)   

## create the instance
- create an instance using the ubuntu image with docker installed
using AMI: ami-039a9e6a0ebccb34b
![](media/20220510100253.png)     
![](media/20220510100334.png)      
![](media/20220510100404.png)      

## create the RDS postgresql instance
- PostgreSQL instance version 12
![](media/20220510101100.png)    
![](media/20220510101136.png)    
![](media/20220510101233.png)    
![](media/20220510101410.png)    
![](media/20220510101442.png)    
![](media/20220510101522.png)    
![](media/20220510101553.png)    
endpoint: patrick-manual-tfe.cvwddldymexr.eu-north-1.rds.amazonaws.com




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
- [x] build network according to the diagram
- [x] Create an AWS RDS PostgreSQL



# To do
- [ ] Create an AWS bucket
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
