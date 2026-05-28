# Week 9 Security Audit — cis410-deploy-sa

**Project:** cis410-asefa
**Date:** May 28, 2026
**Auditor:** Asefa Belete

---

## 1. IAM Audit Results

### Before — Week 8 Configuration (over-permissioned)

| Role | Scope | Problem |
|---|---|---|
| roles/run.admin | Project | Overly broad — grants ability to delete services and modify IAM, not just deploy |
| roles/storage.admin | Project | Overly broad — grants access to ALL GCS buckets in the project |
| roles/artifactregistry.writer | Project | Acceptable — scoped to push images only |
| roles/viewer | Project | Acceptable — read-only project metadata |
| roles/iam.serviceAccountUser | Compute SA | Required — needed to act as Compute Engine default SA |

### After — Week 9 Least-Privilege Fix

| Role | Scope | Why Sufficient |
|---|---|---|
| roles/run.developer | Project | Deploy only — cannot delete services or modify IAM |
| roles/storage.admin | tfstate bucket only | Scoped to one bucket — not all storage |
| roles/artifactregistry.writer | Project | Unchanged — push images only |
| roles/viewer | Project | Unchanged — read project metadata |
| roles/iam.serviceAccountUser | Compute SA | Unchanged — required for Cloud Run deployment |

---

## 2. Secret Manager Migration

- **Secret created:** `flask-app-secret`
- **Replication:** automatic
- **Access granted to:** `cis410-deploy-sa` — roles/secretmanager.secretAccessor on this secret only
- **Access granted to:** `PROJECT_NUMBER-compute@developer.gserviceaccount.com` — roles/secretmanager.secretAccessor on this secret only (required for Cloud Run runtime access)
- **Cloud Run update:** APP_SECRET environment variable mounted from Secret Manager at runtime

---

## 3. Monitoring Configuration

- **Log-based alert:** `cis410-flask-app-alert` — fires on severity>=WARNING for cis410-flask-app
- **Notification channel:** AsefaBelete@students.highline.edu
- **Billing budget:** `cis410-monthly-budget` — $20 limit, alerts at 50% / 90% / 100%

---

## 4. Reflection

**Q1: Why is roles/run.admin inappropriate for a CI/CD pipeline service account?**

Using `roles/run.admin` violates the principle of least privilege because it gives the automation pipeline full control over the service lifecycle, including the ability to permanently delete deployed apps and alter core IAM security settings. A compromised CI/CD pipeline with these permissions could lead to unauthorized access modification or intentional service disruption. Restricting the automation role to `roles/run.developer` ensures it can only build and update revisions without exposing dangerous management privileges.

---

**Q2: What is the security difference between storing a secret in GitHub Secrets vs. Google Secret Manager?**

GitHub Secrets protect data primarily while it is at rest inside the repository toolset and injects them as raw environment variables during build time, which can risk exposing values in logs or configuration dumps. Google Secret Manager offers deep cloud-native infrastructure protection, keeping production secrets fully isolated from the code environment and utilizing fine-grained IAM controls to securely mount them directly to the application container at runtime. This isolation ensures that even if the source repository or build process is compromised, active production secrets remain protected.

---

**Q3: A coworker says "I will clean up IAM permissions after the project launches. For now I need everything to work fast." What is the risk of this approach?**

De-prioritizing secure access structures under the assumption that they will be refactored later creates immediate security vulnerabilities and increases the likelihood that overly permissive accounts will remain active indefinitely once project priorities shift. This practice expands the potential attack surface during deployment, where a single compromised script or account can grant attackers lateral access to the entire cloud environment. Additionally, engineering teams often build implicit operational dependencies on these broad permissions, making security refactoring much more difficult and disruptive after launch.