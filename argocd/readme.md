# Bootstrapping argocd

Meant for one time bootstrapping of argocd. 
Argo will afterwards manage itself through GitOps.


## 01 ssh keygen for private github repo

```sh
ssh-keygen -t ed25519 -C "argocd@test" -f ../local/test -N ""
cat ../local/gitops_repo_deploy_key.pub   
# add as a read-only Deploy Key on the GitHub repo (Settings > Deploy keys)
```

# 02 deploy
run terraform plan and apply

# 03 get access to argo
if you have not set anything else up in the cluster yet:

### get password
```
kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```
### get access to service 
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```