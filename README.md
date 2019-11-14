# CDS Technical Preview - Release v0.2

## DataCore Internal Use Only

## Prerequisites

- Ubuntu Linux 18.04 LTS
- Kubernetes v1.15.x (v1.16 is not supported for this release)
- A Kubernetes cluster with at least 3 worker nodes
- The Kubernetes feature gate 'VolumeSnapshot' should be enabled

Worker nodes should have:
 - At least 12GB of RAM
 - At least 4vCPUs
 - One unpartitioned, unmounted disk device to use as CDS storage, which is a minimum of 64GiB in size


## Preparing a Kubernetes Cluster

For the Technical Preview it is supported to use a Kubernetes cluster which:
- Is installed on bare metal
- Is installed within Virtual Machines (self, or cloud-hosted)
- Is hosted as a Virtual Machine Scale Set within Azure and deployed using aks-engine

For those with access to an Azure Subscription, the quickest and easiest way to deploy a new cluster for evaluation purposes is to use aks-engine with the pre-prepared API model supplied by DataCore.  This process is documented in the "Getting Started" Guide for this release.

## Installation

### Install the CDS Operator

Create the DataCore namespace

```
kubectl create namespace datacore
```

In order to install the Tech Preview of CDS, you will need a secret to gain access to the private repository. Create the secret with the details provided when given access to the Tech Preview.

```
kubectl create secret docker-registry cds-docker-credentials --docker-server=https://index.docker.io/v1/ --docker-username=<USERNAME> --docker-password=<PASSWORD> --docker-email=<YOUR_EMAIL> --namespace datacore
```

Where
- `USERNAME`   is the username provided for the Tech Preview
- `PASSWORD`   is the password for the username provided for the Tech Preview
- `YOUR_EMAIL` is your email address

From the master kubernetes console
kubectl apply -f https://raw.githubusercontent.com/datacore-teamcity/cds/master/datacore-cds-operator-0.2.yaml

Verify that the operator is installed and running
kubectl get pods -n datacore
NAME                                 READY   STATUS    RESTARTS   AGE
cds-operator-6cb9857596-vktpn        1/1     Running   0          104s
datacore-operator-77dd77c48b-sr57r   1/1     Running   1          104s

Your output will vary slightly.

Install the DataCore CDS stack
kubectl apply -f https://raw.githubusercontent.com/datacore-teamcity/cds/master/datacore-cds-0.2.yaml

Verify and wait for the entire stack to be started
kubectl get pods -n datacore
NAME                                            READY   STATUS      RESTARTS   AGE
cds-operator-6cb9857596-vktpn                   1/1     Running     0          10m
csi-cephfsplugin-2ktg6                          3/3     Running     0          6m3s
csi-cephfsplugin-provisioner-64dfc8cd45-hjt2n   4/4     Running     0          6m3s
csi-cephfsplugin-provisioner-64dfc8cd45-jmg5m   4/4     Running     0          6m3s
csi-cephfsplugin-rplq6                          3/3     Running     0          6m3s
csi-cephfsplugin-zdkx2                          3/3     Running     0          6m3s
csi-datacore-attacher-0                         1/1     Running     0          4m43s
csi-datacore-cdsplugin-h9kb6                    2/2     Running     0          4m42s
csi-datacore-cdsplugin-s7klp                    2/2     Running     0          4m42s
csi-datacore-cdsplugin-xqsn7                    2/2     Running     0          4m42s
csi-datacore-provisioner-0                      1/1     Running     0          4m42s
csi-datacore-snapshotter-0                      1/1     Running     0          4m42s
datacore-nats-service-1                         2/2     Running     0          6m6s
datacore-nats-service-2                         2/2     Running     0          6m2s
datacore-nats-service-3                         2/2     Running     0          5m58s
datacore-operator-77dd77c48b-sr57r              1/1     Running     1          10m
elasticsearch-0                                 1/1     Running     0          6m5s
fluentd-4wgfh                                   1/1     Running     0          6m5s
fluentd-6h7cn                                   1/1     Running     0          6m5s
fluentd-dk6q6                                   1/1     Running     0          6m5s
fluentd-ntcnq                                   1/1     Running     0          6m5s
jaeger-collector-6f6d5c4d84-hkd8v               1/1     Running     0          5m42s
jaeger-operator-bob-79f5c499f7-pxv9t            1/1     Running     0          6m5s
jaeger-query-6bcd9b67f4-6dswq                   2/2     Running     2          5m42s
kibana-647958c9f7-j9cz9                         1/1     Running     0          6m5s
metricbeat-5ftbm                                1/1     Running     0          4m42s
metricbeat-7b46787c44-2d5kv                     1/1     Running     0          4m42s
metricbeat-8hbls                                1/1     Running     0          4m42s
metricbeat-k4754                                1/1     Running     0          4m42s
nats-operator-cdc64fdd8-2ln9r                   1/1     Running     0          6m8s
prometheus-5f4cffdf98-fxpb6                     1/1     Running     0          4m43s
rook-ceph-mds-dcsfs-a-56498bb97c-29crx          1/1     Running     0          2m28s
rook-ceph-mds-dcsfs-b-69695b55f-r7ccg           1/1     Running     0          2m28s
rook-ceph-mgr-a-59d84cdfd4-kzzz8                1/1     Running     0          3m32s
rook-ceph-mon-a-6f7869769-5s7wn                 1/1     Running     0          4m20s
rook-ceph-mon-b-78cdb7dff7-trxff                1/1     Running     0          4m4s
rook-ceph-mon-c-7bf4f97d98-8rm9d                1/1     Running     0          3m48s
rook-ceph-operator-79fdc7fc7b-sd5bc             1/1     Running     0          6m6s
rook-ceph-osd-0-d58484b8d-5v6dh                 1/1     Running     0          2m43s
rook-ceph-osd-1-6969d7477f-7qgfz                1/1     Running     0          2m42s
rook-ceph-osd-2-76d87449cd-w2vls                1/1     Running     0          2m42s

There are several components that are installed with CDS. Be sure they are all there and ready. A successful installation will have
A rook-ceph operator. In the example above this is rook-ceph-operator-79fdc7fc7b-sd5bc
A rook-ceph osd pod for each storage device under CDS management. In the example above there is one data disk on each worker node mounted to /var/lib/datacore-rook-osd and these are represented by pods with starting with name rook-ceph-osd.
A rook-ceph mgr pod. In the example above this is rook-ceph-mgr.
Two rook-ceph mds pods. In the example above these are started with name rook-ceph-mds.
Three rook-ceph monitor pods. In the example above these have names starting with rook-ceph-mon.
CSI plugin components for CDS. There should be 
csi-cephfsplugin
csi-cephfsplugin-provisioner
csi-datacore-attacher
csi-datacore-cdsplugin
csi-datacore-provisioner
Csi-datacore-snapshotter
Transport service pods. These have names starting with datacore-nats-service.
A number of pods for metrics and logs gathering including those from elastic, fluentd, jaeger, metricbeat and prometheus.




