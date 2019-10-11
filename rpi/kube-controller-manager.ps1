$wsl_ip=wsl -- bash -c "ip addr | grep eth0 | grep inet | cut -d ' ' -f 6 | cut -d '/' -f 1"

$K8S_CM_HOST=$wsl_ip
# $K8S_ROOT='/opt/k8s'

$command=wsl -u root -- echo /opt/k8s/bin/kube-controller-manager `
--profiling `
--cluster-name=kubernetes `
--controllers=*,bootstrapsigner,tokencleaner `
--kube-api-qps=1000 `
--kube-api-burst=2000 `
--leader-elect `
--use-service-account-credentials `
--concurrent-service-syncs=2 `
--bind-address=${K8S_CM_HOST} `
--secure-port=10257 `
--tls-cert-file=${K8S_ROOT}/certs/kube-controller-manager.pem `
--tls-private-key-file=${K8S_ROOT}/certs/kube-controller-manager-key.pem `
--port=0 `
--authentication-kubeconfig=${K8S_ROOT}/conf/kube-controller-manager.kubeconfig `
--client-ca-file=${K8S_ROOT}/certs/ca.pem `
--requestheader-allowed-names="" `
--requestheader-client-ca-file=${K8S_ROOT}/certs/ca.pem `
--requestheader-extra-headers-prefix="X-Remote-Extra-" `
--requestheader-group-headers=X-Remote-Group `
--requestheader-username-headers=X-Remote-User `
--authorization-kubeconfig=${K8S_ROOT}/conf/kube-controller-manager.kubeconfig `
--cluster-signing-cert-file=${K8S_ROOT}/certs/ca.pem `
--cluster-signing-key-file=${K8S_ROOT}/certs/ca-key.pem `
--experimental-cluster-signing-duration=876000h `
--horizontal-pod-autoscaler-sync-period=10s `
--concurrent-deployment-syncs=10 `
--concurrent-gc-syncs=30 `
--node-cidr-mask-size=24 `
--service-cluster-ip-range=10.254.0.0/16 `
--pod-eviction-timeout=6m `
--terminated-pod-gc-threshold=10000 `
--root-ca-file=${K8S_ROOT}/certs/ca.pem `
--service-account-private-key-file=${K8S_ROOT}/certs/ca-key.pem `
--kubeconfig=${K8S_ROOT}/conf/kube-controller-manager.kubeconfig `
--logtostderr=true `
--v=2

mkdir -Force $PSScriptRoot/supervisor.d | out-null

echo "[program:kube-controller-manager]

command=$command
stdout_logfile=/opt/k8s/log/kube-controller-manager-stdout.log
stderr_logfile=/opt/k8s/log/kube-controller-manager-error.log
directory=/
autostart=false
autorestart=false
startretries=10
user=root
startsecs=60" > $PSScriptRoot/supervisor.d/kube-controller-manager.ini


if($args[1] -eq 'start'){
  wsl -u root -- bash -c $command
}
