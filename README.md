# Cloud-Resume (AWS Edition)

> Setting up an entirely server-less, IaC-driven stack to host my résumé – **אחושרמוטה** fast, scalable and almost free.

[![Deploy](https://github.com/shmador/cloud-resume/actions/workflows/deploy.yml/badge.svg)](../../actions)

---

## Why this project?

The classic **[Cloud Resume Challenge](https://cloudresumechallenge.dev)** proves real‑world cloud skills by shipping a static résumé site that

* lives behind HTTPS and a custom domain  
* counts visitors in a durable, server‑less database  
* is provisioned end‑to‑end with Infrastructure‑as‑Code  
* ships automatically with CI/CD

This repository is my take on the challenge using **AWS**, **Terraform**, and **GitHub Actions**, written so anyone can fork and adapt in a few minutes. **אחושלוקי**, let’s dive in.

---

## High‑level architecture

```mermaid
flowchart TD
    A[Route 53
DNS] --> B(CloudFront CDN)
    B --> C[S3 Static Site
(bucket: dor-resume)]
    B -->|/api/*| D(API Gateway)
    D --> E(Lambda Function)
    E --> F[DynamoDB
Table: dor-resume]
    classDef aws fill:#232F3E,stroke:#fff,color:#fff
    class A,B,C,D,E,F aws
```

| Component | Purpose |
|-----------|---------|
| **S3** | Stores static HTML/CSS/JS for the résumé |
| **CloudFront** | Global CDN and TLS termination (ACM certificate in `us-east-1`) |
| **Route 53** | `A/AAAA` records for the domain pointing to the CloudFront distribution |
| **API Gateway** | Minimal REST interface (`GET /visitors`, `POST /visitors`) |
| **Lambda** | Python 3.10 function that bumps and returns the visitor counter |
| **DynamoDB** | Durable counter table (`id` = `VISITOR_ID`) |
| **GitHub Actions** | Separate pipelines for Terraform and the front‑end |

---

## Repository layout

```
cloud-resume/
├── .github/workflows/    # CI/CD pipelines (Terraform & static site)
├── bootstrap/            # One‑shot script to create remote TF state
├── environments/         # *.tf files – split by service
│   ├── s3.tf
│   ├── cloudfront.tf
│   ├── api.tf
│   └── iam.tf
├── src/
│   ├── front/            # index.html, styles, visitor.js template
│   └── back/
│       ├── lambda_function.py
│       └── requirements.txt
└── README.md             # You are here
```

---

## Getting started

1. **Clone and configure AWS credentials**

   ```bash
   git clone https://github.com/shmador/cloud-resume.git
   cd cloud-resume
   export AWS_PROFILE=myprofile   # or use env vars / OIDC
   ```

2. **Bootstrap remote Terraform state (one‑off)**  

   ```bash
   ./bootstrap/bootstrap.sh   # creates state bucket & DynamoDB lock table
   ```

3. **Deploy the stack**

   ```bash
   cd environments
   terraform init -backend-config="bucket=dor-resume-tfstate"
   terraform apply -var="domain_name=doratar.com" -auto-approve
   ```

4. **Publish the résumé**

   Edit anything in `src/front/`, then push to `main`. The `frontend.yml` workflow lints, minifies, uploads to S3, and invalidates CloudFront automatically.

---

## CI / CD details

| Workflow | Trigger | Actions |
|----------|---------|---------|
| **`terraform.yml`** | Push to `main` or pull request | `terraform fmt` and `terraform validate`, followed by `terraform apply` (auto‑approved on `main`). Uses OIDC to assume a tightly scoped IAM role. |
| **`frontend.yml`** | Changes in `src/front/**/*` | Renders `visitor.js.tpl` (injects API Gateway URL and table name), runs `aws s3 sync`, then calls CloudFront `CreateInvalidation`. |

---

## Local development

* **Static site** – any live‑reload server works:

  ```bash
  cd src/front && npx serve .
  ```

* **Lambda** – run and debug with the AWS SAM CLI:

  ```bash
  sam local invoke -e events/GET-visitors.json
  ```

---

## Cost considerations

* S3 and DynamoDB often stay in the free tier for light traffic.  
* CloudFront: first 1 TB/month is free for the first year.  
* Lambda and API Gateway invocations cost fractions of a cent.  
* Route 53 hosted zone ≈ 0.50 USD/month plus 0.40 USD per million queries.

Destroy everything with `terraform destroy` when finished.

---

## Road‑map

* Visitor counter (done)  
* GitHub OAuth “Hire me” button  
* Automated accessibility tests (Lighthouse CI)  
* Multi‑region replication with S3 CRR and Route 53 latency records  
* Switch to AWS CDK v3 once generally available  

Pull requests are welcome.

---

## License

```
MIT © Dor Attar – 2025
```
