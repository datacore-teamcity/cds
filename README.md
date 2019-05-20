# CDS Alpha Release

## Pre-requisites
A Kubernetes cluster with 3 worker nodes.

The CDS alpha release has only been tested on Kubernetes clusters consisting of Ubuntu 18.04 LTS hosts,
with no other applications deployed on the cluster.

## Installation
The CDS alpha docker images are published on dockerhub, and can be accessed using credentials supplied by your
point of contact in DataCore.

To apply the credentials on your Kubernetes cluster use the commands below:

```
kubectl create namespace datacore
kubectl create secret docker-registry cds-docker-credentials --docker-server=https://index.docker.io/v1/ --docker-username=<USERNAME> --docker-password=<PASSWORD> --docker-email=<EMAIL_ADDRESS> --namespace datacore
```

Where:
 * &lt;USERNAME&gt; is the user name supplied by DataCore
 * &lt;PASSWORD&gt; is the password name supplied by DataCore
 * &lt;EMAIL_ADDRESS&gt; is your email address


To install the DataCore CDS alpha release

Do:
1.  ```kubectl apply -f https://raw.githubusercontent.com/datacore-teamcity/cds/master/cds-operator-release.yaml```
2.  Wait for custom resource definitions to be registered with kubernetes. The output of ```kubectl get crd``` should show
   * ```classes.cdscontroller.datacore.com```
   * ```volumes.cdscontroller.datacore.com```
   * ```configs.cdscontroller.datacore.com``` 
3.  ```kubectl apply -f https://raw.githubusercontent.com/datacore-teamcity/cds/master/cds.yaml```


If you see errors like
```
unable to recognize "/tmp/k8s-artifacts/dcs_operator/cds.yaml": no matches for kind "CDSResource" in version "cdscontroller.datacore.com/v1alpha1"
unable to recognize "/tmp/k8s-artifacts/dcs_operator/cds.yaml": no matches for kind "CDSClass" in version "cdscontroller.datacore.com/v1alpha1"
unable to recognize "/tmp/k8s-artifacts/dcs_operator/cds.yaml": no matches for kind "CDSClass" in version "cdscontroller.datacore.com/v1alpha1"
```
this will be because the registration of cds operator custom resource types on the Kubernetes cluster has not yet completed.

In which case wait for a few seconds and repeat step 2.

The CDS alpha release does not support dynamic provisioning.

Persistent volumes with data services, are provisioned using a Kubernetes Custom Resource (CRD),
see the description of CDS Volumes below.

When a CDS Volume is provisioned a Persistent Volume (PV) of the same name is created.

Applications can access the storage defined by mounting a Persistent Volume Claim (PVC)
bound against the Persistent Volume.

The PVC must be created by the Kubernetes administrator, similar to when volumes are provisioned dynamically.

## CDS Volumes
Persistent volumes are provisioned by applying a CDS Volume yaml file.
```
NAME                              READY   STATUS    RESTARTS   AGE
wordpress-6f88579b6-588p6         0/1     Pending   0          90s
wordpress-mysql-bd86c6b8f-gdlbm   0/1     Pending   0          89s
```

The specification for a CDS volume consists of CDS classname and a subset of the specifications for a PersistentVolume namely *capacity*, *accessMode* and *volumeMode*.

Below is an example:

```
apiVersion: cdscontroller.datacore.com/v1alpha1
kind: CDSVolume
metadata:
  name: cds-vol-1
spec:
  classname: iscsi-skeleton
  capacity:
      storage: 10Gi
  accessMode: ReadWriteOnce
  volumeMode: FileSystem
```

For the CDS alpha release the equivalent minimal specification is:
```
apiVersion: cdscontroller.datacore.com/v1alpha1
kind: CDSVolume
metadata:
  name: cds-vol-1
spec:
```

### Class Name
The name of the DataCore CDS class associated with the volume.

DataCore CDS classes define sets of data services.

**For the CDS alpha release the only class available is the iscsi-skeleton class and if a class is not specified this will be used.**

### Capacity
A PersistentVolume will be created with a capacity equal to or larger than that set in the **capacity** attribute

See the Kubernetes documentation for [Resource Model](https://git.k8s.io/community/contributors/design-proposals/scheduling/resources.md) to understand units of capacity.

**For the CDS alpha release the capacity attribute is ignored and always set to 10Gi**

### Access Modes
See the Kubernetes documentation for [Access Modes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes).

**The CDS alpha release only supports ReadWriteOnce and ReadOnlyMany access modes**

### Volume Mode
See the Kubernetes documentation for [Volume Mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#volume-mode).

**Using block mode with the CDS alpha release is not recommended, and may cause instability**


## Persistent Volume Claims (PVC)
See the Kubernetes documentation for [Persistent Volume Claims](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims).

The requirements for PVCs to bind to Persistent Volumes Provisioned are
 * ```storageClassName``` must be ```datacore-cds```
 * storage request must be 10Gi or lower
 * ```accessModes``` must be ```ReadWriteOnce``` or ```ReadOnlyMany```
 * ```volumeMode``` must match that specified for the CDS Volume.

## Examples
### Wordpress
Here is a list yaml files to start an example wordpress container on the Kubernetes cluster,
using persistent volumes provisioned by the DataCore CDS alpha release.

 * [examples/wordpress/wp-claim.yaml](#wp-claim)
 * [examples/wordpress/mysql-volume.yaml](#mysql-volume)
 * [examples/wordpress/wordpress.yaml](#wordpress)
 * [examples/wordpress/mysql.yaml](#mysql)
 * [examples/wordpress/wp-volume.yaml](#wp-volume)
 * [examples/wordpress/mysql-claim.yaml](#mysql-claim)

Deploy the example wordpress server on the Kubernetes cluster using the following commands:

```
kubectl apply -f https://raw.githubusercontent.com/datacore-teamcity/cds/master/examples/wordpress/mysql-volume.yaml
kubectl apply -f https://raw.githubusercontent.com/datacore-teamcity/cds/master/examples/wordpress/wp-volume.yaml
kubectl apply -f https://raw.githubusercontent.com/datacore-teamcity/cds/master/examples/wordpress/mysql-claim.yaml
kubectl apply -f https://raw.githubusercontent.com/datacore-teamcity/cds/master/examples/wordpress/wp-claim.yaml
kubectl apply -f https://raw.githubusercontent.com/datacore-teamcity/cds/master/examples/wordpress/wordpress.yaml
kubectl apply -f https://raw.githubusercontent.com/datacore-teamcity/cds/master/examples/wordpress/mysql.yaml
```

Wait for the persistent volumes to be provisioned and the wordpress installation to start, typically this requires several minutes.

Check status using ```kubectl get pod```

Typical output is something like this:
```
NAME                              READY   STATUS    RESTARTS   AGE
wordpress-6f88579b6-588p6         0/1     Pending   0          90s
wordpress-mysql-bd86c6b8f-gdlbm   0/1     Pending   0          89s
```

When the status field for both wordpress pods is ```Running``` then the Wordpress installation is ready for use.

The IP address and port to access the Wordpress installation can be obtained from the output of the command:
```
kubectl get service wordpress
```

On VWare ESXi the output is something like this:
```
NAME        TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
wordpress   LoadBalancer   10.109.74.173   <pending>     80:31904/TCP   95m
```

An external IP address is not created, however the Wordpress installation can accessed using the VM external IP address, in this case on port number 31904.
For example http://10.10.10.10:31904

If the EXTERNAL-IP field contains a valid IP address the Wordpress installation can be accessed using that IP address on port 80.

## Known Limitations
 * A maximum of 16 volumes are supported.
 * Volume size is fixed at 10Gi.


## Contents of the example yaml files
### examples/wordpress/wp-volume.yaml <a name="wp-volume">.</a>
```
apiVersion: cdscontroller.datacore.com/v1alpha1
kind: CDSVolume
metadata:
  name: wp-volume
spec:
  classname: iscsi-skeleton
  volumeid: wp-pv
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
```


### examples/wordpress/wp-claim.yaml <a name="wp-claim">.</a>
```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: wp-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: datacore-cds
```


### examples/wordpress/wordpress.yaml  <a name="wordpress">.</a>
```
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  ports:
  - port: 80
  selector:
    app: wordpress
    tier: frontend
  type: LoadBalancer
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: frontend
    spec:
      containers:
      - image: wordpress:4.6.1-apache
        name: wordpress
        env:
        - name: WORDPRESS_DB_HOST
          value: wordpress-mysql
        - name: WORDPRESS_DB_PASSWORD
          value: changeme
        ports:
        - containerPort: 80
          name: wordpress
        volumeMounts:
        - name: wordpress-persistent-storage
          mountPath: /var/www/html
      volumes:
      - name: wordpress-persistent-storage
        persistentVolumeClaim:
          claimName: wp-claim
```


### examples/wordpress/mysql-volume.yaml  <a name="mysql-volume">.</a>
```
apiVersion: cdscontroller.datacore.com/v1alpha1
kind: CDSVolume
metadata:
  name: mysql-vol
spec:
  classname: iscsi-skeleton
  volumeid: mysql-pv
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
```



### examples/wordpress/mysql-claim.yaml <a name="mysql-claim">.</a>
```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: mysql-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: datacore-cds
```


### examples/wordpress/mysql.yaml <a name="mysql">.</a>
```
apiVersion: v1
kind: Service
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  ports:
    - port: 3306
  selector:
    app: wordpress
    tier: mysql
  clusterIP: None
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: mysql
    spec:
      containers:
      - image: mysql:5.6
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: changeme
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-claim
```
