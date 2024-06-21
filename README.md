# grpc_web_proxy

## Set Environment Variables

You can set these to whatever you want.

```sh
export WORKLOAD_IDENTITY_POOL=github-actions-pool
export WORKLOAD_PROVIDER=github-actions-oidc
export LOCATION=global
export PROJECT_NUMBER=<your-project-number>
export PROJECT_ID=<your-project-id>
export SERVICE_ACCOUNT_NAME=envoy-app-sa
export REPOSITORY_OWNER=<your-github-org-or-username>
export REPOSITORY_NAME=<your-github-repo-name>
```

## Create a workload identity pool

```sh
gcloud iam workload-identity-pools create ${WORKLOAD_IDENTITY_POOL} \               
--location="${LOCATION}" \                           
--description="The pool to authenticate GitHub actions." \
--display-name="GitHub Actions Pool"
```

## Create a workload identity pool provider

```sh
gcloud iam workload-identity-pools providers create-oidc ${WORKLOAD_PROVIDER} \
--workload-identity-pool="${WORKLOAD_IDENTITY_POOL}" \
--issuer-uri="https://token.actions.githubusercontent.com/" \
--attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner,attribute.branch=assertion.sub.extract('/heads/{branch}/')" \
--location=${LOCATION} \
--attribute-condition="assertion.repository_owner=='${REPOSITORY_OWNER}'"
```

## Create a service account

```sh
gcloud iam service-accounts create ${SERVICE_ACCOUNT_NAME} --display-name="Envoy Proxy" --description="proxies grpc-web to grpc" 
```

## Add IAM bindings for the workload pool

```sh
gcloud iam service-accounts add-iam-policy-binding ${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \
--role="roles/iam.workloadIdentityUser" \
--member="principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/${LOCATION}/workloadIdentityPools/${WORKLOAD_IDENTITY_POOL}/subject/repo:${REPOSITORY_OWNER}/${REPOSITORY_NAME}:ref:refs/heads/main"
```

## Secrets

WORKLOAD_IDENTITY_PROVIDER:

```sh
echo projects/${PROJECT_NUMBER}/locations/${LOCATION}/workloadIdentityPools/${WORKLOAD_IDENTITY_POOL}/providers/${WORKLOAD_PROVIDER}
```

SERVICE_ACCOUNT_EMAIL:

```sh
echo ${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com
```

## Create a new release to initiate GitHub Actions workflow

- From the GitHub repository page, click on "Releases"
- Click on "Draft a new release"
- Under "Choose a tag", create a new tag
- Click "Publish release"
