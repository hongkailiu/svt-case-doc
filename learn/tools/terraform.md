# [Terraform](https://www.terraform.io/)

* [intro](https://www.terraform.io/intro/index.html), [doc](https://www.terraform.io/docs/index.html)
* [terraform@gh](https://github.com/hashicorp/terraform)

## [Installation](https://www.terraform.io/intro/getting-started/install.html)

```bash
$ curl -LO https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip
$ unzip terraform_0.11.10_linux_amd64.zip 

$ cd ~/bin
$ ln -s ../terraform_0.11.10/terraform terraform
$ terraform --version
Terraform v0.11.10

###https://github.com/hongkailiu/svt-case-doc/tree/master/files/terraform/hello
$ cd ~/svt-case-doc/files/terraform/hello

$ terraform init -var-file="secret.tfvars"
### change the values in secret.tfvars before the following command
$ terraform apply -var-file="secret.tfvars" -auto-approve
$ terraform show
$ terraform destroy -var-file="secret.tfvars" -auto-approve

```

Terraform Ansible provisioner: Not yet supported natively. See
* https://alex.dzyoba.com/blog/terraform-ansible/
* https://nicholasbering.ca/tools/2018/01/08/introducing-terraform-provider-ansible/
* parse the results of `cat terraform.tfstate`

Qs:

* How does OCP installer use terraform?

## tf file format

* [configuration syntax](https://www.terraform.io/docs/configuration/syntax.html) and [interpolation syntax](https://www.terraform.io/docs/configuration/interpolation.html)

* involve history: [nginx configuration file format](https://nginx.org/en/docs/beginners_guide.html#conf_structure)
    &#10168;
  [libucl](https://github.com/vstakhov/libucl)
    &#10168;
  [hil](https://github.com/hashicorp/hil)/[hcl](https://github.com/hashicorp/hcl)

* [syntax of hcl](https://github.com/hashicorp/hcl#syntax): see list and multi-line string

## modules

* [intro](https://www.terraform.io/intro/getting-started/modules.html) and [doc](https://www.terraform.io/docs/modules/index.html) 

TODO

## [best practice](https://www.terraform.io/docs/enterprise/guides/recommended-practices/index.html)
TODO

Understand tf plan. Count 1 to 2: why destroy 1 and create 2?

## more reading

* [k8s as terraform provider](https://medium.com/@fabiojose/platform-as-code-with-openshift-terraform-1da6af7348ce): Use terraform to provision k8s resources

* [terraform-aws-openshift](https://github.com/dwmkerr/terraform-aws-openshift): Use terraform to create OCP cluster
