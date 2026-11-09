<a href="https://zendcraft.net" target="_blank">
  <img src="https://github.com/user-attachments/assets/3b7436bd-6489-44c2-9489-43a9949801cb" width="500" />
</a>

<hr>

**ZendCraft** is a private Minecraft server community designed for whitelisted friends. This repository contains the web portal that provides real-time server status, connection instructions, and community links for our different game modes.

* **Nostalgia Server:** Classic Java 1.5.2 support (Ubuntu on Hetzner).

<img width="429" height="233" alt="image" src="https://github.com/user-attachments/assets/60550b44-1142-4fe8-9fef-ecbb3966acfb" />

* **Java Edition:** Creative Mode (In-Progress).
* **Bedrock Edition:** Survival on a Minecraft Realm.

---

## System Architecture

Everything is served from `zendcraft.net` through a single CloudFront distribution:

```
                          ┌─ /*      → S3 (static Next.js export)
browser ─ HTTPS ─ CloudFront
                          └─ /api/*  → EC2: nginx → Express ─ legacy ping → Minecraft server
```

1. **Frontend:** A Next.js (TypeScript) site exported as static files to S3. `www.zendcraft.net` permanently redirects to `zendcraft.net` through a CloudFront Function.
2. **API:** A Node.js/Express service on EC2 that pings the 1.5.2 server with the pre-1.7 [server list ping](backend/src/minecraft/legacyPing.ts), implemented directly over TCP.
3. **Edge:** CloudFront terminates TLS with an auto-renewing ACM certificate and forwards `/api/*` uncached to the backend.
4. **Reverse proxy:** nginx on the instance passes CloudFront's `/api/` traffic to Express. The instance's firewall accepts port 80 from CloudFront only; there is no SSH.

## Infrastructure & Deployment

* **Infrastructure as code:** All AWS resources are defined with Terraform in [`infra/`](infra/), with state in S3.
* **CI/CD:** GitHub Actions deploy on every push to `main`, authenticating to AWS through OIDC with short-lived credentials (no stored access keys).
  * **Frontend:** build, sync to S3 (hashed assets cached for a year, pages revalidated), invalidate CloudFront.
  * **Backend:** build once in CI, upload the artifact to S3, then install it on the instance through an SSM Run Command document that health-checks the API and rolls back on failure.
* **Server access:** AWS Systems Manager Session Manager only.

---

## 🛠️ Tech Stack
* **Frontend:** [Next.js](https://nextjs.org/) (App Router, static export)
* **API Backend:** [Node.js](https://nodejs.org/) 24 & [Express](https://expressjs.com/)
* **Language:** [TypeScript](https://www.typescriptlang.org/)
* **Cloud:** AWS (CloudFront, S3, EC2, ACM, IAM, Systems Manager)
* **Infrastructure:** [Terraform](https://www.terraform.io/)
* **CI/CD:** GitHub Actions
* **Server/Proxy:** [Nginx](https://nginx.org/)

## Local Development

The Node version is pinned in [`.nvmrc`](.nvmrc).

```bash
# API on http://localhost:4000 (set JAVA_SERVER_HOST / JAVA_SERVER_PORT in backend/.env)
cd backend && npm install && npm run dev

# Site on http://localhost:3000 (/api is proxied to the backend)
cd frontend && npm install && npm run dev
```

## License

Copyright © 2025–2026 Andrii Malakhovtsev. All rights reserved. The source is public for viewing and reference only; see [LICENSE](LICENSE).

Not affiliated with Mojang or Microsoft. Minecraft is a trademark of Mojang AB.
