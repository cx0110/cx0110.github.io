---
authors:
- admin
---


```yaml
apiVersion: v1
items:
- apiVersion: v1
  kind: Pod
  metadata:
    annotations:
      cni.projectcalico.org/containerID: d73fd0c8bc007ffa9a8fc0f9c17ace79927da6fc893ed069b11fdbf2e7e7d047
      cni.projectcalico.org/podIP: 192.168.113.132/32
      cni.projectcalico.org/podIPs: 192.168.113.132/32
    creationTimestamp: "2022-02-28T03:45:09Z"
    generateName: nginx-deployment-57586646f7-
    labels:
      app: nginx
      pod-template-hash: 57586646f7
    name: nginx-deployment-57586646f7-mklkz
    namespace: default
    ownerReferences:
    - apiVersion: apps/v1
      blockOwnerDeletion: true
      controller: true
      kind: ReplicaSet
      name: nginx-deployment-57586646f7
      uid: 3e017427-ec45-4181-a53a-a999155c47ba
    resourceVersion: "283233"
    uid: aa832bd9-f398-4263-8c7b-a9aea1d0e16f
  spec:
    containers:
    - image: nginx
      imagePullPolicy: Always
      name: nginx
      readinessProbe:
        exec:
          command:
          - cat
          - /tmp/healthy
        failureThreshold: 3
        initialDelaySeconds: 5
        periodSeconds: 5
        successThreshold: 1
        timeoutSeconds: 1
      resources: {}
      terminationMessagePath: /dev/termination-log
      terminationMessagePolicy: File
      volumeMounts:
      - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
        name: kube-api-access-65stl
        readOnly: true
    dnsPolicy: ClusterFirst
    enableServiceLinks: true
    nodeName: k8s-node
    preemptionPolicy: PreemptLowerPriority
    priority: 0
    restartPolicy: Always
    schedulerName: default-scheduler
    securityContext: {}
    serviceAccount: default
    serviceAccountName: default
    terminationGracePeriodSeconds: 30
    tolerations:
    - effect: NoExecute
      key: node.kubernetes.io/not-ready
      operator: Exists
      tolerationSeconds: 300
    - effect: NoExecute
      key: node.kubernetes.io/unreachable
      operator: Exists
      tolerationSeconds: 300
    volumes:
    - name: kube-api-access-65stl
      projected:
        defaultMode: 420
        sources:
        - serviceAccountToken:
            expirationSeconds: 3607
            path: token
        - configMap:
            items:
            - key: ca.crt
              path: ca.crt
            name: kube-root-ca.crt
        - downwardAPI:
            items:
            - fieldRef:
                apiVersion: v1
                fieldPath: metadata.namespace
              path: namespace
  status:
    conditions:
    - lastProbeTime: null
      lastTransitionTime: "2022-02-28T03:45:09Z"
      status: "True"
      type: Initialized
    - lastProbeTime: null
      lastTransitionTime: "2022-02-28T03:49:39Z"
      status: "True"
      type: Ready
    - lastProbeTime: null
      lastTransitionTime: "2022-02-28T03:49:39Z"
      status: "True"
      type: ContainersReady
    - lastProbeTime: null
      lastTransitionTime: "2022-02-28T03:45:09Z"
      status: "True"
      type: PodScheduled
    containerStatuses:
    - containerID: docker://e25d12c597bc122021f6591a76a4d3c284ff3a77da2276a694f8ba8ceedc374b
      image: nginx:latest
      imageID: docker-pullable://nginx@sha256:0d17b565c37bcbd895e9d92315a05c1c3c9a29f762b011a10c54a66cd53c9b31
      lastState: {}
      name: nginx
      ready: true
      restartCount: 0
      started: true
      state:
        running:
          startedAt: "2022-02-28T03:45:25Z"
    hostIP: 172.21.0.117
    phase: Running
    podIP: 192.168.113.132
    podIPs:
    - ip: 192.168.113.132
    qosClass: BestEffort
    startTime: "2022-02-28T03:45:09Z"
kind: List
metadata:
  resourceVersion: ""
  selfLink: ""

```