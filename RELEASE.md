# Releasing NLK

## Releasing a version to our internal dockerhub registry  

- Go to the [NLK repo](https://gitlab.com/f5/nginx/nginxazurelb/nginxaas-loadbalancer-kubernetes).

- [Create a new tag](https://gitlab.com/f5/nginx/nginxazurelb/nginxaas-loadbalancer-kubernetes/-/tags/new).

- Give the tag the name of the version to be released, e.g. "v1.1.1". This should match the version in the `version` file at the root of the repo.

- Under **Create from** select the branch from which the image will be created.

- Hit **Create tag**.

## Releasing a version to Azure Marketplace

This workflow requires Azure Marketplace permissions which few members of NGINXaaS possess (currently Ken, Ashok and Ryan).

- Complete the steps above to publish the image internally.

- Go to "Marketplace Offers"

- Click on "F5 NGINX LoadBalancer for Kubernetes"

- Under "Plan overview" select the plan which has a "Live" status (this should be "F5 NGINXaaS AKS Extension")

- On a panel on the left hand side, select "Technical Configuration"

- A pop up appears.
  - Under "Registry" select the "nlbmarketplaceacrprod" option
  - Under "Repo" select "marketplace/nginxaas-loadbalancer-kubernetes"
  - Under "CNAB Bundle" select the version you wish to publish

- To complete the publishing of the image click "Add CNAB Button" button on the bottom of the popup.

- Select "Save draft".

- This should take you to a "Review and Publish" screen. If the UI seems to stall. Follow steps below.

  - Next to "Marketplace offers" on the top of the screen, select "F5 NGINX Loadbalancer for Kubernetes".

  - Select "Offer overview" from the panel on the left.

  - Next to the heading "F5 NGINX Loadbalancer for Kubernetes | Offer Overview" select "Review and publish"

- A number of items should appear, but they must include "F5 NGINXaaS AKS extenstion". Leave all items as they are.

- Then click "Publish".

- This will take a while. Check in on it after 24 hours.
