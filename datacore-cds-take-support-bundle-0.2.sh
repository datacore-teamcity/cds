#!/bin/sh
# Creates a gzipped json file containing the logstash-* index from ElasticSearch
# This script may be run on any host connected to the cluster, on 
# which kubectl is installed.
# Kubectl should be configured with the cluster of interest as the default context.

cleanup() {
  kubectl delete jobs -n datacore support-bundle-elasticdump-job
  exit
}

trap cleanup INT TERM EXIT

# Remove any existing job first
kubectl delete jobs -n datacore support-bundle-elasticdump-job 2> /dev/null

log_name=dcs_logstash.json.gz

cat <<EOF | kubectl create -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: support-bundle-elasticdump-job
  namespace: datacore
spec:
  template:
    spec:
      restartPolicy: Never
      volumes:
      - name: shared-data
        emptyDir: {}
      initContainers:
      - name: support-bundle-elasticsearch-dump
        image: taskrabbit/elasticsearch-dump:v6.8.1
        command: ["/bin/sh", "-c"]
        args: ["elasticdump --input=http://elasticsearch:9200/logstash-* --output=\$ | gzip > /tmp/esdump/dcs_logstash.json.gz"]
        volumeMounts:
        - name: shared-data
          mountPath: /tmp/esdump
      containers:
      - name: support-bundle-wait
        image: busybox:1.31
        command: ["sleep", "infinity"]
        volumeMounts:
        - name: shared-data
          mountPath: /tmp/esdump
EOF

limit=59
i=0
pod_name=""
while [ "$i" -le "$limit" ]; do
  i=$(($i+1))
  sleep 10
  kout=$(kubectl get pods -n datacore | grep support-bundle-elasticdump-job)
  echo $kout
  (echo $kout | grep -q Running) && match=1
  if [ "$match" = "1" ]; then
    pod_name=$(echo $kout | cut -f1 -d' ')
    break
  fi
done
if [ "$pod_name" = "" ]; then
  echo "Dumping logs timed out"
  exit 1
fi

kubectl cp -n datacore $pod_name:/tmp/esdump/$log_name $log_name

if [ -e "$log_name" ]; then
  echo "Logs written to $log_name"
else
  echo "Failed to copy logs"
  exit 1
fi
