import React, { useEffect, useMemo } from 'react';
import { useSelector } from 'react-redux';
import { throttle } from 'lodash';

import Nui from '../../util/Nui';

export default (props) => {
	const rotate = useMemo(
		() =>
			throttle((dir) => {
				Nui.send(`Rotate${dir}`);
			}, 50),
		[],
	);

	const handleDown = (event) => {
		if (event.keyCode === 81) {
			rotate('Left');
		} else if (event.keyCode == 69) {
			rotate('Right');
		}
	};

	const handleUp = (event) => {
		if (event.keyCode == 82) {
			Nui.send(`Animation`);
		}
	};
	const handleScroll = (event) => {
		const elm = document.getElementById('noHover');
		if (elm && elm.matches(':hover')) return;
		if (event.target?.closest?.('[data-no-camera-controls]')) return;

		Nui.send('Zoom', {
			dy: event.deltaY,
		});
	};

	useEffect(() => {
		window.addEventListener('keydown', handleDown);
		window.addEventListener('keyup', handleUp);
		window.addEventListener('wheel', handleScroll);

		return () => {
			window.removeEventListener('keydown', handleDown);
			window.removeEventListener('keyup', handleUp);
			window.removeEventListener('wheel', handleScroll);
		};
	}, []);

	return React.Children.only(props.children);
};
