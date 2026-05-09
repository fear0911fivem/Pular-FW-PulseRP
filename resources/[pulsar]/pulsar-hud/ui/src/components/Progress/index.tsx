import { useEffect, useRef, useState } from 'react'
import { Box, rem } from '@mantine/core'
import { Transition } from '@mantine/core'
import { useProgressStore } from '../../store/progress'
import { useHudStore } from '../../store/hud'
import { nui } from '../../nui'
import { PROGRESS_BOTTOM, PROGRESS_TICK_MS } from '../../hudTheme'
import ProgressTicks from './Ticks'
import ProgressMinimal from './Minimal'

export default function ProgressBar() {
  const { showing, failed, cancelled, finished, label, duration, startTime } = useProgressStore()
  const progressStyle = useHudStore((s) => s.config.progressStyle)

  const dur = duration ?? 0

  const [curr, setCurr]   = useState(0)
  const [visible, setVis] = useState(false)
  const tickRef = useRef<ReturnType<typeof setInterval> | null>(null)
  const hideRef = useRef<ReturnType<typeof setTimeout> | null>(null)

  useEffect(() => {
    setCurr(0)
    setVis(true)
    return () => { if (tickRef.current) clearInterval(tickRef.current) }
  }, [startTime])

  useEffect(() => {
    if (!showing) { setVis(false); return }
    tickRef.current = setInterval(() => {
      setCurr((c) => {
        if (dur > 0 && c + PROGRESS_TICK_MS > dur) {
          nui.send('Progress:Finish')
          if (tickRef.current) clearInterval(tickRef.current)
          useProgressStore.setState({ finished: true })
          return dur
        }
        return c + PROGRESS_TICK_MS
      })
    }, PROGRESS_TICK_MS)
    return () => { if (tickRef.current) clearInterval(tickRef.current) }
  }, [showing, dur])

  useEffect(() => {
    if (cancelled || finished || failed) {
      if (tickRef.current) clearInterval(tickRef.current)
      setCurr(0)
      hideRef.current = setTimeout(() => setVis(false), 1800)
    }
    return () => { if (hideRef.current) clearTimeout(hideRef.current) }
  }, [cancelled, finished, failed])

  const onExited = () => useProgressStore.setState({ showing: false })

  const pct          = dur > 0 ? (cancelled || finished || failed ? 100 : (curr / dur) * 100) : 0
  const displayLabel = finished ? 'Done' : failed ? 'Failed' : cancelled ? 'Cancelled' : (label ?? '')

  const variantProps = { pct, curr, dur, displayLabel, cancelled: !!cancelled, finished: !!finished, failed: !!failed }

  return (
    <Transition mounted={visible} transition="fade" duration={300} onExited={onExited}>
      {(styles) => (
        <Box
          style={{
            ...styles,
            willChange: 'opacity',
            position: 'absolute',
            bottom: rem(PROGRESS_BOTTOM),
            left: '50%',
            transform: 'translateX(-50%)',
            filter: 'drop-shadow(0 1px 6px rgba(0,0,0,0.95))',
          }}
        >
          {progressStyle === 'minimal'
            ? <ProgressMinimal {...variantProps} />
            : <ProgressTicks {...variantProps} />
          }
        </Box>
      )}
    </Transition>
  )
}
