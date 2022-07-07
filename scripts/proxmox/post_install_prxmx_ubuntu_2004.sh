#!/bin/bash 
set -e
set -v

# http://superuser.com/questions/196848/how-do-i-create-an-administrator-user-on-ubuntu
# http://unix.stackexchange.com/questions/1416/redirecting-stdout-to-a-file-you-dont-have-write-permission-on
# This line assumes the user you created in the preseed directory is vagrant
echo "%admin  ALL=NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/init-users
sudo groupadd admin
sudo usermod -a -G admin vagrant

sudo apt-get update
sudo apt-get dist-upgrade -y

# https://github.com/hashicorp/terraform-provider-vsphere/issues/516
# Remove /etc/machine-id so that all the cloned machines will get their own IP address upon DHCP request
sudo rm -f /etc/machine-id
sudo touch /etc/machine-id


# Install Java
sudo apt update
sudo apt install -y openjdk-11-jdk

# Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee \
 /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install -y jenkins 

# Start Jenkins
sudo systemctl start jenkins

#Unzip commandlinetools-linux-8512546_latest.zip
sudo apt-get update
sudo apt-get install -y unzip
#cd /home/vagrant/
unzip commandlinetools-linux-8512546_latest.zip
./cmdline-tools/bin/sdkmanager --install "cmdline-tools;latest" --sdk_root=/home/vagrant/android_sdk
echo 'export ANDROID_SDK_ROOT=/home/vagrant/android_sdk/cmdline-tools/latest/bin' >> ~/.bashrc 
echo 'export PATH=$PATH:$ANDROID_SDK_ROOT' >> ~/.bashrc 

echo 'export ANDROID_SDK_HOME=/home/vagrant/android_sdk' >> ~/.bashrc 
echo 'export PATH=$PATH:$ANDROID_SDK_HOME/tools' >> ~/.bashrc 
echo 'export PATH=$PATH:$ANDROID_SDK_HOME/platform-tools' >> ~/.bashrc 
echo 'export JAVA_HOME=/usr/java/jdk11/bin' >> ~/.bashrc 
echo 'export PATH=$PATH:$JAVA_HOME' >> ~/.bashrc 