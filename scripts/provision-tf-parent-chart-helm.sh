#!/bin/bash -v 

### Define Directory Vairable for the OSH and Contrail Repos for Chrats Installation ############
export BASE_DIR=/opt
export OSH_PATH=${BASE_DIR}/openstack-helm
export OSH_INFRA_PATH=${BASE_DIR}/openstack-helm-infra
export CHD_PATH=${BASE_DIR}/contrail-helm-deployer

### Define Nodes names for K8s Labeling "opencontrail.org/controller", "opencontrail.org/vrouter-kernel" & "opencontrail.org/vrouter-dpdk"  #######
export CONTRAIL_CONTROLLER_NODE_01=k8s-node01
export CONTRAIL_CONTROLLER_NODE_02=k8s-node02
export CONTRAIL_CONTROLLER_NODE_03=k8s-node03

export CONTRAIL_COMPUTE_KERNEL_01=k8s-node01
export CONTRAIL_COMPUTE_KERNEL_02=k8s-node02

#export CONTRAIL_COMPUTE_DPDK_01=k8s-node03
#export CONTRAIL_COMPUTE_DPDK_02=k8s-node04

##### Controller IP Addresses MGMT Network ###########
export CONTROLLER_NODE_01=10.13.82.237
export CONTROLLER_NODE_02=10.13.82.238
export CONTROLLER_NODE_03=10.13.82.239

######### Contrail Control and Data Plane ##################
export CONTROL_NODE_01=192.168.1.237
export CONTROL_NODE_02=192.168.1.238
export CONTROL_NODE_03=192.168.1.239

export CONTROL_DATA_NET_LIST=192.168.1.0/24
export VROUTER_GATEWAY=192.168.1.1

##### Only used for Calico as CNI to change Contrail Controller port to 1179 ########
export BGP_PORT=1179

### vRouter Kernel Config Values #######
export AGENT_MODE_KERNEL=nic

### vRouter DPDK Config Values #######
export CPU_CORE_MASK="0xff"
export DPDK_UIO_DRIVER=uio_pci_generic
export HUGE_PAGES=49000
export AGENT_MODE_DPDK=dpdk
export HUGE_PAGES_DIR=/hugepages

################## Installastion of Contrail Helm Charts ##############################
cd ${CHD_PATH}
make

kubectl replace -f ${CHD_PATH}/rbac/cluster-admin.yaml

############## Label Contrail Nodes ###################################
kubectl label node ${CONTRAIL_COMPUTE_KERNEL_01} ${CONTRAIL_COMPUTE_KERNEL_02} opencontrail.org/vrouter-kernel=enabled
#kubectl label node ${CONTRAIL_COMPUTE_DPDK_01} opencontrail.org/vrouter-dpdk=enabled
kubectl label nodes ${CONTRAIL_CONTROLLER_NODE_01} ${CONTRAIL_CONTROLLER_NODE_02} ${CONTRAIL_CONTROLLER_NODE_03} opencontrail.org/controller=enabled

echo "**********  Contrail Controller Nodes  ***************\n"
kubectl get nodes -o wide -l opencontrail.org/controller=enabled

echo "**********  Contrail Compute Nodes with vrouter-kernel ***************\n"
kubectl get nodes -o wide -l opencontrail.org/vrouter-kernel=enabled

echo "**********  Contrail Compute Nodes with vrouter-dpdk ***************\n"
kubectl get nodes -o wide -l opencontrail.org/vrouter-dpdk=enabled


#### contrail chart Global Env Setting ########
cat > /var/tmp/contrail-controllers << EOF
$CONTROLLER_NODE_01,$CONTROLLER_NODE_02,$CONTROLLER_NODE_03
EOF

cat > /var/tmp/contrail-control << EOF
$CONTROL_NODE_01,$CONTROL_NODE_02,$CONTROL_NODE_03
EOF

cat > /tmp/contrail.yaml << EOF
# GLOBAL variables: which can be consumed by all charts
# images, contrail_env, contrail_env_vrouter_dpdk, contrail_env_vrouter_kernel
global:
  # section to configure images for all containers
  images:
    tags:
      kafka: "docker.io/opencontrailnightly/contrail-external-kafka:ocata-master-38"
      cassandra: "docker.io/opencontrailnightly/contrail-external-cassandra:ocata-master-38"
      redis: "redis:4.0.2"
      zookeeper: "docker.io/opencontrailnightly/contrail-external-zookeeper:ocata-master-38"
      contrail_control: "docker.io/opencontrailnightly/contrail-controller-control-control:ocata-master-38"
      control_dns: "docker.io/opencontrailnightly/contrail-controller-control-dns:ocata-master-38"
      control_named: "docker.io/opencontrailnightly/contrail-controller-control-named:ocata-master-38"
      config_api: "docker.io/opencontrailnightly/contrail-controller-config-api:ocata-master-38"
      config_devicemgr: "docker.io/opencontrailnightly/contrail-controller-config-devicemgr:ocata-master-38"
      config_schema_transformer: "docker.io/opencontrailnightly/contrail-controller-config-schema:ocata-master-38"
      config_svcmonitor: "docker.io/opencontrailnightly/contrail-controller-config-svcmonitor:ocata-master-38"
      webui_middleware: "docker.io/opencontrailnightly/contrail-controller-webui-job:ocata-master-38"
      webui: "docker.io/opencontrailnightly/contrail-controller-webui-web:ocata-master-38"
      analytics_api: "docker.io/opencontrailnightly/contrail-analytics-api:ocata-master-38"
      contrail_collector: "docker.io/opencontrailnightly/contrail-analytics-collector:ocata-master-38"
      analytics_alarm_gen: "docker.io/opencontrailnightly/contrail-analytics-alarm-gen:ocata-master-38"
      analytics_query_engine: "docker.io/opencontrailnightly/contrail-analytics-query-engine:ocata-master-38"
      analytics_snmp_collector: "docker.io/opencontrailnightly/contrail-analytics-snmp-collector:ocata-master-38"
      contrail_topology: "docker.io/opencontrailnightly/contrail-analytics-topology:ocata-master-38"
      build_driver_init: "docker.io/opencontrailnightly/contrail-vrouter-kernel-build-init:ocata-master-38"
      vrouter_agent: "docker.io/opencontrailnightly/contrail-vrouter-agent:ocata-master-38"
      vrouter_init_kernel: "docker.io/opencontrailnightly/contrail-vrouter-kernel-init:ocata-master-38"
      vrouter_dpdk: "docker.io/opencontrailnightly/contrail-vrouter-agent-dpdk:ocata-master-38"
      vrouter_init_dpdk: "docker.io/opencontrailnightly/contrail-vrouter-kernel-init-dpdk:ocata-master-38"
      dpdk_watchdog: "docker.io/opencontrailnightly/contrail-vrouter-net-watchdog:ocata-master-38"
      nodemgr: "docker.io/opencontrailnightly/contrail-nodemgr:ocata-master-38"
      dep_check: quay.io/stackanetes/kubernetes-entrypoint:v0.2.1
    imagePullPolicy: "IfNotPresent"


# contrail_env section for all containers
  contrail_env:
    CONTROLLER_NODES: $(cat /var/tmp/contrail-controllers)
    CONTROL_NODES: $(cat /var/tmp/contrail-control)
    BGP_PORT: 1179
    LOG_LEVEL: SYS_NOTICE
    CLOUD_ORCHESTRATOR: openstack 
    AAA_MODE: cloud-admin 
    BGP_PORT: $BGP_PORT
    CONTROL_DATA_NET_LIST: ${CONTROL_DATA_NET_LIST}
    VROUTER_GATEWAY: ${VROUTER_GATEWAY}

# section of vrouter template for kernel mode
  contrail_env_vrouter_kernel:
    AGENT_MODE: ${AGENT_MODE_KERNEL}

# section of vrouter template for dpdk mode
  contrail_env_vrouter_dpdk:
    DPDK_MEM_PER_SOCKET: 1024
    PHYSICAL_INTERFACE: bond0
    #PHYSICAL_INTERFACE: bond0
    #PHYSICAL_INTERFACE: p3p1
    CPU_CORE_MASK: "$CPU_CORE_MASK"
    DPDK_UIO_DRIVER: ${DPDK_UIO_DRIVER}
    HUGE_PAGES: ${HUGE_PAGES}
    AGENT_MODE: ${AGENT_MODE_DPDK}
    HUGE_PAGES_DIR: /hugepages

  node:
    host_os: ubuntu

# Chart level variables like manifests, labels which are local to subchart
# Can be updated from the parent chart like below
# Example of overriding values of subchart, where contrail-vrouter is name of the subchart
contrail-vrouter:
  manifests:
    configmap_vrouter_dpdk: true
    daemonset_dpdk: true
EOF

############## Use this section if you would like to install each Contrail Chart separately using "values.yaml" file #######
#helm install --name contrail-thirdparty ./contrail-thirdparty --namespace=contrail --values /tmp/contrail-thirdparty.yaml
#helm install --name contrail-controller ./contrail-controller --namespace=openstack --values /tmp/contrail-controller.yaml
#helm install --name contrail-analytics ./contrail-analytics --namespace=openstack --values /tmp/contrail-analytics.yaml
#helm install --name contrail-vrouter ./contrail-vrouter --namespace=openstack --values /tmp/contrail-vrouter.yaml

echo ************* Deployment of Contrail Parent Helm Chart ***************************
cd ${CHD_PATH}
helm install --name contrail ${CHD_PATH}/contrail --namespace=contrail --values=/tmp/contrail.yaml
cd ${OSH_PATH}
./tools/deployment/common/wait-for-pods.sh openstack 1200
echo 3 | sudo tee /proc/sys/vm/drop_caches
read -p "Clear cache on other nodes. Press y to continue or n to abort [y/n] : " yn
case $yn in
    [Nn]* ) echo "Aborting...."; exit;;
esac

echo ************** Installing OpenStack Heat with Contrail Heat Resoruces ****************
cd ${OSH_PATH}
./tools/deployment/multinode/151-heat-opencontrail.sh

echo ****************** Contrail Helm Installation is sucessful *************************