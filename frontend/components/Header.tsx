'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import styles from './Header.module.css';

export default function Header() {
  const pathname = usePathname();
  const currentPath = pathname || '/';
  
  const cleanPathname = currentPath.endsWith('/') && currentPath !== '/' 
    ? currentPath.slice(0, -1) 
    : currentPath;

  const backgroundImages: Record<string, string> = {
    '/': 'url("/header-images/home.webp")',
    '/bedrock': 'url("/header-images/bedrock.webp")',
    '/java-og': 'url("/header-images/java-og.webp")',
    '/java': 'url("/header-images/java-creative.webp")',
  };

  const backgroundImage = backgroundImages[cleanPathname] || 'url("/header-images/logo.png")';

  return (
    <header
      className={styles.header}
      style={{ backgroundImage, backgroundSize: 'cover', backgroundPosition: 'center' }}
    >
      <Link href="/" className={styles.titleImageLink}>
        <img src="/header-images/logo.png" alt="ZendCraft.net" className={styles.titleImage} />
      </Link>

      <nav className={styles.nav}>
        <Link
          href="/java-og"
          className={`${styles.navLink} ${cleanPathname === '/java-og' ? styles.navLinkActive : ''}`}
        >
          Classic
        </Link>
        <Link
          href="/java"
          className={`${styles.navLink} ${cleanPathname === '/java' ? styles.navLinkActive : ''}`}
        >
          Creative
        </Link>
        <Link
          href="/bedrock"
          className={`${styles.navLink} ${cleanPathname === '/bedrock' ? styles.navLinkActive : ''}`}
        >
          Bedrock
        </Link>
      </nav>
    </header>
  );
}