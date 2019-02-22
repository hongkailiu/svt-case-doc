# OCP 4: doc list

Thanks to Jiri

## gdoc (rh internal)

* [OpenShift 4 Terminology](https://docs.google.com/document/d/1bRuZcLzgK3w-nVABu3ylu_37XTtsG-255hFJ7Zh8-lI/edit)
* [OpenShift 4 Goals](https://docs.google.com/document/d/16JwTljY3lD3J7j-BHJByu117dRyCx03hY5exPfKMKJE/edit?ts=5b98e90d#)
* [OpenShift 4 Automated Testing](https://docs.google.com/document/d/1sn_r8QwchNLnOJRpg4M4shWzYSQ3Aif2KEIXl37JP6Q/edit)
    * How to add an e2e operator CI job to your operator repo
* [OpenShift 4 CI and Release Flow
](https://docs.google.com/document/d/1PAHSF86Un6CdG7STX-vIGbrgjVTnVpDOSBplos0U8Rk/edit?ts=5ba3d3e3)
* [OpenShift 4 - Core Update Design](https://docs.google.com/document/d/1SoIcId9VjbgXtOJ1PK1qP6uz79Qyf0AgobubnxAo9M8)
* [Content distribution and OTA in converged platform](https://docs.google.com/document/d/19nqtRuyEf1qxqxlcINkp6RNNdXjg4gX6xaGX5cUfEdM/edit)
* [ClusterOperator Versioning](https://docs.google.com/document/d/1YV_rJ6qR46_DV1s6RwobTYHX0CCE4CIBnt_VRPtN8Nw/edit#heading=h.j35cxjc8vibg)
* [OpenShift 4 Release Image and Release Payload](https://docs.google.com/document/d/1CGZVEyuloZ9oD4NUArW6dnEpi0WFc6BP2tqPSwFZTCY/edit#heading=h.1zgrwxmpgxbr)
    * How do we test an operator as part of an install in a PR CI job?
    * How do I try out the release process for local iteration?
* [Cincinnati in OpenShift](https://docs.google.com/document/d/1TMV_1qNMmobhFfV0iVY67Bv9c-9woUWtxDRk4vb5m-U/edit#heading=h.du4f4lkqahc8)
    

## Terminology

* Update/Release Payload: The information the cluster update operator needs to update itself and the other components.  Typically this is a versioned set of manifests that reference Kubernetes deployments containing known image version numbers.

    ```
    ### to show all the images in a release
    $ oc adm release info --pullspecs registry.svc.ci.openshift.org/ocp/release:4.0.0-0.nightly-2019-02-20-194410
    ```


* Cluster Version Operator (CVO): 

    * [The Cluster Version Operator](https://github.com/openshift/cluster-version-operator/), an instance of which runs in every cluster, is in charge of performing updates to the cluster. 

    * The operator that downloads and keeps all components on the cluster up to date (sets the cluster to a specific version). It delegates most details to second level operators (one for Kubernetes control plane, one for networking, etc) in order to reduce the amount of possible failures.

    ```
    # oc adm upgrade -h

    ```
