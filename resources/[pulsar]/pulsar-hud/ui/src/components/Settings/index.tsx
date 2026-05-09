import { useEffect, useState } from 'react'
import { Box, Text, Grid, Select, Switch, Stack } from '@mantine/core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { rem } from '@mantine/core'
import { useHudStore, HudConfig } from '../../store/hud'
import { nui } from '../../nui'
import { useHudTheme } from '../../hooks/useHudTheme'
import { COLOR_BG_DARK, COLOR_MODAL_OVERLAY, COLOR_PANEL_BORDER, COLOR_DIVIDER, COLOR_INPUT_BG, COLOR_INPUT_BORDER, COLOR_DROPDOWN_BG } from '../../hudTheme'

const LAYOUTS = [
  { value: 'minimap', label: 'Below Minimap' },
  { value: 'center',  label: 'Bottom Center' },
]

const VEH_LAYOUTS = [
  { value: 'default', label: 'Default' },
  { value: 'digital', label: 'Minimal' },
]

const BAR_TYPES: Record<string, { value: string; label: string }[]> = {
  minimap: [{ value: 'icons', label: 'Icon Fill' }, { value: 'radial', label: 'Radial' }],
  center:  [{ value: 'icons', label: 'Icon Fill' }, { value: 'radial', label: 'Radial' }],
}

function SectionHeader({ children, primary }: { children: string; primary: string }) {
  return (
    <Box style={{ marginBottom: rem(12) }}>
      <Text style={{
        fontSize: rem(13), fontWeight: 700,
        letterSpacing: '0.1em', textTransform: 'uppercase',
        color: 'rgba(255,255,255,0.7)', lineHeight: 1,
      }}>
        {children}
      </Text>
      <Box style={{ width: rem(20), height: rem(1), background: primary, marginTop: rem(5), opacity: 0.7 }} />
    </Box>
  )
}

export default function Settings() {
  const isOpen = useHudStore((s) => s.settings)
  const config = useHudStore((s) => s.config)
  const [state, setState] = useState<HudConfig>({ ...config })

  const { primary } = useHudTheme()

  const fieldStyles = {
    input: {
      background: COLOR_INPUT_BG,
      border: `1px solid ${COLOR_INPUT_BORDER}`,
      borderRadius: 0,
      color: '#fff',
      fontSize: rem(13),
      '&:focus': { borderColor: primary },
    },
    label: {
      color: 'rgba(255,255,255,0.45)',
      fontSize: rem(10),
      letterSpacing: '0.1em',
      textTransform: 'uppercase' as const,
      marginBottom: rem(4),
    },
    dropdown: {
      background: COLOR_DROPDOWN_BG,
      border: `1px solid ${COLOR_INPUT_BORDER}`,
      borderRadius: 0,
    },
    option: {
      fontSize: rem(13),
      '&[data-combobox-selected]': { background: `${primary}33` },
      '&[data-combobox-hovered]':  { background: COLOR_DIVIDER },
    },
  }

  const switchStyles = {
    track: {
      background: 'rgba(255,255,255,0.08)',
      border: `1px solid ${COLOR_INPUT_BORDER}`,
      '&[data-checked]': { background: primary, borderColor: primary },
    },
    label: {
      color: 'rgba(255,255,255,0.55)',
      fontSize: rem(12),
      paddingLeft: rem(8),
    },
  }

  useEffect(() => { if (isOpen) setState({ ...config }) }, [isOpen])

  useEffect(() => {
    const validTypes = (BAR_TYPES[state.layout] ?? BAR_TYPES.minimap).map((t) => t.value)
    if (!validTypes.includes(state.statusType)) {
      setState((s) => ({ ...s, statusType: validTypes[0] as HudConfig['statusType'] }))
    }
  }, [state.layout])

  const onClose = () => {
    useHudStore.setState({ settings: false })
    nui.send('CloseUI')
  }

  const onSave = (e: React.FormEvent) => {
    e.preventDefault()
    useHudStore.setState({ config: state })
    nui.send('SaveConfig', state)
    onClose()
  }

  const set = (key: keyof HudConfig, value: unknown) =>
    setState((s) => ({ ...s, [key]: value }))

  const statusTypeOptions = BAR_TYPES[state.layout] ?? BAR_TYPES.minimap

  if (!isOpen) return null
  return (
    <Box style={{
      position: 'fixed', inset: 0,
      background: COLOR_MODAL_OVERLAY,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      zIndex: 1000,
    }}>
      <Box style={{
        width: rem(680),
        background: COLOR_BG_DARK,
        border: `1px solid ${COLOR_PANEL_BORDER}`,
        overflow: 'hidden',
      }}>

        {/* Header */}
        <Box style={{ padding: `${rem(14)} ${rem(16)} ${rem(12)}` }}>
          <Box style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
            <Box>
              <Text style={{
                fontSize: rem(13), fontWeight: 700,
                letterSpacing: '0.1em', textTransform: 'uppercase',
                color: 'rgba(255,255,255,0.9)', lineHeight: 1,
              }}>
                HUD Configuration
              </Text>
              <Box style={{ width: rem(28), height: rem(2), background: primary, marginTop: rem(6) }} />
            </Box>
            <Box
              onClick={onClose}
              style={{ cursor: 'pointer', color: 'rgba(255,255,255,0.3)', fontSize: rem(11), paddingTop: rem(2) }}
              onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.color = '#fff' }}
              onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.color = 'rgba(255,255,255,0.3)' }}
            >
              <FontAwesomeIcon icon={['fas', 'xmark']} />
            </Box>
          </Box>
        </Box>

        {/* Divider */}
        <Box style={{ height: rem(1), background: COLOR_DIVIDER }} />

        {/* Content */}
        <form onSubmit={onSave}>
          <Box style={{ padding: `${rem(18)} ${rem(20)}` }}>
            <Grid gutter={rem(32)}>
              {/* Left column */}
              <Grid.Col span={6}>
                <SectionHeader primary={primary}>General</SectionHeader>
                <Stack gap={rem(10)}>
                  <Switch label="Mask Radio Channel" checked={state.maskRadio} onChange={(e) => set('maskRadio', e.target.checked)} styles={switchStyles} />
                  <Select label="Status Layout" value={state.layout} data={LAYOUTS} onChange={(v) => set('layout', v as HudConfig['layout'])} styles={fieldStyles} comboboxProps={{ zIndex: 1001 }} />
                  {state.layout === 'minimap' && (
                    <Switch label="Anchor Buffs Above Status" checked={state.buffsAnchor2} onChange={(e) => set('buffsAnchor2', e.target.checked)} styles={switchStyles} />
                  )}
                </Stack>

                <Box style={{ height: rem(1), background: COLOR_DIVIDER, margin: `${rem(16)} 0` }} />

                <SectionHeader primary={primary}>Compass</SectionHeader>
                <Stack gap={rem(10)}>
                  <Switch label="Hide Cross Street" checked={state.hideCrossStreet} onChange={(e) => set('hideCrossStreet', e.target.checked)} styles={switchStyles} />
                </Stack>

              </Grid.Col>

              {/* Right column */}
              <Grid.Col span={6}>
                <SectionHeader primary={primary}>Status</SectionHeader>
                <Stack gap={rem(10)}>
                  <Select label="Display Type" value={state.statusType} data={statusTypeOptions} onChange={(v) => set('statusType', v as HudConfig['statusType'])} styles={fieldStyles} comboboxProps={{ zIndex: 1001 }} />
                  {state.statusType === 'circles' && (
                    <Switch label="Show Numbers In Circles" checked={state.circleNumbers} onChange={(e) => set('circleNumbers', e.target.checked)} styles={switchStyles} />
                  )}
                </Stack>

                <Box style={{ height: rem(1), background: COLOR_DIVIDER, margin: `${rem(16)} 0` }} />

                <SectionHeader primary={primary}>Progress Bar</SectionHeader>
                <Stack gap={rem(10)}>
                  <Select
                    label="Style"
                    value={state.progressStyle}
                    data={[{ value: 'ticks', label: 'Ticks' }, { value: 'minimal', label: 'Minimal' }]}
                    onChange={(v) => set('progressStyle', v as HudConfig['progressStyle'])}
                    styles={fieldStyles}
                    comboboxProps={{ zIndex: 1001 }}
                  />
                </Stack>

                <Box style={{ height: rem(1), background: COLOR_DIVIDER, margin: `${rem(16)} 0` }} />

                <SectionHeader primary={primary}>Vehicle</SectionHeader>
                <Stack gap={rem(10)}>
                  <Select label="Vehicle Layout" value={state.vehicle} data={VEH_LAYOUTS} onChange={(v) => set('vehicle', v as HudConfig['vehicle'])} styles={fieldStyles} comboboxProps={{ zIndex: 1001 }} />
                </Stack>
              </Grid.Col>
            </Grid>
          </Box>

          {/* Divider */}
          <Box style={{ height: rem(1), background: COLOR_DIVIDER }} />

          {/* Footer */}
          <Box style={{ padding: `${rem(10)} ${rem(16)}`, display: 'flex', justifyContent: 'flex-end', gap: rem(8) }}>
            <Box
              onClick={onClose}
              style={{
                cursor: 'pointer', padding: `${rem(6)} ${rem(16)}`,
                border: '1px solid rgba(255,255,255,0.10)',
                color: 'rgba(255,255,255,0.4)',
                fontSize: rem(12), letterSpacing: '0.06em', userSelect: 'none',
              }}
              onMouseEnter={(e) => { const el = e.currentTarget as HTMLElement; el.style.color = '#fff'; el.style.borderColor = 'rgba(255,255,255,0.25)' }}
              onMouseLeave={(e) => { const el = e.currentTarget as HTMLElement; el.style.color = 'rgba(255,255,255,0.4)'; el.style.borderColor = COLOR_INPUT_BORDER }}
            >
              Cancel
            </Box>
            <button
              type="submit"
              style={{
                cursor: 'pointer', padding: `${rem(6)} ${rem(16)}`,
                background: `${primary}22`, border: `1px solid ${primary}70`,
                color: '#fff', fontSize: rem(12), letterSpacing: '0.06em',
                userSelect: 'none', fontFamily: 'inherit',
              }}
              onMouseEnter={(e) => { e.currentTarget.style.background = `${primary}44` }}
              onMouseLeave={(e) => { e.currentTarget.style.background = `${primary}22` }}
            >
              Save
            </button>
          </Box>
        </form>

      </Box>
    </Box>
  )
}
