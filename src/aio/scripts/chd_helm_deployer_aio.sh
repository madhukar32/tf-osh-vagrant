sudo apt-get update

sudo apt-get install -y git

rm -rf /opt/openstack-helm /opt/openstack-helm-infra /opt/contrail-helm-deployer
sudo git clone https://github.com/Juniper/openstack-helm.git /opt/openstack-helm
# Download openstack-helm-infra code
sudo git clone https://github.com/Juniper/openstack-helm-infra.git /opt/openstack-helm-infra
#cp -r /vagrant/openstack-helm-infra /opt/openstack-helm-infra
# Download contrail-helm-deployer code
sudo git clone https://github.com/Juniper/contrail-helm-deployer.git /opt/contrail-helm-deployer
#cp -r /vagrant/contrail-helm-deployer /opt/

export BASE_DIR=/opt
export OSH_PATH=${BASE_DIR}/openstack-helm
export OSH_INFRA_PATH=${BASE_DIR}/openstack-helm-infra
export CHD_PATH=${BASE_DIR}/contrail-helm-deployer

export CONTRAIL_REGISTRY=docker.io/opencontrailnightly
export CONTAINER_TAG=latest
 
ls -al /opt/contrail-helm-deployer/roles/contrail-helm-deployer/files/helm-deploy.sh
chmod +x /opt/contrail-helm-deployer/roles/contrail-helm-deployer/files/helm-deploy.sh
/opt/contrail-helm-deployer/roles/contrail-helm-deployer/files/helm-deploy.sh
