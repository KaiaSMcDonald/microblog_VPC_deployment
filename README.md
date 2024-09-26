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

9. Then, create a start


# Kura Labs Cohort 5- Deployment Workload 4


---



## Provisioning Server Infrastructure:

Welcome to Deployment Workload 4! In Workload 3 We shifted to infrastucture provisioned by us and learned about what goes into deploying an application.  That was hardly an effective system though.  Let's build out our infrastructure a little more.

Be sure to document each step in the process and explain WHY each step is important to the pipeline.

## Instructions

1. Clone this repo to your GitHub account. IMPORTANT: Make sure that the repository name is "microblog_VPC_deployment"

2. In the AWS console, create a custom VPC with one availability zome, a public and a private subnet.  There should be a NAT Gateway in 1 AZ and no VPC endpoints.  DNS hostnames and DNS resolution should be selected.

3. Navigate to subnets and edit the settings of the public subet you created to auto assign public IPv4 addresses.

4. In the Default VPC, create an EC2 t3.medium called "Jenkins" and install Jenkins onto it.  

5. Create an EC2 t3.micro called "Web_Server" In the PUBLIC SUBNET of the Custom VPC, and create a security group with ports 22 and 80 open.  

6. Create an EC2 t3.micro called "Application_Server" in the PRIVATE SUBNET of the Custom VPC,  and create a security group with ports 22 and 5000 open. Make sure you create and save the key pair to your local machine.

7. SSH into the "Jenkins" server and run `ssh-keygen`. Copy the public key that was created and append it into the "authorized_keys" file in the Web Server. 

IMPORTANT: Test the connection by SSH'ing into the 'Web_Server' from the 'Jenkins' server.  This will also add the web server instance to the "list of known hosts"

Question: What does it mean to be a known host?

8. In the Web Server, install NginX and modify the "sites-enabled/default" file so that the "location" section reads as below:
```
location / {
proxy_pass http://<private_IP>:5000;
proxy_set_header Host $host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```
IMPORTANT: Be sure to replace `<private_IP>` with the private IP address of the application server. Run the command `sudo nginx -t` to verify. Restart NginX afterward.

9. Copy the key pair (.pem file) of the "Application_Server" to the "Web_Server".  How you choose to do this is up to you.  (Best practice would be to SCP from your local machine into the Jenkins server but if not, it is possible to nano a new file and copy/paste the contents of the .pem file into it.  MAKE SURE TO INCLUDE EVERYTHING FROM -----BEGIN RSA PRIVATE KEY----- to -----END RSA PRIVATE KEY----- including a new line afterwards if you chose this route)

IMPORTANT: Test the connection by SSH'ing into the "Application_Server" from the "Web_Server".

10. Create scripts.  2 scripts are required for this Workload and outlined below:

a) a "start_app.sh" script that will run on the application server that will set up the server so that has all of the dependencies that the application needs, clone the GH repository, install the application dependencies from the requirements.txt file as well as [gunicorn, pymysql, cryptography], set ENVIRONMENTAL Variables, flask commands, and finally the gunicorn command that will serve the application IN THE BACKGROUND

b) a "setup.sh" script that will run in the "Web_Server" that will SSH into the "Application_Server" to run the "start_app.sh" script.

(HINT: run the scripts with "source" to avoid issues)

Question: What is the difference between running scripts with the source command and running the scripts either by changing the permissions or by using the 'bash' interpreter?

IMPORTANT: Save these scripts in your GitHub Respository in a "scripts" folder.

11. Create a Jenkinsfile that will 'Build' the application, 'Test' the application by running a pytest (you can re-use the test from WL3 or challenge yourself to create a new one), run the OWASP dependency checker, and then "Deploy" the application by SSH'ing into the "Web_Server" to run "setup.sh" (which would then run "start_app.sh").

IMPORTANT/QUESTION/HINT: How do you get the scripts onto their respective servers if they are saved in the GitHub Repo?  Do you SECURE COPY the file from one server to the next in the pipeline? Do you C-opy URL the file first as a setup? How much of this process is manual vs. automated?

Question 2: In WL3, a method of "keeping the process alive" after a Jenkins stage completed was necessary.  Is it in this Workload? Why or why not?

12. Create a MultiBranch Pipeline and run the build. IMPORTANT: Make sure the name of the pipeline is: "workload_4".  Check to see if the application can be accessed from the public IP address of the "Web_Server".

13. If all is well, create an EC2 t3.micro called "Monitoring" with Prometheus and Grafana and configure it so that it can collect metrics on the application server.

14. Document! All projects have documentation so that others can read and understand what was done and how it was done. Create a README.md file in your repository that describes:

	  a. The "PURPOSE" of the Workload,

  	b. The "STEPS" taken (and why each was necessary/important),
    
  	c. A "SYSTEM DESIGN DIAGRAM" that is created in draw.io (IMPORTANT: Save the diagram as "Diagram.jpg" and upload it to the root directory of the GitHub repo.),

	  d. "ISSUES/TROUBLESHOOTING" that may have occured,

  	e. An "OPTIMIZATION" section for that answers the questions: What are the advantages of separating the deployment environment from the production environment?  Does the infrastructure in this workload address these concerns?  Could the infrastructure created in this workload be considered that of a "good system"?  Why or why not?  How would you optimize this infrastructure to address these issues?

    f. A "CONCLUSION" statement as well as any other sections you feel like you want to include.
