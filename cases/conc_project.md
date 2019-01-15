# Concurrent Projects Test
Create certain number of new projects as admin at the same time. The concurrent number start from 5 and increase by 10 during the test.

## Manual steps
Copy kube conf file to ~/.kube directory


```bash
cp $KUBECONFIG $HOME/.kube/config
```

Change directory where script is:

```bash
cd $HOME/svt/openshift_performance/ci/scripts
```

Run test script

```bash
./conc_proj.sh
```