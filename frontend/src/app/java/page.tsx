'use client';

import YouTubeShorts from '@/components/media/YouTubeShorts/YouTubeShorts';
import Flag from '@/components/server/Flag/Flag';

export default function JavaPage() {
  return (
    <main style={{ padding: '2rem', textAlign: 'center' }}>
      <h2>Java Edition: Creative Mode</h2>
      <br />
      <p><i><b>Coming in the future...</b></i></p>
      <br />
      <p>Region: <b>US East <Flag.US /></b></p>
      <br />
      <p>Planned to be based on my old city map: </p>
      <br />
      <YouTubeShorts />
    </main>
  );
}
