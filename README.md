# CDS Technical Preview - Release v0.2

## DataCore Internal Use Only

## Prerequisites

- Ubuntu Linux 18.04 LTS
- Kubernetes v1.15.x (v1.16 is not supported for this release)
- A Kubernetes cluster with at least 3 worker nodes
- The Kubernetes feature gate 'VolumeSnapshot' should be enabled

Worker nodes should each have:
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

### Create the DataCore namespace

```
kubectl create namespace datacore
```

### Create Docker Secrets

In order to install the Tech Preview of CDS, you will need a secret to gain access to the private repository. Create the secret with the details provided when given access to the Tech Preview.

```
kubectl create secret docker-registry cds-docker-credentials --docker-server=https://index.docker.io/v1/ --docker-username=<USERNAME> --docker-password=<PASSWORD> --docker-email=<YOUR_EMAIL> --namespace datacore
```

Where
- `USERNAME`   is the username provided for the Tech Preview
- `PASSWORD`   is the password for the username provided for the Tech Preview
- `YOUR_EMAIL` is your email address

### Deploy the CDS Operator

```
kubectl apply -f https://raw.githubusercontent.com/datacore-teamcity/cds/master/datacore-operator-0.2.yaml
```

Verify that the operator is installed and running

```
kubectl get pods -n datacore
NAME                                 READY   STATUS    RESTARTS   AGE
cds-operator-6cb9857596-vktpn        1/1     Running   0          104s
datacore-operator-77dd77c48b-sr57r   1/1     Running   1          104s
```

(Your output will vary slightly but should contain the two 'cds-' and 'datacore-' pods)

### Deploy the DataCore CDS stack

```
kubectl apply -f https://raw.githubusercontent.com/datacore-teamcity/cds/master/datacore-cds-0.2.yaml
```

Wait for the entire stack to be started.  This may take a few minutes.
The installation is complete when all pods in the datacore namespace reach 'Running' or 'Completed' status


### Create the CDP VolumeSnapshotClass

```
kubectl apply -f https://raw.githubusercontent.com/datacore-teamcity/cds/master/datacore-snapshotClassCdp-0.2.yaml
```

