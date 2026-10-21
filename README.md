<a href="https://www.zendcraft.net" target="_blank">
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

1.  **Frontend:** Next.js (TypeScript) provides the UI and server-side rendering.
2.  **API Layer:** A Node.js/Express service that queries the Minecraft servers using the `query` protocol.
3.  **Reverse Proxy:** Nginx manages SSL termination and routes traffic between the web and the API.

---

## 🛠️ Tech Stack
* **Frontend:** [Next.js](https://nextjs.org/) (App Router)
* **API Backend:** [Node.js](https://nodejs.org/) & [Express](https://expressjs.com/)
* **Language:** [TypeScript](https://www.typescriptlang.org/) (Strongly typed for better reliability)
* **Server/Proxy:** [Nginx](https://www.nginx.com/)
* **Minecraft Integration:** `minecraft-server-util`
