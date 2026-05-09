import { Box, Text } from '@mantine/core'
import { rem } from '@mantine/core'
import { COLOR_PRIMARY, COLOR_SUCCESS, COLOR_FAIL, PROGRESS_TICK_COUNT } from '../../hudTheme'

interface Props {
  pct: number
  curr: number
  dur: number
  displayLabel: string
  cancelled: boolean
  finished: boolean
  failed: boolean
}

export default function ProgressTicks({ pct, curr, dur, displayLabel, cancelled, finished, failed }: Props) {
  const litTicks  = Math.round((pct / 100) * PROGRESS_TICK_COUNT)
  const secsLeft  = Math.max(0, Math.ceil((dur - curr) / 1000))
  const fillColor = cancelled || failed ? COLOR_FAIL : finished ? COLOR_SUCCESS : COLOR_PRIMARY

  return (
    <Box style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: rem(8) }}>
      <Box style={{ display: 'flex', alignItems: 'baseline', gap: rem(8) }}>
        <Text
          style={{
            fontSize: rem(15),
            fontWeight: 600,
            letterSpacing: '0.12em',
            textTransform: 'uppercase',
            color: 'rgba(255,255,255,1)',
            lineHeight: 1,
            whiteSpace: 'nowrap',
          }}
        >
          {displayLabel}
        </Text>
        {!cancelled && !finished && !failed && dur > 0 && (
          <Text style={{ fontSize: rem(13), color: 'rgba(255,255,255,0.75)', letterSpacing: '0.04em', lineHeight: 1, minWidth: rem(28), textAlign: 'right' }}>
            {secsLeft}s
          </Text>
        )}
      </Box>

      <Box style={{ display: 'flex', alignItems: 'center', gap: rem(5) }}>
        {Array.from({ length: PROGRESS_TICK_COUNT }).map((_, i) => {
          const isLit     = i < litTicks
          const isLeading = i === litTicks - 1
          return (
            <Box
              key={i}
              style={{
                width: rem(5),
                height: rem(isLeading ? 20 : 15),
                borderRadius: rem(1),
                background: isLit ? fillColor : 'rgba(255,255,255,0.07)',
                boxShadow: isLeading ? `0 0 10px ${fillColor}, 0 0 4px ${fillColor}` : 'none',
                transition: 'background 0.08s, box-shadow 0.08s, height 0.08s',
                animation: isLeading && !cancelled && !finished && !failed ? 'tick-bounce 0.6s ease-in-out infinite' : 'none',
                flexShrink: 0,
              }}
            />
          )
        })}
      </Box>
    </Box>
  )
}
