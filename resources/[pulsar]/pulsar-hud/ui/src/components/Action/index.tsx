import { Transition, Box, Text, Group, rem } from '@mantine/core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { useActionStore, useAction2Store } from '../../store/action'
import { useHudTheme } from '../../hooks/useHudTheme'
import { COLOR_BG_DARK } from '../../hudTheme'

function formatMessage(msg: string, primary: string) {
  const parts = msg.split(/(\{key\}[^{]*\{\/key\}|\[[^\]]+\])/g)
  return parts.map((part, i) => {
    if (/^\{key\}/.test(part)) {
      const content = part.replace(/\{key\}|\{\/key\}/g, '')
      return <Text key={i} span style={{ color: primary, fontWeight: 700, background: `${primary}22`, padding: '1px 5px' }}>{content}</Text>
    }
    if (/^\[.*\]$/.test(part)) {
      return <Text key={i} span style={{ color: primary, fontWeight: 700 }}>{part}</Text>
    }
    return part
  })
}

export function ActionBanner() {
  const { primary } = useHudTheme()
  const { showing, message, buttons } = useActionStore()

  return (
    <Transition mounted={showing} transition="fade" duration={300}>
      {(styles) => (
        <Box
          style={{
            ...styles,
            willChange: 'opacity',
            position: 'absolute',
            bottom: '10%',
            left: '50%',
            transform: 'translateX(-50%)',
            width: 'max-content',
            maxWidth: rem(500),
            background: COLOR_BG_DARK,
            border: `1px solid ${primary}40`,
            padding: `${rem(11)} ${rem(22)}`,
            textAlign: 'center',
          }}
        >
          <Text style={{ fontSize: rem(15), fontWeight: 500 }}>{formatMessage(String(message ?? ''), primary)}</Text>
        </Box>
      )}
    </Transition>
  )
}

export function Action2List() {
  const { primary } = useHudTheme()
  const actions = useAction2Store((s) => s.actions)

  if (actions.length === 0) return null
  return (
    <Box
      style={{
        position: 'absolute',
        bottom: '15%',
        left: '50%',
        transform: 'translateX(-50%)',
        display: 'flex',
        flexDirection: 'column',
        gap: rem(6),
        alignItems: 'center',
      }}
    >
      {actions.map((a) => (
        <Box
          key={a.id}
          style={{
            background: COLOR_BG_DARK,
            border: `1px solid ${primary}40`,
            padding: `${rem(8)} ${rem(18)}`,
          }}
        >
          <Text style={{ fontSize: rem(15), fontWeight: 500 }}>{formatMessage(a.message, primary)}</Text>
        </Box>
      ))}
    </Box>
  )
}
