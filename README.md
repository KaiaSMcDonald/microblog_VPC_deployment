# Microblog_VPC_deployment 

## Purpose 
This project aims to help a social media company deploy its application to servers in a vigorous and secure infrastructure. To accomplish this, a new approach will be introduced, which is to separate the deployment and production environments. Resources such as a VPC and the network protocol known as SSH will be utilized to effectively create this separation.


The steps below showcase what was done to deploy the application using this approach alongside monitoring the resources used.

## Steps 
1. To begin clone the repository to a personal repository on my Github account This step will allow customization and contributions to be made without altering the original repository.
2. Create a custom VPC with one availability zone, a public, and a private subnet.
   This can be accomplished with the following steps:
#### Creating a VPC
-    Select create a VPC
-    Choose VPC only
-    Name the VPC
-    Set the cidr - a example would be 10.0.0./24 which is 256 IP’s
-    Select no IPV6
-    Click  on create VPC
#### Creating a public subnet
-    Select create a subnet
-    Select the VPC created earlier
-    Name Public subnet
-    Select availability zone (an example is US East (N. Virginia) us-east-1a 
-    Set IPV4 subnet cidr block to 10.0.0/25
#### Creating a private subnet 
-    Select add a new subnet
-    Name private subnet
-    Select the same availability zone as the public subnet because they need to be in the same availability zone
-    The IPV4 VPC CIDR block will be 10.0.0/24
-    Set IPV4 subnet CIDR block to be 10.0.0.128/25 ( this is 128 IP's)

Following the creation of the VPC and the subnets will be setting up the route tables for the respective subnets 
This can be accomplished by the following steps:
1. Create a internet gateway which will be included in the route table for the public subnet
   	. Select create internet gateway and give the IGW a name
   	* It is important to attach the IGW to the VPC newly created because without the attachment the IGW will be unable to offers a target in your VPC for internet routable traffic
2.  Select create a route table and name it
3.  Then under the route tab, select edit routes and add the Internet Gateway while also ensuring that the destination is set as 0.0.0/0
        * The 0.0.0/0 ensures there isn't any restrictions in regards to the traffic destination

<br>For the private subnet the NAT Gateway must be created to allow resources within the private subnet to access the internet </br>
<br> Similar to the steps of creating the IGW the NAT Gateway will be created and added to the private subnet route table </br>
<br>However when creating the NAT Gateway a elastic IP must be added because it is static IP address and will guarantee that outbound traffic from your private instances in a VPC  will always appear to come from the same public IP address.</br>

3. Next, Create an Ubuntu EC2 instance that is specifically set to be a t3.medium. On this EC2, Jenkins will be installed using the following steps:
```
$sudo apt update && sudo apt install fontconfig openjdk-17-jre software-properties-common && sudo add-apt-repository ppa:deadsnakes/ppa && sudo apt install python3.7 python3.7-venv
$sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
$echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    $sudo apt-get update
    $sudo apt-get install jenkins
    $sudo systemctl start jenkins
    $sudo systemctl status jenkins

```

4. Then, Create an Ubuntu EC2 t3.micro named 'Web_Server' in the PUBLIC SUBNET of the Custom VPC.
   This speicific EC2 should have security groups that will be:
   ```
   	
   SSH  TCP 22   0.0.0.0/0
   HTTP TCP 80 0.0.0.0/0
   ```

5. Next, Create an EC2 t3.micro called 'Application_Server' in the PRIVATE SUBNET of the Custom VPC.
   This particular EC2 should have security groups that will be:
   ```
   Custom TCP TCP 5000 0.0.0.0/0
   SSH TCP 22 0.0.0.0/0
   ```
6. Following that, Connect to the Jenkins server and run ssh-keygen command. The key that is generated should be appended to the authorized keys
   <br>These steps will successfully accomplish this:</br>
   <br>Run this command cat .ssh/id_ed25519.pub ( this copies the contents of the public key)</br>
   <br>Run this command ssh ubuntu@3.82.192.72  (ssh into web server)</br>
   <br>Once into the web server run this command nano ~/.ssh/authorized_keys ( this will allow you to manually add the key to the authorized keys)</br>
   <br>Lastly it is important that the authorized keys file has the right permissions and this can be guaranteed by using the following command: chmod 600 ~/.ssh/authorized_keys</br>

If this step is done correctly the web server instance will be added to the list of known hosts. This means that the remoter server's identity has been stored locally on the client machine. Therefore allowing a secure connection between the client and the server. 

7. Next, Edit the NginX configuration file at "sites-enabled/default" so that "location" reads as below:
```
   location / {
proxy_pass http://<private_IP>:5000;
proxy_set_header Host $host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```
<br>The part of this code that says private IP should be replaced with the IP address of the application server. </br>

<br>After editing the Nginx configuration we will test it with the following command: sudo nginx -t </br>

8. Next, is copying the key pair (.pem file) of the Application_Server to the Web_Server. This is essential for sshing into the Application Server from the Webserver
After dowloading the key pair onto the computer use the following commands to successfully accomplish this:
<br>cd .ssh</br>
<br>nano WL4keys.pem</br> Cpoy the key pair that was stored on the computer to a .pem file
<br>chmod 400 WL4keys.pem </br> Change the permissions for the .pem file
<br>ssh -i WL4keys.pem ubuntu@10.0.0.108</br> This command will allow you to ssh into the Application Server from the Webserver

9. Then, create a start_app.sh script which will run on the Application. This script holds the commands that will start the application when it runs



<br> This script will automate the set up of the application by guaranteeing that all the dependencies are installed and the application is served using Gunicorn in the background.</br>

10. Next, create a setup.sh script that will run in the Web_Server that will SSH into the Application_Server to run the start_app.sh script.



<br>This script includes variables that are essential to run a command that will allow the web server to ssh into the application server and then run the start_app script that was created.</br>

11. VPC Peering
The purpose of VPC Peering is to allow two VPCs to communicate directly to each other.The VPC peering enables low-latency private communication within AWS's internal network without exposing the data to the public internet. However for this specific project VPC is neccessary for many VPC's created to communicate with each other.

These are steps to successfully do VPC peering 
1. Go to Peering connections
2. Then select create peering  connection
3. Select VPC that was newly created and name the peering connection
4. Then go to route tables and select the public route table created
5. Once that route table is selected edit the route and add the peering connection
6. Then select the route table that is not associated with the VPC created and add the peering connection however the destination should match the CIDR block of the VPC that was created


12. Editing Jenkinsfile

13. Adding a pytest
14. Creating Multibranch Pipeline


## System Design Diagram



## Issues/ Troubleshooting 


One of the issues I experienced was completing each stage of the CI/CD pipeline in Jenkins. On one of the builds I did I recieved a error at the OWASP FS Scan stage. Once I reviewed  the log to identify the error I noticed I didn't install the DP-Check. This also meant that I didn't install the OWASP Dependency Check plug in. The configuration of this plug in will include the DP-Check. Therefore I went through the following steps to make these installations:
1. Install OWASP Dependency Check
   Move to "Manage Jenkins"
   Then  got to Plugins
   Next go to Available plugins 
   Lastly  go to Search and install
2. Install DP-Check
   Go to Manage Jenkins
   Then Tools
   Next Add Dependency-Check
   Then Name: DP-Check >
   Select check install automatically
   Lastly Add Installer: "Install from github.com"

The other issue I had was completing the delpoy stage of the pipeline. I continued to get the error that the identity file isn't accessible. I believe a solution to this problem may be altering or including the absolute path to the file or change the permissions which might be interfering with the accessibility of the file.





<p align="center">I will continue to do my research to find a resolution to the problem.</p>



## Optimization 
There are many advantages of separating the deployment environment from the production environment some of them include:
Risk Mitigation - When deployment environments are separated they can be tested throughly before impacting a live application. This in return will reduce the risk of introduce issues into production. 
Security - Separating environments helps restrict access to sensitive production data this will essentially limit the risk of unauthorized access.

The infrastructure created in this workload can be considered a good system because sensitive data is protected due to the fact the environments are separated. I also believe that this infrastructure can be scalable because different EC2 instances were added to cater to the demand. However if the demand or the need changes the infrastructure can be changed to accomodate that change. These two different highlight the ways this infrastructure can be a good system. 

The way I would optimize this infrastructure is enhance reliability by implementing multi-region deployments for geographical redundancy. Especially since this infrastructure is supporting a application for social media company it is common to have users that are in different areas of the country or world. Therefore catering to more regions would reduce latency and other issues.



## Conclusion




## Sources





