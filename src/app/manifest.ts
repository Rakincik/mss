import { MetadataRoute } from 'next'

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: process.env.NEXT_PUBLIC_SITE_NAME || 'Sınav Sistemi',
    short_name: 'Sınav',
    description: 'Kesintisiz ve offline çalışabilen yeni nesil sınav platformu.',
    start_url: '/',
    display: 'standalone',
    background_color: '#ffffff',
    theme_color: process.env.NEXT_PUBLIC_PRIMARY_COLOR || '#2563eb',
    icons: [
      {
        src: '/favicon.ico',
        sizes: '64x64 32x32 24x24 16x16',
        type: 'image/x-icon',
      },
    ],
  }
}
