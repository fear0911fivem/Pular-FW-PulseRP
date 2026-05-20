import React, { Fragment, useEffect } from 'react';
import { Overlay, OverlayColors } from '../../PedComponents';
import { useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';
import ElementBox from '../../UIComponents/ElementBox/ElementBox';
import { Ticker } from '../../UIComponents';
import { SetPedHairColor } from '../../../actions/pedActions';
import Nui from '../../../util/Nui';

const useStyles = makeStyles(theme => ({
  body: {
    display: 'grid',
    gap: '.75rem',
    gridTemplateColumns: 'auto minmax(0, 1fr)',
    alignItems: 'stretch',
  },
  color: {
    width: '50%',
    height: '50%',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    margin: 'auto',
    position: 'relative',
    border: '2px solid #3e4148',
  },
}));

export default props => {
  const classes = useStyles();
  const ped = useSelector(state => state.app.ped);
  const colorsMax = useSelector(state => state.app.hairColors);

  // useEffect(() => {
  //   Nui.send("GetPedHairRgbColor", {
  //     type: 'color1',
  //     name: 'chesthair',
  //     colorId: ped.customization.colors.chesthair.color1.index
  //   })
  // }, [ped.customization.colors.chesthair.color1.index]);

  // useEffect(() => {
  //   Nui.send("GetPedHairRgbColor", {
  //     type: 'color2',
  //     name: 'chesthair',
  //     colorId: ped.customization.colors.chesthair.color2.index
  //   })
  // }, [ped.customization.colors.chesthair.color2.index]);

  return <Fragment>
    <Overlay
      label={'Chest Hair'}
      data={{
        type: 'chesthair',
        id: 12,
      }}
      current={ped.customization.overlay.chesthair}
      max={16}
    />
    <OverlayColors
      label={'Chest Hair Colors'}
      data={{
        type: 'chesthair',
        id: 2,
      }}
      current={ped.customization.overlay.chesthair}
		/>
  </Fragment>;
}
