export default function Head() {
  return (
    <>
      <title>ZendCraft</title>
      <meta name="description" content="Your next door Minecraft Bedrock and Java Servers." />
      <meta name="keywords" content="minecraft, minecraft server, server, zendcraft" />
      <meta name="author" content="ZendCraft.net" />

      {/* Open Graph tags */}
      <meta property="og:title" content="ZendCraft.net" />
      <meta property="og:description" content="Your neighborhood Minecraft Bedrock and Java Servers for Whitelisted friends." />
      <meta property="og:image" content="https://zendcraft.net/social-preview.jpg" />
      <meta property="og:url" content="https://zendcraft.net" />
      <meta property="og:type" content="website" />

      {/* Favicons */}
      <link rel="icon" type="image/png" href="/favicon/favicon-96x96.png" sizes="96x96" />
      <link rel="icon" type="image/svg+xml" href="/favicon/favicon.svg" />
      <link rel="shortcut icon" href="/favicon/favicon.ico" />
      <link rel="apple-touch-icon" sizes="180x180" href="/favicon/apple-touch-icon.png" />
      <meta name="apple-mobile-web-app-title" content="MyWebSite" />
      <link rel="manifest" href="/favicon/site.webmanifest" />
    </>
  );
}