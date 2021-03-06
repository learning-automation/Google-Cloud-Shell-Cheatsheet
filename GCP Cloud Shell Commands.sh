###################################
### Google Cloud Shell Basics   ###
###################################

#Authenticate yourself in Cloud Shell (or change to another user)
gcloud auth login

##it will give you a URL to go to to authenticate (example shown below)
https://accounts.google.com/o/oauth2/auth?redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&prompt=select_account&response_type=code&client_id=32555940559.apps.googleusercontent.com&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fappengine.admin+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcompute+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Faccounts.reauth&access_type=offline

#and then give you a token to put back in Cloud Shell prompt (example shown below)
4/8wBRLfFq4wcqpvHMwrfn2MBG9O9f64M7fSntCVyXoWdYtLwlpYBBLH8

#Set Default Project
gcloud config set project learningautomation-io-test

#Alternatively you could set Project ID using the built in DEVSHELL_PROJECT_ID environment variable to set to your current CloudShell project
gcloud config set project $DEVSHELL_PROJECT_ID

#Get current GCloud config
gcloud config list

#Get all GCloud Configs, even ones that arent set yet
gcloud config list --all

#Get Project ID of current project
gcloud config get-value project

#Display list of CE Machine Types
gcloud compute machine-types list

#Get current default Region/Zone
gcloud config get-value compute/region
gcloud config get-value compute/zone

#Set default Region/Zone
gcloud config set compute/region
gcloud config set compute/zone

#Get listing of current gcloud config settings like project ID
gcloud config list
gcloud config list | grep project  (for example to get just the current project ID)

#Set current Project ID as an Environment variable
export PROJECTID="$(gcloud config get-value project -q)"


#Adding your zone to MY_ZONE Environment variable for ease of use
export MY_ZONE=us-central1-a

## List GCP Compute Regions
gcloud compute regions list

asia-southeast1          0/24  0/4096    0/8        0/8                 UP
australia-southeast1     0/24  0/4096    0/8        0/8                 UP
...
us-east4                 0/24  0/4096    0/8        0/8                 UP
us-west1                 0/24  0/4096    0/8        0/8                 UP
us-west2                 0/24  0/4096    0/8        0/8                 UP

## Setting Env variables in Cloud Shell
INFRACLASS_REGION=us-central1
echo $INFRACLASS_REGION

INFRACLASS_PROJECT_ID=[YOUR_PROJECT_ID]


## Save this to a config file
mkdir infraclass
touch infraclass/config
echo INFRACLASS_REGION=$INFRACLASS_REGION >> ~/infraclass/config
echo INFRACLASS_PROJECT_ID=$INFRACLASS_PROJECT_ID >> ~/infraclass/config


## use the persistent config file to set ENV variables
source ~/infraclass/config
echo $INFRACLASS_PROJECT_ID


## Save source command to Cloud Shell .profile (acts like .bashrc file)
nano .profile
Add souce command to bottom of file, save and restart ur Cloud Shell

## Resetting Cloud Shell to default stat (Important: This will permanently delete all files in your home directory)
#To restore your Cloud Shell home directory to a clean state first check for personal files in the home directory:
#Remove all files from your home directory (save them somewhere else first if needed):

ls -a $HOME
sudo rm -rf $HOME

#In the Cloud Shell menu, click the three dots menu icon, then click Restart Cloud Shell. Click Restart Cloud Shell in the confirmation dialog. A new VM will be provisioned and the home directory will be restored to its default state.


## Referencing values in Cloud Shell commands
User Account = $(gcloud config get-value account)
Project ID   = $(gcloud config get-value project -q)   or $(gcloud info --format='value(config.project)')
User Email   =$(gcloud auth list --limit=1 2>/dev/null | grep '@' | awk '{print $2}')
Service Account Email = export SA_EMAIL=$(gcloud iam service-accounts list --filter="displayName:spinnaker-storage-account" --format='value(email)')

#### Access GCP Console for a particular project: (for sharing with other team members after they have been granted access to that project in IAM)
https://console.cloud.google.com/compute/instances?project=yourprojectname


###########################
####    IAM & Admin    ####
###########################

#### Create a Service Account
gcloud iam service-accounts create  spinnaker-storage-account \
    --display-name spinnaker-storage-account

#### Bind a service account to a particular access policy
gcloud projects add-iam-policy-binding \
    $PROJECT --role roles/storage.admin --member serviceAccount:$SA_EMAIL

#### Create and download service account key
gcloud iam service-accounts keys create spinnaker-sa.json \
     --iam-account $SA_EMAIL


#############################
### Cloud Storage Buckets ###
#############################

#### Creating a Bucket
gsutil mb gs://[bucket-name]

#### Displaying the contents of a Storage Bucket
gsutil ls gs://[bucket-name]

#### Displaying more details for an object in the bucket
gsutil ls -l gs://[bucket-name]/file.txt

#### Viewing the contents of a file in a Storage Bucket
gsutil cat gs://super-cool-bucket/sample.txt

#### Copying a file from Cloud Shell to Storage Bucket
gsutil cp my-file.txt gs://[bucket-name]

#### Copy a file from Storage Bucket to server/cloud shell
gsutil cp gs://[bucket-name]/sample.txt .

#### To get access control list for a file in Cloud Bucket
gsutil acl get gs://$BUCKET_NAME_1/setup.html  > acl.txt
cat acl.txt

#### Set ACL for file to private and print out the acl list again
gsutil acl set private gs://$BUCKET_NAME_1/setup.html
gsutil acl get gs://$BUCKET_NAME_1/setup.html  > acl2.txt
cat acl2.txt

#### To make a file publicly readable and check acl again to verify
gsutil acl ch -u AllUsers:R gs://$BUCKET_NAME_1/setup.html
gsutil acl get gs://$BUCKET_NAME_1/setup.html  > acl3.txt
cat acl3.txt

#### Generate a Customer Supplied Encryption Key (CSEK)
python -c 'import base64; import os; print(base64.encodestring(os.urandom(32)))'

#### Will generate a base64 encoded key like this
Y0EpmDNdr9o5EHg9KsaR4Y6WWytJKy0bQG5b7S9tmVE=

#### then put the above key in the .boto file like so
encryption_key=Y0EpmDNdr9o5EHg9KsaR4Y6WWytJKy0bQG5b7S9tmVE=

#### Now any files that are upload using gsutil will be encrypted bya CSEK you created instead of Google Provided keys

#### Generate a new .boto config file for gsutil
gsutil config -n

#### Get details of gsutil version and config including location of .boto file
gsutil version -l

#### To rotate Encryption keys generate a new one with the python command above and place old key in decription_key1 value in .boto file
#### Place new encryption key in the encryption_key value and then rewrite the required files in the Storage bucket
gsutil rewrite -k gs://$BUCKET_NAME_1/testfile.html

### Any file trying to be copyed over with out proper decryption keys will give this error
No decryption key matches object gs://really-cool-test-bucket/testfile.html.


#### View Current Lifecycle policy for Storage Bucket
gsutil lifecycle get gs://$BUCKET_NAME_1

#### Example Lifecyle policy JSON file
{
  "rule":
  [
    {
      "action": {"type": "Delete"},
      "condition": {"age": 61}
    }
  ]
}

#### Set new Lifecycle policy via a JSON file
gsutil lifecycle set lifecycle.json gs://$BUCKET_NAME_1

#### Get versioning policy for Storage Bucket (Suspended policy means that it is not enabled)
gsutil versioning get gs://$BUCKET_NAME_1

#### Enable versioning on Storage Bucket
gsutil versioning set on gs://$BUCKET_NAME_1

#### Copy a file to Storage Bucket with versioning option
gsutil cp -v testfile.html gs://$BUCKET_NAME_1

#### List all versions of a file
gsutil ls -a gs://$BUCKET_NAME_1/testfile.html

gs://really-cool-test-bucket/testfile.html#1551838445092743  <--- this is the oldest version
gs://really-cool-test-bucket/testfile.html#1551839990886092
gs://really-cool-test-bucket/testfile.html#1551840022565501  

#### To enable directory sync with folder on VM to Storage Bucket
gsutil rsync -r ./folder gs://$BUCKET_NAME_1/folder

#################################
###  VPC/Firewall Netwokring  ###
#################################

#List of forwarding rules
gcloud compute forwarding-rules list

# Creating Automode network and associated Firewall rules
gcloud compute networks create learnauto --description="Learn about auto-mode networks" --subnet-mode=auto
gcloud compute firewall-rules create learnauto-allow-ssh --description="Allows TCP connections from any source to any instance on the network using port 22." --direction=INGRESS --priority=65534 --network=learnauto --action=ALLOW --rules=tcp:22 --source-ranges=0.0.0.0/0
gcloud compute firewall-rules create learnauto-allow-rdp --description="Allows RDP connections from any source to any instance on the network using port 3389." --direction=INGRESS --priority=65534 --network=learnauto --action=ALLOW --rules=tcp:3389 --source-ranges=0.0.0.0/0
gcloud compute firewall-rules create learnauto-allow-icmp --description="Allows ICMP connections from any source to any instance on the network." --direction=INGRESS --priority=65534 --network=learnauto --action=ALLOW --rules=icmp --source-ranges=0.0.0.0/0
gcloud compute firewall-rules create learnauto-allow-internal --description="Allows connections from any source in the network IP range to any instance on the network using all protocols." --direction=INGRESS --priority=65534 --network=learnauto --action=ALLOW --rules=all --source-ranges=10.128.0.0/9

#### List Firewall Rules for given network
gcloud compute firewall-rules list \
--filter="network:mynetwork"

gcloud compute firewall-rules list \
--filter="network:mynetwork AND name=mynetwork-deny-icmp"

#### Create Custom VPN Network
gcloud compute networks create network-a --subnet-mode custom

#### create a subnet and alias ip range
gcloud compute networks subnets create subnet-a \
    --network network-a \
    --range 10.128.0.0/16 \
    --secondary-range container-range=172.16.0.0/20

#### List subnets in a given network
gcloud compute networks subnets list --network network-a

# Create VMs with alias
gcloud compute instances create vm1 [...] \
    --network-interface subnet=subnet-a,aliases=container-range:172.16.0.0/24
gcloud compute instances create vm2 [...] \
    --network-interface subnet=subnet-a,aliases=container-range:172.16.1.0/24

# Expand a subnet
gcloud compute networks subnets \
expand-ip-range new-useast  \
--prefix-length 23 \
--region us-east1

# Example Firewall rule to allow connections on port 80 for webtraffic (will default to ingress and 0.0.0.0/0)
gcloud compute firewall-rules create www-firewall --allow tcp:80

# Example Firewall rule to allow egress traffic on port 80
gcloud compute firewall-rules create egress-firewall --direction egress --allow tcp:80

#### Create firewall rule to allow external traffic on port 80 and 443 (eg. for nginx)
gcloud compute firewall-rules create nginx-firewall \
 --allow tcp:80,tcp:443 \
 --target-tags nginxstack-tcp-80,nginxstack-tcp-443
 
#### Create Network Load Balancer targeting an Instance group
gcloud compute forwarding-rules create nginx-lb \
         --region us-central1 \
         --ports=80 \
         --target-pool nginx-pool
 
#### Show forwarding rules
gcloud compute forwarding-rules list

#### Delete a subnet
gcloud compute networks subnets delete subnet-asia-east --region asia-east1

#### Delete a Network (note you have to delete all subnets in that Network before deleting the Network)
gcloud compute networks delete network-a

#### More info on GCP Firewall rules
https://cloud.google.com/compute/docs/vpc/firewalls


#### Create NAT Gateway
gcloud compute routes create nat-route --network private-network \
--destination-range 0.0.0.0/0 --next-hop-instance private-bastion-host \
--next-hop-instance-zone us-central1-c --tags nat-me --priority 800

#### Then log into Bastion Host VM and activate IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

#### Create External IP for NAT Gateway
gcloud compute addresses create nat-1 --region us-east1

nat_1_ip=$(gcloud compute addresses describe nat-1 \
    --region us-east1 \
    --format='value(address)')

printf "The public NAT ip-address is :
nat-1: $nat_1_ip\n"

########################################################
####    Create Network TCP External Load Balancer   ####
########################################################

#### First create your Compute instances that are going to be handling the requests
#### Then create a a Health Check in Compute Engine on whatever specific port traffic is going to be directing too
gcloud compute health-checks create tcp webserver-health --port 80

#### Now create a target pool for the Load Balancer and add VM Instances to target pool
gcloud compute target-pools create extloadbalancer \
    --region $MY_REGION --http-health-check webserver-health

gcloud compute target-pools add-instances extloadbalancer \
    --instances webserver1,webserver2,webserver3 \
     --instances-zone=$MY_ZONE1

#### List Reserved Static IP Addresses
gcloud compute addresses list

#### Create forwarding rule for HTTP Load Balancer
gcloud compute forwarding-rules create webserver-rule \
    --region $MY_REGION --ports 80 \
    --address $STATIC_EXTERNAL_IP --target-pool extloadbalancer

#### The Load Balancer can be seen in the GCP console under Network services > Load Balancing
#### The reserved Static IP can be seen in VPC network > External IP addresses

#### Create Health check for Instance Groups
gcloud compute health-checks create tcp my-tcp-health-check \
    --port 80

#### Create Backend group
gcloud compute backend-services create my-int-lb \
    --load-balancing-scheme internal \
    --region $MY_REGION \
    --health-checks my-tcp-health-check \
    --protocol tcp

#### Add instance group 1 & 2 to Backend
gcloud compute backend-services add-backend my-int-lb \
    --instance-group ig1 \
    --instance-group-zone $MY_ZONE1 \
    --region $MY_REGION

gcloud compute backend-services add-backend my-int-lb \
    --instance-group ig2 \
    --instance-group-zone $MY_ZONE2 \
    --region $MY_REGION

#### Create a forwarding rule
gcloud compute forwarding-rules create my-int-lb-forwarding-rule \
    --load-balancing-scheme internal \
    --ports 80 \
    --network default \
    --subnet default \
    --region $MY_REGION \
    --backend-service my-int-lb

#### Create Firewall rule to allow for web traffic and health checks
gcloud compute firewall-rules create allow-internal-lb \
    --network default \
    --source-ranges 0.0.0.0/0 \
    --target-tags int-lb \
    --allow tcp:80,tcp:443

gcloud compute firewall-rules create allow-health-check \
    --network default \
    --source-ranges 130.211.0.0/22,35.191.0.0/16 \
    --target-tags int-lb \
    --allow tcp

###############################################################
####    Create Internal Load Balancer for Instance Groups   ####
###############################################################


###################################################
####     Create VPN for VPC Network Peering    ####
###################################################

#### Need to create a VPN gateway on each VPC network in order to peer networks together
gcloud compute target-vpn-gateways \
create vpn-1 \
--network vpn-network-1  \
--region us-east1

gcloud compute target-vpn-gateways \
create vpn-2 \
--network vpn-network-2  \
--region europe-west1

#### Reserve static IP address for VPN
gcloud compute addresses create --region us-east1 vpn-1-static-ip
gcloud compute addresses create --region europe-west1 vpn-2-static-ip

#### View static IP address for VPN
gcloud compute addresses list

NAME             ADDRESS/RANGE  TYPE  PURPOSE  NETWORK  REGION    SUBNET  STATUS
vpn-1-static-ip  34.73.244.192                          us-east1          RESERVED
vpn-2-static-ip  34.76.176.141                          europe-west1      RESERVED

#### Create ESP Firewall rule for VPN Gateway
gcloud compute \
forwarding-rules create vpn-1-esp \
--region us-east1  \
--ip-protocol ESP  \
--address $STATIC_IP_VPN_1 \
--target-vpn-gateway vpn-1

gcloud compute \
forwarding-rules create vpn-2-esp \
--region europe-west1  \
--ip-protocol ESP  \
--address $STATIC_IP_VPN_2 \
--target-vpn-gateway vpn-2

#### Create UDP500 Firewall rule for VPN Gateway
gcloud compute \
forwarding-rules create vpn-1-udp500  \
--region us-east1 \
--ip-protocol UDP \
--ports 500 \
--address $STATIC_IP_VPN_1 \
--target-vpn-gateway vpn-1

gcloud compute \
forwarding-rules create vpn-2-udp500  \
--region europe-west1 \
--ip-protocol UDP \
--ports 500 \
--address $STATIC_IP_VPN_2 \
--target-vpn-gateway vpn-2

#### Create UDP4500 Firewall Rule for VPN Gateway
gcloud compute \
forwarding-rules create vpn-1-udp4500  \
--region us-east1 \
--ip-protocol UDP --ports 4500 \
--address $STATIC_IP_VPN_1 \
--target-vpn-gateway vpn-1

gcloud compute \
forwarding-rules create vpn-2-udp4500  \
--region europe-west1 \
--ip-protocol UDP --ports 4500 \
--address $STATIC_IP_VPN_2 \
--target-vpn-gateway vpn-2

#### List VPN Gateways
gcloud compute target-vpn-gateways list

NAME   NETWORK        REGION
vpn-2  vpn-network-2  europe-west1
vpn-1  vpn-network-1  us-east1


#### Creat tunnels for VPN Gateway
#### Tunnel network1-to-network2
gcloud compute \
vpn-tunnels create tunnel1to2  \
--peer-address $STATIC_IP_VPN_2 \
--region us-east1 \
--ike-version 2 \
--shared-secret gcprocks \
--target-vpn-gateway vpn-1 \
--local-traffic-selector 0.0.0.0/0 \
--remote-traffic-selector 0.0.0.0/0

#### Tunnel network2-to-network1
gcloud compute \
vpn-tunnels create tunnel2to1 \
--peer-address $STATIC_IP_VPN_1 \
--region europe-west1 \
--ike-version 2 \
--shared-secret gcprocks \
--target-vpn-gateway vpn-2 \
--local-traffic-selector 0.0.0.0/0 \
--remote-traffic-selector 0.0.0.0/0

#### View VPN Tunnels
gcloud compute vpn-tunnels list

NAME        REGION        GATEWAY  PEER_ADDRESS
tunnel2to1  europe-west1  vpn-2    34.73.244.192
tunnel1to2  us-east1      vpn-1    34.76.176.141

#### Create Static Routes
gcloud compute  \
routes create route1to2  \
--network vpn-network-1 \
--next-hop-vpn-tunnel tunnel1to2 \
--next-hop-vpn-tunnel-region us-east1 \
--destination-range 10.1.3.0/24

gcloud compute  \
routes create route2to1  \
--network vpn-network-2 \
--next-hop-vpn-tunnel tunnel2to1 \
--next-hop-vpn-tunnel-region europe-west1 \
--destination-range 10.5.4.0/24

#### List all routes
gcloud compute routes list


###################################
### Google Compute Engine (GCE) ###
###################################

#### List all compute instances
gcloud compute instances list

#### Create a VM Instance using Cloud Shell
gcloud compute instances create testvm1 --zone us-central1-c

#### SSH into the new VM instance straight from Cloud Shell
gcloud compute ssh testvm1 --zone us-central1-c

#### Create a VM instance with Tags and Meta-data startup script
gcloud compute instances create webserver4 \
--image-family debian-9 \
--image-project debian-cloud \
--tags int-lb \
--zone $MY_ZONE2 \
--subnet default \
--metadata startup-script-url="gs://cloud-training/archinfra/mystartupscript",my-server-id="WebServer-4"

# Using for loop to create multiple Compute VM Instances (eg. 3 nginx instances)
for i in {1..3}; \
do \
  gcloud compute instances create "nginx-$i" \
  --machine-type "f1-micro" \
  --tags nginx-tcp-443,nginx-tcp-80 \
  --zone us-central1-f \
  --image   "https://www.googleapis.com/compute/v1/projects/bitnami-launchpad/global/images/bitnami-nginx-1-14-0-4-linux-debian-9-x86-64" \
  --boot-disk-size "200" --boot-disk-type "pd-standard" \
  --boot-disk-device-name "nginx-$i"; \
done

#### Delete VM Instance
gcloud compute instances delete [vm-name] --keep-disks

# Authorize VM to use the Google Cloud API via Service Account
gcloud auth activate-service-account --key-file credentials.json

# To initialize the Google Cloud SDK if not already setup by deafault on your VM
https://cloud.google.com/sdk/downloads


# To add start-up script to VM add custom metadata to VM in edit screen with key name startup-script
# You can do the same for shutdown script by added a custom metadata with key name shutdown-script


#### Creating a persistant disk
gcloud compute instances attach-disk gcelab --disk mydisk --zone us-central1-c

#### Attaching a persistant disk
gcloud compute instances attach-disk gcelab --disk mydisk --device-name <YOUR_DEVICE_NAME> --zone us-central1-c

#### To mount and format a Persistent Disk
# Create a folder to act as a mount point 
sudo mkdir /mnt/mydisk

# Get disk ID
ls -l /dev/disk/by-id/

# Format the attached disk
sudo mkfs.ext4 -F -E lazy_itable_init=0,\
lazy_journal_init=0,discard \
/dev/disk/by-id/[disk name]
#example:
sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1

# Mount the disk
sudo mount -o discard,defaults /dev/disk/by-id/[disk name] /mnt/[mount point]
#example:
sudo mount -o discard,defaults /dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1 /mnt/mydisk

#### Automatically mount the disk on restart
# Edit fstab file
sudo nano /etc/fstab

# Add following line at the end of the file and save
/dev/disk/by-id/[disk name] /mnt/[mount folder] ext4 defaults 1 1
# example:
/dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1 /mnt/mydisk ext4 defaults 1 1



#### For migrating data from a persistant disk to another region:
# 1. Unmount file system(s)
# 2. Create snapshot
# 3. Create disk in new region from snapshot
# 4. Create instance in new region
# 5. Attach disk

#### For documentation on using Local SSDs (best used as swap disk fro their fast performance, but lack of redundancy)
https://cloud.google.com/compute/docs/disks/local-ssd#create_a_local_ssd

#### Add tags to an instance
gcloud compute instances add-tags testvm --zone us-central1-a --tags web-server

#### Authorize VM to use Cloud SDK via a service account credentials file
gcloud auth activate-service-account --key-file credentials.json

#### Reset Windows RDP password for Compute instance (will create that user account if the account does not already exist)
gcloud compute reset-windows-password my-win-server --user admin --zone us-central1-a

#### Get Serial output of compute instance
gcloud compute instances get-serial-port-output instance-1 --zone us-central1-a

##################################
####    Instance Templates    ####
##################################

#### Create an instance template (along with a startup script)
gcloud compute instance-templates create nginx-template \
--metadata-from-file startup-script=startup.sh

#### List instance templates
gcloud compute instance-templates list

#### Create a target pool for all instances in a group
gcloud compute target-pools create nginx-pool

#### Create a managed instance goup
gcloud compute instance-groups managed create nginx-group \
--base-instance-name nginx \
--size 2 \
--template nginx-template \
--target-pool nginx-pool

#### List Instancec Groups
gcloud compute instance-groups list

#### Creating a HTTP(s) Load Balancer for a Managed Instance Group ####

#### Create a basic HTTP Health Check
gcloud compute http-health-checks create http-basic-check

#### Define an HTTP server and map a port name to Instance group
gcloud compute instance-groups managed \
set-named-ports nginx-group \
--named-ports http:80

#### Create a backend service
gcloud compute backend-services create nginx-backend \
--protocol HTTP --http-health-checks http-basic-check --global

#### Add Instance group to backend service
gcloud compute backend-services add-backend nginx-backend \
    --instance-group nginx-group \
    --instance-group-zone us-central1-a \
    --global
  
#### Create a defaul URL map that directs all incoming traffic to Instances
gcloud compute url-maps create web-map \
    --default-service nginx-backend

#### For specific content-based routing see this link
https://cloud.google.com/compute/docs/load-balancing/http/content-based-example

#### Create a target HTTP proxy to route requests to your URL map
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map

#### Lastly, create a global forwarding rule (this should give the Load Balanced IP to use)
gcloud compute forwarding-rules create http-content-rule \
        --global \
        --target-http-proxy http-lb-proxy \
        --ports 80

#### Create Unmanaged Instance group
gcloud compute instance-groups unmanaged create ig1 \
    --zone $MY_ZONE1

#### Add VM instances to group
gcloud compute instance-groups unmanaged add-instances ig1 \
    --instances=webserver2,webserver3 --zone $MY_ZONE1

#### Set Autohealng for instance
gcloud beta compute instance-groups managed set-autohealing nat-1 \
    --health-check nat-health-check \
    --initial-delay 120 \
    --zone us-east1-b

    
##########################################
####    Other Useful Linux commands   ####
##########################################

# For snapshoting boot disk safest is to halt/shutdown the system
sudo shutdown -h now

# Unmounting disk to take a snapshot 
sudo unmount </mount/point>

# Freezing a partition to take a snapshot if you cant unmount
#1. Stop application from writing to disk
#2. Complete pending writes and flush cache
sudo sync
#3. Suspend/freeze writing to disk device
sudo fsfreeze -f </mount/point>

# Using screen to run a detached session
sudo apt-get install -y screen

sudo screen -S [name of screen] [command you want to run]
# To detach the screen terminal, press Ctrl+A, D. To reattach screen type
sudo screen -r [name of screen]
# Send a command to a screen
sudo screen -r -X [name of scree] '[command]\n'

# Setting up a crontab job
sudo crontab -e

# To see information about unused and used memory and swap space on your custom VM, run the following command:
free

# To see details about the RAM installed on your VM, run the following command:
sudo dmidecode -t 17

# To verify the number of processors, run the following command:
nproc

#To see details about the CPUs installed on your VM, run the following command:
lscpu

######################################
### Google Kubernetes Engine (GKE) ###
######################################

#Creating a cluster on GKE
gcloud container clusters create webfrontend --zone $MY_ZONE --num-nodes 2

#If zone is already set in gcloud config then it can be ommitted like so
gcloud container clusters create networklb --num-nodes 3  

#List all running clusters
gcloud container clusters list

#List running clusters in a specific region
gcloud container clusters list --region us-central1

NAME                 LOCATION     MASTER_VERSION  MASTER_IP       MACHINE_TYPE   NODE_VERSION  NUM_NODES  STATUS
my-regional-cluster  us-central1  1.11.6-gke.2    35.184.129.220  n1-standard-1  1.11.6-gke.2  3          RUNNING

#List node-pools in cluster
gcloud container node-pools list --cluster my-regional-cluster --region us-central1

NAME          MACHINE_TYPE   DISK_SIZE_GB  NODE_VERSION
default-pool  n1-standard-1  15            1.11.6-gke.2

#Add a node-pool to cluster
gcloud container node-pools create my-pool --num-nodes=2 \
> --cluster my-regional-cluster --region us-central1

#Resize node-pool
gcloud container clusters resize my-regional-cluster --region us-central1 --node-pool default-pool --size=4

#Resize Kubernetes Cluser
gcloud container clusters resize  webfrontend --size=2 --zone us-central1-a

#Delete Deployment/Workloads in GKE
kubectl describe deployment nginx-1
kubectl delete deployment nginx-1

#Delete cluster in GKE
gcloud container clusters delete webfrontend --zone us-central1-a
gcloud container clusters delete networklb

#Create Regional cluster in GKE (default runs in 3 zones in that Region)
gcloud container clusters create my-regional-cluster \
--num-nodes 1 \
--region us-central1 \
--disk-size=15GB \
--enable-autoscaling --min-nodes 1 --max-nodes 10 \
--enable-autorepair

#Create Zonal cluster in GKE
gcloud container clusters create my-zonal-cluster --zone us-central1-a \
--preemptible \
--machine-type n1-standard-1 \
--no-enable-cloud-monitoring \
--no-enable-cloud-logging

#Udating a Zonal cluster to multiple zones (multi-region)
gcloud container clusters update my-zonal-cluser --zone us-central1-a \
--node-locations us-central1-a,us-central1-b

#Get details of your cluster in GKE
gcloud container clusters describe my-zonal-cluster --zone us-central1-a

#Update config/settings of a GKE Cluster (eg. enable StackDriver logging)
gcloud container clusters update my-zonal-cluster --zone us-central1-a --logging-service="logging.googleapis.com"

### USING KUBECTL  ###

#Install or Check to see if you have most uptodate version of KubeCTL
gcloud components install kubectl

#switch current context for kubectl and update kubeconfig file which kubectl uses to store cluster authentication information
gcloud beta container clusters get-credentials my-regional-cluster \
--region us-central1 --project qwiklabs-gcp-08c3e58bd80f329e

#this can also be accessed via the Connect button in GKE Clusters console window
gcloud container clusters get-credentials test-cluster --zone us-central1-a --project qwiklabs-gcp-2de127a77da5556b


# Build docker container (requires a Dockerfile in current directory)
docker build -t gcr.io/PROJECT_ID/hello-node:v1 .

# Run docker image
docker run -d -p 8080:8080 gcr.io/PROJECT_ID/hello-node:v1

# Push to Google Docker Private Registry
gcloud docker -- push gcr.io/PROJECT_ID/hello-node:v1

#######################
### Using Kubectl   ###
#######################

#Get Credentials of your cluster for Kubectl config
gcloud container clusters get-credentials CLUSTERNAME

#Get cluster information
kubectl cluster-info

#For troubleshooting 
kubectl get events
kubectl logs <pod-name>

#Get listing of pods
kubectl get pods
kubectl get pods --show-labels  #get list of pods and show their labels
kubectl get pods -owide #to get all pods in cluster
kubectl get pod -l app=nginx #to select via label selector
kubectl get pods -l "app=monolith,secure=enabled" #to select via multiple label selector

#Get more details about pods (including event log)
kubectl describe pods nginx

#Add labels to a pod
kubectl label pods secure-nginx 'secure=enabled'
kubectl get pods secure-nginx --show-labels

#Get Pod log stream in real time
kubectl logs -f monolith

#Set up port forwarding so that you can access port on a Pod from outside cluster
kubectl port-forward monolith 10080:80
#To test:
curl http://127.0.0.1:10080

#Log into a pod via interactive terminal
kubectl exec monolith --stdin --tty -c monolith /bin/sh

#Get listing of nodes
kubectl get nodes

#Get list of exposed services
kubectl get services
kubectl get service nginx

#Get 
kubectl get service [service_name] | awk 'BEGIN { cnt=0; } { cnt+=1; if (cnt > 1) print $4;}'

#Get current context for your session (to determine which cluster etc. kubectl will use)
kubectl config current-context

#View details of your kubeconfig file
kubectl config view

#View your kubeconfig file
cat ~/.kube/config

#Deploy and run a container (by default it will run in the cluster you created if you only have one)
kubectl run nginx --image=nginx:1.10.0 --replicas=2
kubectl run php-apache --image=k8s.gcr.io/hpa-example --requests=cpu=200m --expose --port=80

#Delete Service (exposed IP)
kubectl delete service nginx-1

#Delete deployment/workload
kubectl delete deployment nginx-1

#Exposing Service using Kubectl
kubectl expose deployment nginx --port 80 --target-port 80 --type LoadBalancer
kubectl expose deployment test-website --type LoadBalancer --port 80 --target-port 80

#For reasons on when you would use ClusterIP, NodePort, or Loadbalancer see this link:
https://medium.com/google-cloud/kubernetes-nodeport-vs-loadbalancer-vs-ingress-when-should-i-use-what-922f010849e0

#Exposing Service on each Node's IP at a static port (the NodePort)
kubectl expose deployment nginx --target-port=80 --type=NodePort0

#To Use a Cloud Load Balancer to expose services using the NodePort first create an ingress.yaml file
nano ingress.yaml

#Example Ingress file
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: basic-ingress
spec:
  backend:
    serviceName: nginx
    servicePort: 80

#More Advanced Ingress file #You can define rules that direct traffic by host/path to multiple Kubernetes services.
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: example-ingress
spec:
  backend:
    serviceName: default-handler
    servicePort: 80
  rules:
  - host: my.app.com
    http:
      paths:
      - path: /tomcat
        backend:
          serviceName: tomcat
          servicePort: 8080
      - path: /nginx
        backend:
          serviceName: nginx
          servicePort: 80

#Now create the ingress service
kubectl create -f ingress.yaml

#Monitor the progress of the ingress service (ctrl+C to break out)
kubectl get ingress basic-ingress --watch

#Check status of ingress service
kubectl describe ingress basic-ingress

#Lastly to get external IP address of this httploadbalancer
kubectl get ingress basic-ingress

# Scale up a deployment
kubectl scale deployment hello-node --replicas=4

#Autoscale a deployment
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10

#### Edit a deployment file
kubectl edit deployment hello-node

#### Update an existing deployment/app to a newer version of docker image
kubectl set image deployment/myapp myapp=gcr.io/[project-id]/myapp:v2

#### Rolling back to the previous deployment/version of your app
kubectl rollout undo deployment/myapp

#### Watch status of rolling update for your deployment until completion
kubectl rollout status -w deployment/myapp                    

#Delete the ingress object
kubectl delete -f basic-ingress.yaml

#Get status of Horizontal Pool Autoscaler
kubectl get hpa

NAME         REFERENCE               TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   <unknown>/50%   1         10        1          33s

#Generate load on cluster for testing
kubectl run -i --tty load-generator --image=busybox /bin/sh
\# while true; do wget -q -O- http://php-apache.default.svc.cluster.local;done

# Docker build in GKE (Dockerfile has to be present in directory)
docker build -t [to register with Google container registry use gcr.io/] [root directory of dockerfile]
docker build -t gcr.io/${PROJECTID}/test-website:v1 .

#Example Dockerfile:
FROM nginx:alpine
COPY default.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html

#View list of Docker images
docker images

REPOSITORY                                          TAG                 IMAGE ID            CREATED             SIZE
gcr.io/learning-automation-io-test-repo/test-website   v1                  b75227aae838        2 minutes ago       16.1MB
nginx                                               alpine              b411e34b4606        2 weeks ago         16.1MB

#Allow GCLOUD to setup credential help for all registries
gcloud  auth configure-docker

 {
  "credHelpers": {
    "gcr.io": "gcloud",
    "us.gcr.io": "gcloud",
    "eu.gcr.io": "gcloud",
    "asia.gcr.io": "gcloud",
    "staging-k8s.gcr.io": "gcloud",
    "marketplace.gcr.io": "gcloud"
  }
}

#Add newly built docker image into Google Container Registry
docker push gcr.io/${PROJECTID}/test-website:v1 

The push refers to repository [gcr.io/learning-automation-io-test-repo/test-website]
1bb84fde1fdc: Pushed
722b159e05a8: Pushed
979531bcfa2b: Layer already exists
8d36c62f099e: Layer already exists
4b735058ece4: Layer already exists
503e53e365f3: Layer already exists
v1: digest: sha256:33692b607ee955714e84929ecc588840aeba1287ddf7fac6e3b7e0dafc4f274c size: 1568


#Create ingress object
kubectl create -f ingress.yaml

# Ingress can provide load balancing, SSL termination and name-based virtual hosting.
# More details can be found in Googles documentation:  
https://kubernetes.io/docs/concepts/services-networking/ingress/

#Example ingress.yaml file:
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
    name: test-website-ingress
spec:
    backend:
        serviceName: test-website
        servicePort: 80

#Get details of ingress object
kubectl get ingress test-website-ingress --watch

NAME                   HOSTS     ADDRESS   PORTS     AGE
test-website-ingress   *                   80        3s
test-website-ingress   *         34.95.70.83   80        13s
test-website-ingress   *         34.95.70.83   80        13s

#Get details of ingress object
kubectl describe ingress test-website-ingress

Name:             test-website-ingress
Namespace:        default
Address:          34.95.70.83
Default backend:  test-website:80 (10.8.1.8:80,10.8.1.9:80,10.8.2.6:80)
Rules:
  Host  Path  Backends
  ----  ----  --------
  *     *     test-website:80 (10.8.1.8:80,10.8.1.9:80,10.8.2.6:80)
Annotations:
  ingress.kubernetes.io/forwarding-rule:  k8s-fw-default-test-website-ingress--0e20ca25204f6195
  ingress.kubernetes.io/target-proxy:     k8s-tp-default-test-website-ingress--0e20ca25204f6195
  ingress.kubernetes.io/url-map:          k8s-um-default-test-website-ingress--0e20ca25204f6195
  ingress.kubernetes.io/backends:         {"k8s-be-30480--0e20ca25204f6195":"Unknown"}
Events:
  Type    Reason  Age   From                     Message
  ----    ------  ----  ----                     -------
  Normal  ADD     1m    loadbalancer-controller  default/test-website-ingress
  Normal  CREATE  1m    loadbalancer-controller  ip: 34.95.70.83

#Creating persistant disks
kubectl apply -f test-website-volumeclaim.yaml

#Example yaml file for persistant disk
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
    name: test-website-volumeclaim
spec:
    accessMode:
    - ReadWriteOnce
    resources:
        requests:
            storage: 200Gi

#Get status of persistent volume claims (persistent disks)
kubectl get pvc

#detele persistent volume claim
kubectl delete pvc test-website-volumeclaim
kubectl delete pvc test-mysql-volumeclaim

#Create secret object in Kubectl
kubectl create secret generic mysql --from-literal=password=ReallyStrongPassword123

#Referencing Secret object in .yaml file
...
    spec: containers:
    - image: mysql:5.6
      name: mysql
      env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
            name: mysql
            key: password
...

#########################################
####    Google Container Registry    ####
#########################################

#### Build/tag image that targets GCR
docker build -t gcr.io/[project_id]/myapp:1.0 .

#### gcloud credential helper for Docker
gcloud auth configure-docker

#### Push Image to GCR
gcloud docker -- push gcr.io/[project_id]/myapp:1.0

#### Pull Image from GCR
gcloud docker -- pull gcr.io/[project_id]/myapp:1.0

####  Deploy docker image to GKE
kubectl run my-app --image=gcr.io/[project_id]/myapp:1.0 --replicas=2


#########################################
####    Installing and Using Helm    ####
#########################################

#Installing Helm
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz
tar zxfv helm-v2.9.1-linux-amd64.tar.gz
cp linux-amd64/helm .


#Setting current account as admin on cluster via role binding
kubectl create clusterrolebinding cluster-admin-binding \
 --clusterrole=cluster-admin \
 --user=$(gcloud config get-value account)


#Create service account (tiller is server side of Helm package manager)
 kubectl create serviceaccount tiller --namespace kube-system

#Initiate Helm
./helm init --service-account=tiller

#Update Helm
./helm update
./helm repo update

#Check Helm version
./helm version

#Install Jenkins using Helm
./helm install -n cd stable/jenkins \
 -f jenkins/values.yaml  \
 --version 0.16.6 --wait

#Get your 'admin' user password by running:
printf $(kubectl get secret --namespace default cd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo

#Save POD name to env variable
export POD_NAME=$(kubectl get pods -l "component=cd-jenkins-master" -o jsonpath="{.items[0].metadata.name}")

#Port forward port on pod
kubectl port-forward $POD_NAME 8080:8080 >> /dev/null &

#Create new namespace
kubectl create ns production

#deploy to a specific namespace
kubectl apply -f k8s/production -n production

#Get External IP of app (app name is gceme-frontend in this example and it is in the production namespace)
export FRONTEND_SERVICE_IP=$(kubectl get -o \
jsonpath="{.status.loadBalancer.ingress[0].ip}" \
 --namespace=production services gceme-frontend)


########################################
####   Kubernetes Dashboard Beta    ####
########################################

#### First grant cluster level permissions
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)

#### Create a new dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

#### Edit yaml file for dashboard
kubectl -n kube-system edit service kubernetes-dashboard
# change "type: ClusterIP" to "type: NodePort" and save file

#### Get Token for logging into K8s Dashboard
kubectl -n kube-system describe $(kubectl -n kube-system \
get secret -n kube-system -o name | grep namespace) | grep token:

#### Open connection to dashboard on port 8081 for example
kubectl proxy --port 8081
# use Cloud Shell's web preview and change port to 8081 to view the page. You first need to remove the /?authuser=0 and then add the /api/v1/... similar to the URL below to access the dashboard

https://8081-dot-6692035-dot-devshell.appspot.com/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/service?namespace=default

# Select Token and paste in the Token you copied above to access the Dashboard

#########################
####    App Engine   ####
#########################

#### Download a sample Hello World App Engine app
mkdir appengine-hello
cd appengine-hello
gsutil cp gs://cloud-training/archinfra/gae-hello/* .

#### Run the sample Hello World app in Cloud Shell's local development server
dev_appserver.py $(pwd)

#### Afer running the above command go to In click Web Preview in Cloud Shell to Preview on port 8080

#### To deploy app to App Engine
gcloud app deploy app.yaml

#### Once deployed you can test your app by going to the URL provide with this command
gcloud app browse

#### To redeploy app in App Engine (The --quiet flag disables all interactive prompts when running gcloud commands. If input is required, defaults will be us)
gcloud app deploy app.yaml --quiet

#########################
####    Cloud SQL    ####
#########################

#### Different Connection methods to connect to Cloud SQL
https://cloud.google.com/sql/docs/mysql/external-connection-methods?hl=en_US&_ga=2.121186319.-668297787.1549999676


########################
####    BigQuery    ####
########################

#### Example Syntax for a query in BigQuery
SELECT *
FROM [DatasetID.TableID]
WHERE (DatasetID.TableID.Field > 0);

#### Example BigQuery from example dataset that has 22,537 records
SELECT product, resource_type, start_time, end_time,
cost, project_id, project_name, project_labels_key, currency, currency_conversion_rate,
usage_amount, usage_unit
FROM [cloud-training-prod-bucket.arch_infra.billing_data]
WHERE ([cloud-training-prod-bucket.arch_infra.billing_data.cost] > 0)
  LIMIT 100

#### Grouping data in your Query
SELECT product, COUNT(*)
FROM [cloud-training-prod-bucket.arch_infra.billing_data]
WHERE ([cloud-training-prod-bucket.arch_infra.billing_data.cost] > 1)
GROUP BY product


########################
#### Stack Driver   ####
########################

#### To install Stack Driver monitoring agent
curl -O https://repo.stackdriver.com/stack-install.sh
sudo bash stack-install.sh --write-gcm

#### To install Stack Driver logging agent (for EC2 and Compute Engine resources as App Engine Kubernetes engine have it built-in already)
curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
sudo bash install-logging-agent.sh

#### Note that Stackdriver Logging only keeps logs for 30 days. To keep logs longer they need to be exported to Cloud Storage

#################################
###  Cloud Source Repository  ###
#################################

#Create a repo
gcloud source repos create test_repo

#Use GCloud Credential helper
git config credential.helper gcloud.sh

#Add you Google Cloud Repo as current branch
git remote add origin https://source.developers.google.com/p/learning-automation-io-test/r/test_repo

git config --global user.email "testaccount@google_test.com"
git config --global user.name "Google Tester"

#Clone a repo from Source Repositories
gcloud source repos clone <reponame>

#Get Auth token for GIT user
gcloud auth print-access-token


################################
### USING DEPLOYMENT MANAGER ###
################################

# To list types of resources you can control with Deployment manager
gcloud deployment-manager types list

# For example you can grep to just list instances
gcloud deployment-manager types list | grep instance

# Copying file from Google Cloud resource to your Cloud Shell terminal (using gsutil)
gsutil cp gs://cloud-training/gcpfcoreinfra/mydeploy.yaml mydeploy.yaml

# Creating deployment from yaml file
gcloud deployment-manager deployments create my-first-deployment --config mydeploy.yaml

# Describe your deployment
gcloud deployment-manager deployments describe my-first-deployment

# View manifest of your deployment
gcloud deployment-manager manifests describe manifest-1553994903827 --deployment my-first-deployment

# Basic configuration file
https://cloud.google.com/deployment-manager/docs/configuration/create-basic-configuration

# Example Basic VM config file
resources:
- name: myfirstvm
  type: compute.v1.instance
  properties:
  #basic configuration comes here
    zone: [zone where the instance resides]
    machineType: [URL of the machine type resource to use for this instance]
    disks:
    - deviceName: [unique device name]
      type: [type of the disk, SCRATCH or PERSISTENT]
      boot: [indicate that it is boot disk or not]
      autoDelete: [Specifies whether the disk will be auto-deleted when the instance is deleted]
      initializeParams:
        sourceImage: [The source image to create the disk]
    networkInterfaces:
    - network: [URL of the network resource for this instance]
      accessConfigs:
      - name: [Name for access configuration, currenly only accepted value is "External NAT"]
        type: [type of configuration, currently only accepted value is "ONE_TO_ONE_NAT"]

# Get URL self-link for machine time in a specific region for your project
gcloud compute machine-types describe f1-micro --zone us-central1-a | grep selfLink

# Get URL self-link for image
gcloud compute images list | grep debian
gcloud compute images describe debian-9-stretch-v20190326 --project debian-cloud | grep selfLink

# Get URL self-link for your VPC network
gcloud compute networks list
gcloud compute networks describe default | grep selfLink

# Creating template files
https://cloud.google.com/deployment-manager/docs/step-by-step-guide/create-a-template

# Sample Deployment manager templats from Google
https://github.com/GoogleCloudPlatform/deploymentmanager-samples

# Delete your deployment
gcloud deployment-manager deployments delete  my-first-deployment

#########################
####    Cloud KMS    ####
#########################

#### Cloud KMS is a cryptographic key management service on GCP
#### To Enable Cloud KMS
gcloud services enable cloudkms.googleapis.com

#### Create a Keyrin Grouping and Crytokey
KEYRING_NAME=development CRYPTOKEY_NAME=dev-web
gcloud kms keyrings create $KEYRING_NAME --location global

gcloud kms keys create $CRYPTOKEY_NAME --location global \
      --keyring $KEYRING_NAME \
      --purpose encryption

## Note: CryptoKeys and KeyRings cannot be deleted in Cloud KMS and have to be done in the console > IAM & Admin > Cryptogrphic keys > Go to Keo Management

#### To Encrypting Data first encode file to Base64
FILEBASE64=$(cat image.jpg | base64 -w0)

#### Now encrypt the file using the CryptoKey you generated 
curl -v "https://cloudkms.googleapis.com/v1/projects/$DEVSHELL_PROJECT_ID/locations/global/keyRings/$KEYRING_NAME/cryptoKeys/$CRYPTOKEY_NAME:encrypt" \
  -d "{\"plaintext\":\"$FILEBASE64\"}" \
  -H "Authorization:Bearer $(gcloud auth application-default print-access-token)"\
  -H "Content-Type:application/json" \
| jq .ciphertext -r > image.jpg.encrypted

## This command makes an API call to Cloud KMS to encrypt the base64 encoded string you created and then pipes the ciphertext value returned in the JSON response out to a file named .encrypted using jq (can be any filename or extension)

#### To decrypt and view contents of the file you can call the Cloud KMS Decrypt API
curl -v "https://cloudkms.googleapis.com/v1/projects/$DEVSHELL_PROJECT_ID/locations/global/keyRings/$KEYRING_NAME/cryptoKeys/$CRYPTOKEY_NAME:decrypt" \
  -d "{\"ciphertext\":\"$(cat image.jpg.encrypted)\"}" \
  -H "Authorization:Bearer $(gcloud auth application-default print-access-token)"\
  -H "Content-Type:application/json" \
| jq .plaintext -r | base64 -d

#### Same as above, but to decrypt and save the contents to a file
curl -v "https://cloudkms.googleapis.com/v1/projects/$DEVSHELL_PROJECT_ID/locations/global/keyRings/$KEYRING_NAME/cryptoKeys/$CRYPTOKEY_NAME:decrypt" \
  -d "{\"ciphertext\":\"$(cat image.jpg.encrypted)\"}" \
  -H "Authorization:Bearer $(gcloud auth application-default print-access-token)"\
  -H "Content-Type:application/json" \
| jq .plaintext -r | base64 -d > image.jpg


#### Cloud KMS Quickstart Guide
https://cloud.google.com/kms/docs/quickstart


## The IAM permission to manage keys is 
cloudkms.admin


## The IAM permission to encrypt and decrypt (used to call the encrypt and decrypt API endpoints) is
cloudkms.cryptoKeyEncrypterDecrypter


#### Grant current Cloud Shell user cloudkms.admin and cloudkms.cryptoKeyEncrypterDecrypter role
USER_EMAIL=$(gcloud auth list --limit=1 2>/dev/null | grep '@' | awk '{print $2}')
gcloud kms keyrings add-iam-policy-binding $KEYRING_NAME \
--location global \
--member user:$USER_EMAIL \
--role roles/cloudkms.admin

gcloud kms keyrings add-iam-policy-binding $KEYRING_NAME \
--location global \
--member user:$USER_EMAIL \
--role roles/cloudkms.cryptoKeyEncrypterDecrypter

#### Encrypt an entire Folder
MYDIR=myfolder
FILES=$(find $MYDIR -type f -not -name "*.encrypted")
for file in $FILES; do
  PLAINTEXT=$(cat $file | base64 -w0)
  curl -v "https://cloudkms.googleapis.com/v1/projects/$DEVSHELL_PROJECT_ID/locations/global/keyRings/$KEYRING_NAME/cryptoKeys/$CRYPTOKEY_NAME:encrypt" \
    -d "{\"plaintext\":\"$PLAINTEXT\"}" \
    -H "Authorization:Bearer $(gcloud auth application-default print-access-token)" \
    -H "Content-Type:application/json" \
  | jq .ciphertext -r > $file.encrypted
done

#### Upload encrypted folder to Cloud Storage Bucket
gsutil -m cp myfolder/*.encrypted gs://${BUCKET_NAME}/myfoler

## Note: Cloud Storage supports Server Side Encryption, which supports key rotation of your data and is the recommended way to encrypt data in Cloud Storage. See Cloud Storage section on Customer Supplied Encryption Key (CSEK)

##############################################
####    Using Terraform in Cloud Shell    ####
##############################################

#Download and Install Terraform
wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
unzip terraform_0.11.13_linux_amd64.zip

#Export Terraform path
export PATH="$PATH:$HOME/terraform"
cd /usr/bin
sudo ln -s $HOME/terraform
cd $HOME
source ~/.bashrc

# Now you can use Terraform init, plan, apply, etc. without having to specify the Google Cloud (GCP) provider or use a credentials file from a service account to provision infrastructure!