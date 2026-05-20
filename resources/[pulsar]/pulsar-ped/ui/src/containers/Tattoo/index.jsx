import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';

import { CancelEdits, SavePed } from '../../actions/pedActions';
import { CurrencyFormat } from '../../util/Parser';
import { Dialog } from '../../components/UIComponents';
import SrpPedMenu from '../../components/PedComponents/SrpPedMenu';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		width: '100%',
		height: '100%',
		position: 'relative',
	},
	highlight: {
		color: theme.palette.primary.main,
	},
}));

export default () => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const state = useSelector((state) => state.app.state);
	const cost = useSelector((state) => state.app.pricing.TATTOO);

	const [cancelling, setCancelling] = useState(false);
	const [saving, setSaving] = useState(false);

	const onCancel = () => {
		setCancelling(false);
		dispatch(CancelEdits());
	};

	const onSave = () => {
		setSaving(false);
		dispatch(SavePed(state));
	};

	return (
		<div className={classes.wrapper}>
			<SrpPedMenu
				mode="tattoo"
				saveLabel="Save Everything"
				onDiscard={() => setCancelling(true)}
				onSave={() => setSaving(true)}
			/>

			<Dialog title="Cancel?" open={cancelling} onAccept={onCancel} onDecline={() => setCancelling(false)} acceptLang="Yes" declineLang="No">
				<p>All changes will be discarded, are you sure you want to continue?</p>
			</Dialog>
			<Dialog title="Save Tattoos?" open={saving} onAccept={onSave} onDecline={() => setSaving(false)}>
				<p>You will be charged <span className={classes.highlight}>{CurrencyFormat.format(cost)}</span>?</p>
				<p>Are you sure you want to save?</p>
			</Dialog>
		</div>
	);
};
