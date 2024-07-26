
### New Version: 5.0.15

### Old Version: 4.5.8


1. Install old version, it should working, running. <---- Upgrade 5.0.15 <------ It works as in their dev env
     																		|___ It fail in a different
  																			|___ It fail the same way <----------------- Root causing the issue.


* STEP ONE: CREATION OF THE FILE

```shell

kustomize build github.com/minio/operator/resources/\?ref\=v4.5.8 > operator-4-5-8.yaml <-------------
kustomize build github.com/minio/operator/examples/kustomization/tenant-lite\?ref\=v4.5.8 > tenant-4-5-8.yaml

```

* STEP TWO: DEPLOYMENT OF THE FILE

```shell
kubectl apply -f operator-4-5-8.yaml <----- deployed done!
kubectl apply -f tenant-4-5-8.yaml
```

2. Install new version (5.0.15), hack the config to hit issue <----------------- You sort of know it can be reproduced by misconfiguration <--- shortcut


3. Ask a call, and work with them <--------------------------------------------- Ask ECO, when to join?

---

4. When you are already too crazy!!! < 12 1 am 2 am <---------------------------- Too tired!. I am useless!.