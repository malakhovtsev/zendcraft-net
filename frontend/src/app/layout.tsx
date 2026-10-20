import type { Metadata } from 'next';
import './globals.css';
import Header from '@/components/layout/Header/Header';
import Footer from '@/components/layout/Footer/Footer';

export const metadata: Metadata = {
  metadataBase: new URL('https://zendcraft.net'),
  title: 'ZendCraft',
  description: 'Your next door Minecraft Bedrock and Java Servers.',
  keywords: ['minecraft', 'minecraft server', 'server', 'zendcraft'],
  authors: [{ name: 'ZendCraft.net' }],
  openGraph: {
    title: 'ZendCraft.net',
    description: 'Your neighborhood Minecraft Bedrock and Java Servers for Whitelisted friends.',
    url: 'https://zendcraft.net',
    type: 'website',
    images: ['/social-preview.jpg'],
  },
  icons: {
    icon: [
      { url: '/favicon/favicon-96x96.png', sizes: '96x96', type: 'image/png' },
      { url: '/favicon/favicon.svg', type: 'image/svg+xml' },
    ],
    apple: [{ url: '/favicon/apple-touch-icon.png', sizes: '180x180' }],
  },
  manifest: '/favicon/site.webmanifest',
  appleWebApp: { title: 'ZendCraft' },
};

interface RootLayoutProps {
  children: React.ReactNode;
}

export default function RootLayout({ children }: RootLayoutProps) {
  return (
    <html lang="en">
      <body className="layout">
        <Header />
        {children}
        <Footer />
      </body>
    </html>
  );
}
