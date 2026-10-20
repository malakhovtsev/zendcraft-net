import './globals.css';
import Header from '@/components/layout/Header/Header';
import Footer from '@/components/layout/Footer/Footer';

export const metadata = {
  title: 'ZendCraft',
  description: 'Minecraft Bedrock and Java server',
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
