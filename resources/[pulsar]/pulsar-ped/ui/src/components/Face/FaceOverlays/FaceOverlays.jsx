import React, { Fragment } from 'react';
import { Overlay } from '../../PedComponents';
import { useSelector } from 'react-redux';

export default (props) => {
	const ped = useSelector((state) => state.app.ped);

	return (
		<div style={{ display: 'flex', flexDirection: 'column', gap: '.75rem' }}>
			<Overlay
				label={'Blemishes'}
				data={{
					type: 'blemish',
					id: 0,
				}}
				current={ped.customization.overlay.blemish}
				max={23}
			/>
			<Overlay
				label={'Ageing'}
				data={{
					type: 'ageing',
					id: 3,
				}}
				current={ped.customization.overlay.ageing}
				max={14}
			/>
			<Overlay
				label={'Complexion'}
				data={{
					type: 'complexion',
					id: 6,
				}}
				current={ped.customization.overlay.complexion}
				max={11}
			/>
			<Overlay
				label={'Sun Damage'}
				data={{
					type: 'sundamage',
					id: 7,
				}}
				current={ped.customization.overlay.sundamage}
				max={10}
			/>
			<Overlay
				label={'Moles / Freckles'}
				data={{
					type: 'freckles',
					id: 9,
				}}
				current={ped.customization.overlay.freckles}
				max={10}
			/>
		</div>
	);
};
