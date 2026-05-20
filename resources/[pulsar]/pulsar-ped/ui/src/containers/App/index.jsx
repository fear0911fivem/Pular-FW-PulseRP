import React, { Fragment, useEffect, useState } from 'react';
import { connect, useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';
import { library } from '@fortawesome/fontawesome-svg-core';
import { fas } from '@fortawesome/free-solid-svg-icons';
import { far } from '@fortawesome/free-regular-svg-icons';
import { fab } from '@fortawesome/free-brands-svg-icons';
import { Fade } from '@mui/material';

import { Loader } from '../../components/UIComponents';
import Creator from '../Creator';
import Shop from '../Shop/Shop';
import Surgery from '../Surgery/Surgery';
import Barber from '../Barber';
import Tattoo from '../Tattoo';

library.add(fab, fas, far);

const useStyles = makeStyles((theme) => ({
	wrapper: {
		color: '#fff',
		inset: 0,
		width: '100%',
		height: '100%',
		position: 'fixed',
		display: 'flex',
		flexDirection: 'column',
		zIndex: 1000,
		'--green-bg': '#425c2c',
		'--dark-green-bg': 'rgba(26, 31, 20, 0.85)',
		'--black': 'rgba(0, 0, 0, 0.5)',
		'--black-hover': 'rgba(0, 0, 0, 0.75)',
	},
	content: {
		position: 'relative',
		flex: 1,
		width: '100%',
		minHeight: 0,
		display: 'flex',
	},
}));

export default connect()((props) => {
	const classes = useStyles();
	const hidden = useSelector((state) => state.app.hidden);
	const state = useSelector((state) => state.app.state);
	const loading = useSelector((state) => state.app.loading);
	const [display, setDisplay] = useState(<Fragment />);

	useEffect(() => {
		switch (state) {
			case 'CREATOR':
				setDisplay(<Creator />);
				break;
			case 'SHOP':
				setDisplay(<Shop />);
				break;
			case 'BARBER':
				setDisplay(<Barber />);
				break;
			case 'TATTOO':
				setDisplay(<Tattoo />);
				break;
			case 'SURGERY':
				setDisplay(<Surgery />);
				break;
			default:
				setDisplay(<Fragment />);
				break;
		}
	}, [state]);

	return (
		<Fade in={!hidden}>
			<div className="App">
				<div className={classes.wrapper}>
					<div className={classes.content}>
						{loading ? <Loader /> : display}
					</div>
				</div>
			</div>
		</Fade>
	);
});
