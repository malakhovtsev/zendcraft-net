'use client';

import { useState, useEffect } from 'react';
import Flag from '@/components/server/Flag/Flag';
import ServerStatus, { ServerStatusData } from '@/components/server/ServerStatus/ServerStatus';
import styles from '../serverPage.module.css';

export default function JavaOgPage() {
  const [status, setStatus] = useState<ServerStatusData | null>(null);
  const [loading, setLoading] = useState(true);
  const [showReason, setShowReason] = useState(false);

  async function fetchStatus() {
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL;
      const response = await fetch(`${apiUrl}/api/java-server-status`);
      const data = await response.json();
      setStatus(data);
    } catch {
      setStatus({ online: false, playerCount: 0 });
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    fetchStatus();
    const interval = setInterval(fetchStatus, 10000);
    return () => clearInterval(interval);
  }, []);

  return (
    <main className={styles.serverMain}>
      <h2>Java Edition: OG Survival</h2>
      <br />

      <p>
        This is the main{' '}
        <a
          href="#"
          className={styles.reasonLink}
          onClick={(e) => {
            e.preventDefault();
            setShowReason((prev) => !prev);
          }}
          aria-expanded={showReason}
          aria-controls="server-reason"
        >
          <b>NOSTALGIA</b>
        </a>{' '}
        server
      </p>

      <br />
      <ServerStatus loading={loading} status={status} showPlayers={true} />

      <p>
        Region: <b>Germany</b> <Flag.DE />
      </p>
      <p>Version: <b>1.5.2</b></p>
      <p>Difficulty: <b>NORMAL</b></p>

      <br />

      {showReason && (
        <p id="server-reason" className={styles.serverReason}>
          <u>Reason</u>: Was selected to be one of the first and most nostalgic versions among most friends.
        </p>
      )}

      <br />

      <p>
        Instructions to join are on{' '}
        <strong>
          <a href="https://discord.gg/McyvbNsrED" target="_blank" rel="noreferrer">
            Discord
          </a>
        </strong>
      </p>
    </main>
  );
}
