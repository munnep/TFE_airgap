# manual steps for creating a TFE airgap installation



## image with docker software
- make sure you have created the ubuntu image with docker you can use 

## network related
- Create a VPC with cidr block 10.233.0.0/16
![](media/20220510091839.png)    
- Create 2 subnets. 1 public subnets and 1 private subnet
patrick-public1-subnet (ip: 10.233.1.0/24 availability zone: eu-north-1a)
patrick-private-subnet (ip: 10.233.11.0/24 availability zone: eu-north-1a)
patrick-private2-subnet (ip: 10.233.12.0/24 availability zone: eu-north-1b)
![](media/20220510092408.png)      
![](media/20220510092442.png)   
- create an internet gateway
![](media/20220510092528.png)    
![](media/20220510092604.png)    
- create routing table for public
 ![](media/20220510092733.png)    
- add the route to the subnet
![](media/20220510092853.png)    
- create a security group that allows ssh, https,replicated admin portal from your own machine and port 5432 from the TFE environment itself and https from TFE to itself on FQDN
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

# AWS to use
- create a bucket patrick-tfe-manual  
![](media/20220510102447.png)  
![](media/20220510102555.png)  
![](media/20220510102746.png)      

aws s3 cp test.txt s3://patrick-tfe-manual/test.txt

- create policy to access the bucket from the created instance
![](media/20220510103135.png)    
- create a new policy
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "arn:aws:s3:::patrick-tfe-manual",
                "arn:aws:s3:::*/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        }
    ]
}
```
![](media/20220510103614.png)    
![](media/20220510103732.png)    
![](media/20220510103905.png)    
![](media/20220510103917.png)    

- attach the role to the instance
![](media/20220510104028.png)    
- you should now be able to upload a file to the s3 bucket
```
ubuntu@ip-10-233-1-81:~$ aws s3 cp test.txt s3://patrick-tfe-manual/test.txt
upload: ./test.txt to s3://patrick-tfe-manual/test.txt
```

## create the certificate TLS to use
dns: patrick-tfe.bg.hashicorp-success.com

used the following manual to create it: https://github.com/munnep/nginx_create_certificates
```
certbot -d patrick-tfe.bg.hashicorp-success.com --manual --preferred-challenges dns certonly
```
files stored under ../certificates/

## copy installation files
- copy installation files to your ec2 instance
```
scp -r * ubuntu@13.53.70.56:/tmp/

Terraform Enterprise - 610.airgap                                                    100% 1372MB  10.7MB/s   02:07    
chain.pem                                                                            100% 3750   147.2KB/s   00:00    
cert.pem                                                                             100% 1899    73.2KB/s   00:00    
privkey.pem                                                                          100% 1704    68.4KB/s   00:00    
fullchain.pem                                                                        100% 5649   226.1KB/s   00:00    
license.rli                                                                          100%   14KB 519.3KB/s   00:00    
replicated.tar.gz                                                                    100% 1078MB  10.6MB/s   01:42    
```

## change hostname
```
sudo hostnamectl set-hostname patrick-tfe
```

# airgap installer

- make directory /opt/tfe
```
sudo mkdir /opt/tfe
```
- move the replicated installer
```
sudo cmv /tmp/replicated.tar.gz /opt/tfe
```
- untar replicated installer
```
cd /opt/tfe
sudo tar xzf replicated.tar.gz
```
- start the installer
```
ubuntu@patrick-tfe:/opt/tfe$ sudo ./install.sh airgap
Determining local address
The installer was unable to automatically detect the private IP address of this machine.
Please choose one of the following network interfaces:
[0] ens5        10.233.1.81
[1] docker0     172.17.0.1
Enter desired number (0-1): 0
```
after 2 minutes you should see the following
```

Operator installation successful

To continue the installation, visit the following URL in your browser:

  http://<this_server_address>:8800
```
- Continue to the webbrowser: http://patrick-tfe.bg.hashicorp-success.com:8800/
![](media/20220510112618.png)    
![](media/20220510112843.png)    
![](media/20220510112902.png)    
 choose airgapped installation  
 ![](media/20220510112948.png)    
![](media/20220510113053.png)    
![](media/20220510113233.png)    
![](media/20220510114529.png)    
![](media/20220510114548.png)    

- Installation settings  
  hostname: patrick-tfe.bg.hashicorp-success.com  
  encryption password:   
  Production type: External Services  
  Postgresql configuration:   
     username: postgres  
     password:  
     hostname and optional port: patrick-manual-tfe.cvwddldymexr.eu-north-1.rds.amazonaws.com  
     database name: tfe  
  object storage:  
     use instance profile for access  
     bucket: patrick-tfe-manual  
     Region: eu-north-1     
     test authentication should succeed      
Save settings  

- open terraform itself  
![](media/20220510120034.png)  
- create username and password  
![](media/20220510120105.png)      
- create an organization  
![](media/20220510120157.png)      
- create a workspace and run some terraform code which should succeed  
![](media/20220510132050.png)    





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
- [x] Create an AWS bucket
- [x] Create a valid certificate to use 
- [x] Get an Airgap software download
- [x] create a virtual machine in a public network with public IP address.
    - [x] firewall inbound are all from user building external ip
    - [x] firewall outbound rules
          postgresql rds
          AWS bucket
          user building external ip
- [x] transfer files to TFE virtual machine
      - airgap software
      - license
      - TLS certificates
      - Download the installer bootstrapper
- [x] point dns name to public ip address



# To do
- [ ] install TFE
- [ ] create a TFE user organization and workspace to test the functionality
