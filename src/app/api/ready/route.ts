import configPromise from '@payload-config'
import { NextResponse } from 'next/server'
import { getPayload } from 'payload'

export const dynamic = 'force-dynamic'
export const runtime = 'nodejs'

export async function GET() {
  const startedAt = Date.now()

  try {
    const payload = await getPayload({
      config: configPromise,
    })

    await payload.find({
      collection: 'pages',
      depth: 0,
      limit: 1,
      overrideAccess: true,
    })

    return NextResponse.json(
      {
        status: 'ready',
        service: 'news-cms',
        database: 'connected',
        responseTimeMs: Date.now() - startedAt,
        timestamp: new Date().toISOString(),
      },
      {
        status: 200,
        headers: {
          'Cache-Control': 'no-store, no-cache, must-revalidate',
        },
      },
    )
  } catch (error) {
    console.error('[readiness] Application is not ready:', error)

    return NextResponse.json(
      {
        status: 'not-ready',
        service: 'news-cms',
        database: 'unavailable',
        responseTimeMs: Date.now() - startedAt,
        timestamp: new Date().toISOString(),
      },
      {
        status: 503,
        headers: {
          'Cache-Control': 'no-store, no-cache, must-revalidate',
        },
      },
    )
  }
}
