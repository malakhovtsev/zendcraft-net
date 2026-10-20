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
  DE: () => <FlagBase src="/images/flags/de.png" alt="🇩🇪" />,
  US: () => <FlagBase src="/images/flags/us.png" alt="🇺🇸" />,
};

export default Flag;