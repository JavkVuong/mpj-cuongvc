import { withPayload } from '@payloadcms/next/withPayload'
import type { NextConfig } from 'next'
import path from 'path'
import { fileURLToPath } from 'url'

import { redirects } from './redirects'

const __filename = fileURLToPath(import.meta.url)
const dirname = path.dirname(__filename)

let serverURL = 'http://localhost:3000'

if (process.env.NEXT_PUBLIC_SERVER_URL) {
  serverURL = process.env.NEXT_PUBLIC_SERVER_URL
} else if (process.env.VERCEL_PROJECT_PRODUCTION_URL) {
  serverURL = `https://${process.env.VERCEL_PROJECT_PRODUCTION_URL}`
} else if (process.env.__NEXT_PRIVATE_ORIGIN) {
  serverURL = process.env.__NEXT_PRIVATE_ORIGIN
}

const parsedServerURL = new URL(serverURL)

const nextConfig: NextConfig = {
  output: 'standalone',

  sassOptions: {
    loadPaths: ['./node_modules/@payloadcms/ui/dist/scss/'],
  },

  images: {
    localPatterns: [
      {
        pathname: '/api/media/file/**',
      },
    ],
    qualities: [100],
    remotePatterns: [
      {
        hostname: parsedServerURL.hostname,
        protocol: parsedServerURL.protocol.replace(':', '') as 'http' | 'https',
      },
    ],
  },

  webpack: (webpackConfig) => {
    webpackConfig.resolve.extensionAlias = {
      '.cjs': ['.cts', '.cjs'],
      '.js': ['.ts', '.tsx', '.js', '.jsx'],
      '.mjs': ['.mts', '.mjs'],
    }

    return webpackConfig
  },

  reactStrictMode: true,
  redirects,

  turbopack: {
    root: path.resolve(dirname),
  },
}

export default withPayload(nextConfig, {
  devBundleServerPackages: false,
})
