| Dimension | On-Premise Docker (Wks 3–5) | Cloud Run (Week 8) |
| :--- | :--- | :--- |
| Infrastructure setup | 3 VMs created, Docker installed on each | Serverless platform; no VMs to manage, Google provisions underlying host infrastructure automatically. |
| Deployment command | SSH → docker build → docker run | Automated CI/CD via GitHub Actions workflow triggering Artifact Registry push and Cloud Run revision updates. |
| TLS / HTTPS | Not configured | Automatically provisioned out of the box with built-in Google-managed public HTTPS certificates. |
| Scaling approach | Manual — redeploy or add VMs | Dynamic horizontal auto-scaling; managed automatically based on concurrent incoming request volume. |
| Port management | Ports 5000/5001/5002 per environment | Abstracted completely by Google; container listens on environment variable port `$PORT` (typically 8080). |
| Cost when idle | VM running 24/7 regardless of traffic | Scale-to-Zero allocation; entirely free ($0) during zero-traffic idle periods. |
| Rollback | Re-deploy previous image manually | Point-and-click or immediate CLI traffic shifting to immutable, historic service revisions. |
| Secrets management | GitHub Secrets → env vars in workflow | Integrated centrally via Google Cloud IAM or direct injection-linking via Google Secret Manager. |

## 2. Reflection Questions

### Q1: Which approach required more manual steps from push to live URL? List the specific steps that were eliminated by Cloud Run.
**Answer:** The on-premise Docker VM approach required significantly more manual steps, forcing developers to SSH into individual machines, pull updated code, and rebuild or restart container runtimes manually. Cloud Run completely eliminated the need for manual SSH terminal access, container build executions directly on the host machines, manually setting up firewall rules, and handling port conflicts.

### Q2: A security audit asks how you know which version of the code is currently running in production. How would you answer for on-premise Docker vs. Cloud Run with commit SHA tagging?
**Answer:** For the on-premise Docker setup, code verification requires an administrator to manually log into each VM and check local container images or hashes, which leaves room for configuration drift and blind spots. With Cloud Run and commit SHA tagging, each deployment generates an immutable revision identifier tied directly to a specific GitHub commit signature, creating a transparent, unalterable cryptographic audit trail in the cloud console.

### Q3: Your on-premise VMs run 24/7 even when no students are using the app. Cloud Run scales to zero. What is the security advantage of scale-to-zero beyond cost savings?
**Answer:** Scaling to zero minimizes the application's attack surface drastically by ensuring that no live container processes, open ports, or operating runtimes exist during idle periods. This ephemeral behavior prevents malicious actors from scanning, probing, or exploiting active application vulnerabilities or memory-based bugs when the service is not in active use.

### Q4: The OIDC workflow replaced the SSH key secrets from Weeks 3–5. What attack surface was eliminated?
**Answer:** The migration to OpenID Connect (OIDC) eliminated the threat vector of using long-lived static credentials stored directly within GitHub repository environment secrets. By transitioning to keyless, short-lived tokens using federated IAM identity tokens, attackers can no longer harvest a compromised private SSH key to establish permanent unauthorized access to backend cloud servers.