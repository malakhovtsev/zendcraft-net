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
                          └─ /api/*  → Lambda (Express in a container) ─ legacy ping → Minecraft server
```

1. **Frontend:** A Next.js (TypeScript) site exported as static files to S3. `www.zendcraft.net` permanently redirects to `zendcraft.net` through a CloudFront Function.
2. **API:** A Node.js/Express service that pings the 1.5.2 server with the pre-1.7 [server list ping](backend/src/minecraft/legacyPing.ts), implemented directly over TCP.
3. **Edge:** CloudFront terminates TLS with an auto-renewing ACM certificate and forwards `/api/*` uncached to the backend.
4. **Serverless backend:** The API image runs on AWS Lambda through [Lambda Web Adapter](https://github.com/awslabs/aws-lambda-web-adapter), so the same Express app and [Dockerfile](backend/Dockerfile) also run as a plain container. CloudFront reaches it through a Lambda function URL that only accepts requests signed by CloudFront (Origin Access Control), and it costs nothing while idle.

## Infrastructure & Deployment

* **Infrastructure as code:** All AWS resources are defined with Terraform in [`infra/`](infra/), with state in S3.
* **CI/CD:** GitHub Actions deploy on every push to `main`, authenticating to AWS through OIDC with short-lived credentials (no stored access keys).
  * **Frontend:** build, sync to S3 (hashed assets cached for a year, pages revalidated), invalidate CloudFront.
  * **Backend:** build the API image once in CI and push it to Amazon ECR, tagged with the commit SHA, point the Lambda function at it, then check the live API through CloudFront.
* **Pull requests:** CI builds and type-checks both apps, builds the Docker image, and validates the Compose file and Terraform before merge.
* **Server access:** AWS Systems Manager Session Manager only.

---

## Tech Stack
* **Frontend:** [Next.js](https://nextjs.org/) (App Router, static export)
* **API Backend:** [Node.js](https://nodejs.org/) 24 & [Express](https://expressjs.com/)
* **Language:** [TypeScript](https://www.typescriptlang.org/)
* **Containers:** [Docker](https://www.docker.com/) & Docker Compose
* **Cloud:** AWS (CloudFront, S3, Lambda, ECR, ACM, IAM)
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

To run the API the way production does, behind nginx in containers:

```bash
docker compose up --build   # http://localhost/api/java-server-status
```

## License

Copyright © 2025 Andrii Malakhovtsev. All rights reserved. The source is public for viewing and reference only; see [LICENSE](LICENSE).

Not affiliated with Mojang or Microsoft. Minecraft is a trademark of Mojang AB.
