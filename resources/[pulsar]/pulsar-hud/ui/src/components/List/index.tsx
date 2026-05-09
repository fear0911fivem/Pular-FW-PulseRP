import { useEffect } from 'react'
import { Box, Text, Transition } from '@mantine/core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import type { IconProp } from '@fortawesome/fontawesome-svg-core'
import { rem } from '@mantine/core'
import { useListStore, ListItem } from '../../store/list'
import { nui } from '../../nui'
import ListItemRow from './ListItem'
import { useHudTheme } from '../../hooks/useHudTheme'
import { COLOR_BG_DARK, COLOR_PANEL_BORDER, COLOR_DIVIDER, LIST_TOP, LIST_RIGHT } from '../../hudTheme'

export default function ListMenu() {
  const showing = useListStore((s) => s.showing)
  const active  = useListStore((s) => s.active)
  const stack   = useListStore((s) => s.stack)
  const menus   = useListStore((s) => s.menus)
  const menu    = menus[active]

  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && showing) nui.send('ListMenu:Close')
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [showing])

  const onBack = () => {
    nui.send('ListMenu:Back')
    useListStore.setState((s) => {
      const next = s.stack[s.stack.length - 1] ?? 'main'
      return { active: next, stack: s.stack.slice(0, -1) }
    })
  }

  const { primary } = useHudTheme()

  if (!menu) return null

  return (
    <Transition mounted={showing} transition="slide-left" duration={200}>
      {(styles) => (
        <Box
          style={{
            ...styles,
            position: 'absolute',
            top: rem(LIST_TOP),
            right: LIST_RIGHT,
            width: rem(360),
            maxHeight: '65vh',
            display: 'flex',
            flexDirection: 'column',
            background: COLOR_BG_DARK,
            border: `1px solid ${COLOR_PANEL_BORDER}`,
            zIndex: 400,
            overflow: 'hidden',
          }}
        >
          {/* Header */}
          <Box style={{ padding: `${rem(14)} ${rem(16)} ${rem(12)}`, flexShrink: 0 }}>
            <Box style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
              <Box>
                <Text
                  style={{
                    fontSize: rem(13),
                    fontWeight: 700,
                    letterSpacing: '0.1em',
                    textTransform: 'uppercase',
                    color: 'rgba(255,255,255,0.9)',
                    lineHeight: 1,
                  }}
                >
                  {menu.label ?? 'Menu'}
                </Text>
                {/* Short accent underline */}
                <Box style={{ width: rem(28), height: rem(2), background: primary, marginTop: rem(6) }} />
              </Box>

              <Box style={{ display: 'flex', alignItems: 'center', gap: rem(10), paddingTop: rem(2) }}>
                {stack.length > 0 && (
                  <Box
                    onClick={onBack}
                    style={{ cursor: 'pointer', color: 'rgba(255,255,255,0.3)', fontSize: rem(11) }}
                    onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.color = '#fff' }}
                    onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.color = 'rgba(255,255,255,0.3)' }}
                  >
                    <FontAwesomeIcon icon={['fas', 'arrow-left']} />
                  </Box>
                )}
                {menu.headerAction?.event && (
                  <Box
                    onClick={() => nui.send('ListMenu:Clicked', { event: menu.headerAction!.event, data: menu.headerAction!.data })}
                    style={{ cursor: 'pointer', color: 'rgba(255,255,255,0.3)', fontSize: rem(11) }}
                    onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.color = primary }}
                    onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.color = 'rgba(255,255,255,0.3)' }}
                  >
                    <FontAwesomeIcon icon={['fas', menu.headerAction.icon] as unknown as IconProp} />
                  </Box>
                )}
                <Box
                  onClick={() => nui.send('ListMenu:Close')}
                  style={{ cursor: 'pointer', color: 'rgba(255,255,255,0.3)', fontSize: rem(11) }}
                  onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.color = '#fff' }}
                  onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.color = 'rgba(255,255,255,0.3)' }}
                >
                  <FontAwesomeIcon icon={['fas', 'xmark']} />
                </Box>
              </Box>
            </Box>
          </Box>

          {/* Thin divider */}
          <Box style={{ height: rem(1), background: COLOR_DIVIDER, flexShrink: 0 }} />

          {/* Items */}
          <div style={{ flex: 1, minHeight: 0, overflowY: 'auto' }}>
            {(menu.items ?? []).map((item: ListItem, k: number) => (
              <ListItemRow key={`${active}-${k}`} index={k} item={item} />
            ))}
          </div>
        </Box>
      )}
    </Transition>
  )
}
