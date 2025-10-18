running minikube on my lan machine:
- debian 13
- ip: 192.168.179.229
- ssh user: pl
- deployed airbyte 1.7 with helm
- python 3.13, 3.14
- using poetry

developing Airbyte custom connector on local machine:
- macos using brew
- python 3.13, 3.14
- using poetry

airbyte web ui
- http://127.0.0.1:8080/
- http://192.168.179.229:8080/

minikube dashboard:
- http://192.168.179.229:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/#/workloads?namespace=airbyte-v2