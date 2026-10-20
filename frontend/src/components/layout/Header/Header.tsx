'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useEffect, useRef } from 'react';
import styles from './Header.module.css';

export default function Header() {
  const pathname = usePathname();
  const currentPath = pathname || '/';
  const bgRef = useRef<HTMLDivElement>(null);

  const cleanPathname = currentPath.endsWith('/') && currentPath !== '/'
    ? currentPath.slice(0, -1)
    : currentPath;

  const backgroundImages: Record<string, string> = {
    '/': 'url("/images/header/home.webp")',
    '/bedrock': 'url("/images/header/bedrock.webp")',
    '/java-og': 'url("/images/header/java-og.webp")',
    '/java': 'url("/images/header/java-creative.webp")',
  };

  const backgroundImage = backgroundImages[cleanPathname] || 'url("/images/header/logo.png")';

  useEffect(() => {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      return;
    }

    let ticking = false;

    const handleScroll = () => {
      if (ticking) return;
      ticking = true;
      window.requestAnimationFrame(() => {
        if (bgRef.current) {
          bgRef.current.style.transform = `translate3d(0, ${document.body.scrollTop * 0.35}px, 0)`;
        }
        ticking = false;
      });
    };

    document.body.addEventListener('scroll', handleScroll, { passive: true });
    return () => document.body.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <header className={styles.header}>
      <div ref={bgRef} className={styles.headerBg} style={{ backgroundImage }} />

      <div className={styles.headerContent}>
        <Link href="/">
          <img src="/images/header/logo.png" alt="ZendCraft.net" className={styles.titleImage} />
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
      </div>
    </header>
  );
}