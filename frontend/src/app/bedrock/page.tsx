'use client';

import { useState } from 'react';
import Flag from '@/components/server/Flag/Flag';
import ServerStatus from '@/components/server/ServerStatus/ServerStatus';
import styles from '../serverPage.module.css';

export default function BedrockPage() {
  const [showReason, setShowReason] = useState(false);

  return (
    <main style={{ padding: '2rem', textAlign: 'center' }}>
      <h2>Bedrock Edition</h2>
      <br></br>
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
          <b>SURVIVAL</b>
        </a>{' '}
        server
      </p>
      <br />
      <ServerStatus
        loading={false}
        status={{ online: false, paused: true, playerCount: 0 }}
      />
      <p>Region: <b>US East <Flag.US /></b></p>
      <p>Achievements: <b>ON</b></p>
      <p>Show Coordinates: <b>ON</b></p>
      <p>Difficulty: <b>EASY</b></p>
      <br />
      {showReason && (
        <p id="server-reason" className={styles.serverReason}>
            <u>Reason</u>: The only version of Minecraft constantly updated to newest versions
          <br />
          and available on all platforms at the same time
        </p>
      )}

      <br />
    </main>
  );
}
