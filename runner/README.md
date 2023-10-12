# Install gitlab runner

## version

- gitlab: 14.10.5
- runner: alpine3.15-v14.10.1

## set up

- replace $URL $TOKEN in value.yml

```bash
helm repo add gitlab https://charts.gitlab.io
kubectl -n gitlab create secret generic runner.crt --from-file=./runner.crt
helm install -n gitlab gitlab-runner gitlab/gitlab-runner -f values.yml
```


