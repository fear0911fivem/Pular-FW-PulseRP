import { useState, useEffect } from 'react'
import { Box, Text } from '@mantine/core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import type { IconProp } from '@fortawesome/fontawesome-svg-core'
import { rem } from '@mantine/core'
import { useInteractionStore } from '../../store/interaction'
import { nui } from '../../nui'
import {
  COLOR_PRIMARY, COLOR_BG_DARK, COLOR_BAR_BG,
  INTERACTION_RADIUS,
} from '../../hudTheme'

const RADIUS    = INTERACTION_RADIUS
const ITEM_SIZE = 66

export default function InteractionMenu() {
  const { showing, items, layer } = useInteractionStore()
  const [hoveredIdx, setHoveredIdx] = useState(-1)

  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if ((e.key === 'F1' || e.key === 'Escape') && showing) {
        e.preventDefault()
        nui.send('Interaction:Hide', {})
      }
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [showing])

  const handleBack = (e: React.MouseEvent) => {
    e.stopPropagation()
    nui.send('Interaction:Back', {})
  }

  const handleHide = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) nui.send('Interaction:Hide', {})
  }

  const handleClose = (e: React.MouseEvent) => {
    e.stopPropagation()
    nui.send('Interaction:Hide', {})
  }

  if (!showing) return null

  return (
    <Box
      onClick={handleHide}
      style={{
        position: 'absolute',
        inset: 0,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 500,
      }}
    >
      {(items ?? []).map((item, i) => {
        const angle  = (i / items.length) * 2 * Math.PI - Math.PI / 2
        const x      = Math.cos(angle) * RADIUS
        const y      = Math.sin(angle) * RADIUS
        const active = hoveredIdx === i

        return (
          <Box
            key={item.id}
            onMouseEnter={() => setHoveredIdx(i)}
            onMouseLeave={() => setHoveredIdx(-1)}
            onClick={(e) => {
              e.stopPropagation()
              nui.send('Interaction:Trigger', { id: item.id })
            }}
            style={{
              position: 'absolute',
              width:  rem(ITEM_SIZE),
              height: rem(ITEM_SIZE),
              left:  `calc(50% + ${rem(x)} - ${rem(ITEM_SIZE / 2)})`,
              top:   `calc(50% + ${rem(y)} - ${rem(ITEM_SIZE / 2)})`,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              gap: rem(5),
              background: COLOR_BG_DARK,
              border: `${active ? '2px' : '1px'} solid ${active ? COLOR_PRIMARY : COLOR_BAR_BG}`,
              cursor: 'pointer',
              transform: active ? 'scale(1.08)' : 'scale(1)',
              transition: 'transform 0.1s ease, border-color 0.1s ease, border-width 0.1s ease',
              userSelect: 'none',
            }}
          >
            {item.icon && (
              <FontAwesomeIcon
                icon={['fas', item.icon] as IconProp}
                style={{ color: active ? COLOR_PRIMARY : 'rgba(255,255,255,0.7)', fontSize: rem(24) }}
              />
            )}
            {item.label && (
              <Text
                style={{
                  fontSize: rem(12),
                  fontWeight: 600,
                  color: active ? '#fff' : 'rgba(255,255,255,0.55)',
                  letterSpacing: '0.04em',
                  textAlign: 'center',
                  lineHeight: 1.2,
                  maxWidth: rem(ITEM_SIZE - 8),
                  whiteSpace: 'nowrap',
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                }}
              >
                {item.label}
              </Text>
            )}
          </Box>
        )
      })}

      <Box
        onClick={layer > 0 ? handleBack : handleClose}
        style={{
          position: 'absolute',
          width:  rem(44),
          height: rem(44),
          borderRadius: '50%',
          background: COLOR_BG_DARK,
          border: `1px solid ${COLOR_BAR_BG}`,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          cursor: 'pointer',
          zIndex: 100,
        }}
      >
        <FontAwesomeIcon
          icon={layer > 0 ? ['fas', 'arrow-left'] : ['fas', 'xmark']}
          style={{ color: 'rgba(255,255,255,0.4)', fontSize: rem(14) }}
        />
      </Box>
    </Box>
  )
}
