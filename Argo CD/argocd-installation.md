## Step 1: Install Argo CD
```
kubectl create namespace argocd
```

```
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/v3.5.5/manifests/install.yaml
```

`--server-side` is required: some Argo CD resource definitions are too large for a
normal `kubectl apply`.

Wait until all pods are `Running` (Ctrl+C to stop watching):

```
kubectl get pods -n argocd -w
```


## Step 2: Open the web UI
Get the initial `admin` password:

```
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d; echo
```

Forward a local port to the UI (keep this terminal open):

```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open https://localhost:8080, accept the self-signed certificate warning, and log in as
`admin`.

`port-forward` creates no AWS resources, so it never blocks `terraform destroy`.
Avoid exposing the UI with a `LoadBalancer` Service: that creates an AWS load
balancer outside Terraform.



## Step 3: Deploy the product catalog with Argo CD
Argo CD manages only the product catalog. The other services are still deployed
with `kubectl` (see `notes.txt`).

Save as `Argo CD/product-catalog.yaml`:

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: product-catalog
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/DesmondYau/end-to-end-devops.git
    targetRevision: main
    path: kubernetes/productcatalog
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Commit it, then apply it once:

```
git add "Argo CD/cd-product-catelog.yaml"
git commit -m "Add Argo CD application for product catalog"
git push
kubectl apply -f "Argo CD/cd-product-catelog.yaml"
```

If the product catalog's Deployment and Service already exist (created earlier with
`kubectl`), Argo CD takes them over because the names match; nothing is recreated.
The app should show **Synced** and **Healthy** in the UI within a minute or two.

```
kubectl get applications -n argocd
```



## Step 4: Test the full CI/CD loop
1. On a new branch, change something in `src/product-catalog/`, push, open a pull
   request and merge it.
2. CI builds and pushes the image, then commits the new tag to
   `kubernetes/productcatalog/deploy.yaml`.
3. Argo CD checks Git about every 3 minutes and rolls out the change. Click
   **Refresh** on the app in the UI to check immediately.
4. Confirm the running image:

```
kubectl get deployment opentelemetry-demo-productcatalogservice \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```


## Notes

- To change the product catalog, change Git (commit + push). Manual `kubectl apply`
  or `kubectl edit` on it is undone by Argo CD (`selfHeal`).
- Nothing extra is needed before `terraform destroy`: Argo CD and the product catalog
  create no AWS resources and are removed together with the cluster.
- The full shutdown and rebuild sequence is in `notes.txt`.
