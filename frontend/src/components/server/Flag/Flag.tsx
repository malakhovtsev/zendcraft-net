import React from 'react';
import styles from './Flag.module.css';

function FlagBase({ src, alt }: { src: string; alt: string }) {
  return (
    <img
      src={src}
      alt={alt}
      width={61}
      height={39}
      className={styles.flagImage}
      loading="lazy"
    />
  );
}

const Flag = {
  DE: () => <FlagBase src="/de-flag-minecraft.png" alt="🇩🇪" />,
  US: () => <FlagBase src="/us-flag-minecraft.png" alt="🇺🇸" />,
};

export default Flag;