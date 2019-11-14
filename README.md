# CDS Technical Preview - Release v0.2

## DataCore Internal Use Only

## Prerequisites

- Ubuntu Linux 18.04 LTS
- Kubernetes v1.15.x (v1.16 is not supported for this release)
- A Kubernetes cluster with at least 3 worker nodes

Worker nodes should have:
 - At least 12GB of RAM
 - At least 4vCPUs
 - One unpartitioned, unmounted disk device to use as CDS storage, which is a minimum of 64GiB in size


## Preparing a Kubernetes Cluster

For the Technical Preview it is supported to use a Kubernetes cluster which:
- Is installed on bare metal
- Is installed within Virtual Machines (self, or cloud-hosted)
- Is hosted as a Virtual Machine Scale Set within Azure and deployed using aks-engine

For those with access to an Azure Subscription, the quickest and easiest way to deploy a new cluster for evaluation purposes is to use aks-engine with the pre-prepared API model supplied by DataCore

## Installation




