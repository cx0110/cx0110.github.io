---
title: "Pod 生命周期和探针"
subtitle: "Kubernetes Pod 状态管理与健康检查"
summary: "深入了解 Kubernetes Pod 的生命周期、状态管理、探针配置和重启策略"
authors:
  - admin
tags:
  - Kubernetes
  - Pod
  - 探针
  - 生命周期
categories:
  - Cloud Native
date: 2022-02-24T08:35:11+08:00
lastmod: 2025-12-24T10:00:00+08:00
featured: false
draft: false
image:
  filename: kubernetes-logo.svg
  focal_point: Smart
  preview_only: false
---

# Pod 生命周期和探针

## [1. Pod 的状态和探针](https://kubernetes.io/zh/docs/concepts/workloads/pods/pod-lifecycle/)

### 1.1 Pod 状态

- 第⼀阶段：

  - Pending:

    #正在创建Pod但是Pod中的容器还没有全部被创建完成=[处于此状态的Pod应该检查Pod依赖的存储是否有权限挂载、镜像是否可以下载、调度是否正常等。

  - Failed

    #Pod中有容器启动失败⽽导致pod⼯作异常。

  - Unknown

    #由于某种原因⽆法获得pod的当前状态，通常是由于与pod所在的node节点通信错误。

  - Succeeded

    #Pod中的所有容器都被成功终⽌即pod⾥所有的containers均已terminated。

- 第⼆阶段：
  
    - Unschedulable：
    
      #Pod不能被调度，kube-scheduler没有匹配到合适的node节点
    
    - PodScheduled
    
      #pod正处于调度中，在kube-scheduler刚开始调度的时候，还没有将pod分配到指定的node，在筛选出合适的节点后就会更新etcd数据，将pod分配到指定的node
    
    - Initialized
    
      #所有pod中的初始化容器已经完成了
    
    - ImagePullBackOff：
    
      #Pod所在的node节点下载镜像失败
      
    - Running
    
      #Pod内部的容器已经被创建并且启动。
    
    - Ready
      #表示pod中的容器已经可以提供访问服务

```json
Error: #pod 启动过程中发⽣错误
NodeLost: #Pod 所在节点失联
Unkown: #Pod 所在节点失联或其它未知异常
Waiting: #Pod 等待启动
Pending: #Pod 等待被调度
Terminating: #Pod 正在被销毁
CrashLoopBackOff：#pod，但是kubelet正在将它重启
InvalidImageName：#node节点⽆法解析镜像名称导致的镜像⽆法下载
ImageInspectError：#⽆法校验镜像，镜像不完整导致
ErrImageNeverPull：#策略禁⽌拉取镜像，镜像中⼼权限是私有等
ImagePullBackOff：#镜像拉取失败，但是正在重新拉取
RegistryUnavailable：#镜像服务器不可⽤，⽹络原因或harbor宕机
ErrImagePull：#镜像拉取出错，超时或下载被强制终⽌
CreateContainerConfigError：#不能创建kubelet使⽤的容器配置
CreateContainerError：#创建容器失败
PreStartContainer： #执⾏preStart hook报错，Pod hook(钩⼦)是由 Kubernetes 管理的 kubelet 发起的，当容器中的进程启动前或者容器中的进程终⽌之前运⾏，⽐如容器创建完成后⾥⾯的服务启动之前可以检查⼀下依赖的其它服务是否启动，或者容器退出之前可以把容器中的服务先通过命令停⽌。
PostStartHookError：#执⾏ postStart hook 报错
RunContainerError：#pod运⾏失败，容器中没有初始化PID为1的守护进程等
ContainersNotInitialized：#pod没有初始化完毕
ContainersNotReady：#pod没有准备完毕
ContainerCreating：#pod正在创建中
PodInitializing：#pod正在初始化中
DockerDaemonNotReady：#node节点decker服务没有启动
NetworkPluginNotReady：#⽹络插件还没有完全启动
```

### 1.2 Pod 调度过程

### [1.3 Pod 探针](https://kubernetes.io/zh/docs/concepts/workloads/pods/pod-lifecycle/%23%E5%AE%B9%E5%99%A8%E6%8E%A2%E9%92%88)

#### 1.3.1 探针简介

- 探针 是由 kubelet 对容器执⾏的定期诊断，以保证Pod的状态始终处于运⾏状态，要执⾏诊断，kubelet 调⽤由容器实现的Handler(处理程序)，有三种类型的处理程序：

  ```json
  ExecAction
  #在容器内执⾏指定命令，如果命令退出时返回码为0则认为诊断成功。
  TCPSocketAction
  #对指定端⼝上的容器的IP地址进⾏TCP检查，如果端⼝打开，则诊断被认为是成功的。
  HTTPGetAction
  #对指定的端⼝和路径上的容器的IP地址执⾏HTTPGet请求，如果响应的状态码⼤于等于200且⼩于 400，则诊断被认为是成功的。
  ```

- 每次探测都将获得以下三种结果之⼀：

  ```json
  成功：容器通过了诊断。
  失败：容器未通过诊断。
  未知：诊断失败，因此不会采取任何⾏动。
  ```

#### 1.3.2 配置探针

> 基于探针实现对Pod的状态检测

#### 1.3.2.1 探针类型

- livenessProbe
  #存活探针，检测容器容器是否正在运⾏，如果存活探测失败，则kubelet会杀死容器，并且容器将受到其重启策略的影响，如果容器不提供存活探针，则默认状态为 Success，livenessProbe⽤于控制是否重启pod。
- readinessProbe
  #就绪探针，如果就绪探测失败，端点控制器将从与Pod匹配的所有Service的端点中删除该Pod的IP地址，初始延迟之前的就绪状态默认为Failure(失败)，如果容器不提供就绪探针，则默认状态为 Success，readinessProbe⽤于控制pod是否添加⾄service。

#### [1.3.2.2 探针配置](https://kubernetes.io/zh/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

- 探针有很多配置字段，可以使⽤这些字段精确的控制存活和就绪检测的⾏为：

  ```json
  initialDelaySeconds: 120
  #初始化延迟时间，告诉kubelet在执⾏第⼀次探测前应该等待多少秒，默认是0秒，最⼩值是0
  periodSeconds: 60
  #探测周期间隔时间，指定了kubelet应该每多少秒秒执⾏⼀次存活探测，默认是 10 秒。最⼩值是 1
  timeoutSeconds: 5
  #单次探测超时时间，探测的超时后等待多少秒，默认值是1秒，最⼩值是1。
  successThreshold: 1
  #从失败转为成功的重试次数，探测器在失败后，被视为成功的最⼩连续成功数，默认值是1，存活探测的这个值必须是1，最⼩值是 1。
  failureThreshold： 3
  #从成功转为失败的重试次数，当Pod启动了并且探测到失败，Kubernetes的重试次数，存活探测情况下的放弃就意味着重新启动容器，就绪探测情况下的放弃Pod 会被打上未就绪的标签，默认值是3，最⼩值是1。
  ```

- HTTP 探测器可以在 httpGet 上配置额外的字段：

  ```json
  host:
  #连接使⽤的主机名，默认是Pod的 IP，也可以在HTTP头中设置 “Host” 来代替。
  scheme: http
  #⽤于设置连接主机的⽅式（HTTP 还是 HTTPS），默认是 HTTP。
  path: /monitor/index.html
  #访问 HTTP 服务的路径。
  httpHeaders:
  #请求中⾃定义的 HTTP 头,HTTP 头字段允许重复。
  port: 80
  #访问容器的端⼝号或者端⼝名，如果数字必须在 1 ～ 65535 之间。
  ```

#### 1.3.2.3 HTTP探针示例

```yaml
# cat nginx.yaml
#apiVersion: extensions/v1beta1
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
	matchLabels: #rs or deployment
	  app: ng-deploy-80
	#matchExpressions:
	# - {key: app, operator: In, values: [ng-deploy-80,ng-rs-81]}
  template:
	metadata:
	  labels:
		app: ng-deploy-80
	spec:
	  containers:
	  - name: ng-deploy-80
		image: nginx:1.17.5
		ports:
		- containerPort: 80
		#readinessProbe:
		livenessProbe:
		  httpGet:
			#path: /monitor/monitor.html
			path: /index.html
			port: 80
		initialDelaySeconds: 5
		periodSeconds: 3
		timeoutSeconds: 5
		successThreshold: 1
		failureThreshold: 3
---
apiVersion: v1
kind: Service
metadata:
  name: ng-deploy-80
spec:
  ports:
  - name: http
	port: 81
	targetPort: 80
	nodePort: 40012
	protocol: TCP
  type: NodePort
  selector:
	app: ng-deploy-80
```

#### 1.3.2.4 TCP探针示例

```yaml
# cat nginx.yaml
#apiVersion: extensions/v1beta1
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
  matchLabels: #rs or deployment
	app: ng-deploy-80
	#matchExpressions:
	# - {key: app, operator: In, values: [ng-deploy-80,ng-rs-81]}
  template:
	metadata:
	  labels:
	    app: ng-deploy-80
	spec:
	  containers:
	  - name: ng-deploy-80
		image: nginx:1.17.5
		ports:
		- containerPort: 80
		livenessProbe:
		#readinessProbe:
		  tcpSocket:
			port: 80
     	    #port: 8080
			initialDelaySeconds: 5
			periodSeconds: 3
			timeoutSeconds: 5
			successThreshold: 1
			failureThreshold: 3
---
apiVersion: v1
kind: Service
metadata:
  name: ng-deploy-80
spec:
  ports:
  - name: http
	port: 81
	targetPort: 80
	nodePort: 40012
	protocol: TCP
  type: NodePort
  selector:
	app: ng-deploy-80
```

#### 1.3.2.5：ExecAction探针

> 可以基于指定的命令对 Pod 进行特定的状态检查

```yaml
# docker pull redis

# cat redis.yaml
# apiVersion: extensions/v1beta1
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-deployment
spec:
  replicas: 1
  selector:
    matchLabels: #rs or deployment
      app: redis-deploy-6379
    # matchExpressions:
    # - {key: app, operator: In, values: [redis-deploy-6379,ns-rs-81]}
  template:
    metadata:
      labels:
        app: redis-deploy-6379
    spec:
      containers:
      - name: redis-deploy-6379
        image: redis
        ports:
        - containerPort: 6379
        livenessProbe:
        # readinessProbe:
          exec:
            command:
            # - /apps/redis/bin/redis-cli
            - /usr/local/bin/redis-cli
            - /quit
          initialDelaySeconds: 5
          periodSeconds: 3
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 3
---
apiVersion: v1
kind: Service
metadata:
  name: redis-deploy-6379
spec:
  ports:
  - name: http
    port: 6379
    targetPort: 6379
    nodePort: 40016
    protocol: TCP
  type: NodePort
  selector:
    app: redis-deploy-6379
```

#### 1.3.2.6 livenessProbe 和 readinessProbe 对比

- 配置参数一样

- livenessProbe 连续探测失败会重启、重建 Pod ，redinessProbe 不会执行重启或者重建 Pod 操作

- livenessProbe 连续检测指定次数失败后会将容器置于（Crash Loop BackOff）且不可用，readinessProbe 不会

- livenessProbe 连续探测失败会从 service 的 endpointd 中删除该 Pod ，livenessProbe 不具备次功能，但是会将容器挂起 livenessProbe

- livenessProbe 用户控制是否重启 Pod ，readinessProbe 用于控制 Pod 是否添加至 service

- 建议： 两个探针都配置

  

### 1.4 Pod 重启策略

- Kubernetes 在 Pod 出现异常的时候会自动将 Pod 重启以恢复 Pod 中的服务

  restartPolicy:

  - Always:：当容器异常时，k8s 自动重启该容器，ReplicationController/Replicaset/Deployment
  - OnFailure：当容器失败时（容器停止运行且退出码不为 0），k8s 自动重启该容器
  - Never：不论容器运行状态如何都不会重启该容器，Job 或 Cronjob

  示例：

  ```yaml
      containers:
      - name: tomcat-app1-container
        image: harbor.1ch0.local/1ch0/tomcat-app1:v1
        # command: ["/apps/tomcat/bin/run_tomcat.sh"]
        # imagePullPolicy: IfNotPresent
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
          protocol: TCP
          name: http
        env:
        - name: "password"
          value: "123456"
        - name: "age"  
          value: "18"
        resources:
          limits:
            cpu: 1
            memory: "512Mi"
          requests:
            cpu: 500m
            memory: "512Mi"
       restartPolicy: Always   
  ```

## [1.5 镜像拉取策略](https://kubernetes.io/zh/docs/concepts/configuration/overview/)

  ```json
  imagePullPolicy: IfNotPresent # node 节点没有此镜像就去指定的镜像仓库拉取，node 有就是用 node 本地镜像
  imagePullPolicy: Always # 每次重建 Pod 都会重新拉取镜像
  imagePullPolicy: Never # 从不到镜像中心拉取镜像，只使用本地镜像
  ```

