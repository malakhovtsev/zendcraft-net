'use client';

import styles from './YouTubeShorts.module.css';

export default function SilentLoopingShorts() {
  return (
    <div className={styles['shorts-wrapper']}>
      <div className={styles['short-container']}>
        <iframe
          className={styles['short-iframe']}
          src="https://www.youtube.com/embed/c3YCBiGu02E?autoplay=1&mute=1&loop=1&playlist=c3YCBiGu02E&controls=0&modestbranding=1&playsinline=1&rel=0"
          allow="autoplay; encrypted-media; picture-in-picture"
          allowFullScreen
          title="Short 1"
        ></iframe>
      </div>
      <div className={styles['short-container']}>
        <iframe
          className={styles['short-iframe']}
          src="https://www.youtube.com/embed/Rl4gHAwp--Y?autoplay=1&mute=1&loop=1&playlist=Rl4gHAwp--Y&controls=0&modestbranding=1&playsinline=1&rel=0"
          allow="autoplay; encrypted-media; picture-in-picture"
          allowFullScreen
          title="Short 2"
        ></iframe>
      </div>
    </div>
  );
}