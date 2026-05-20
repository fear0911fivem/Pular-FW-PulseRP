import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';

import { Dialog } from '../../components/UIComponents';
import { CurrencyFormat } from '../../util/Parser';
import { CancelEdits, SavePed } from '../../actions/pedActions';
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
	const cost = useSelector((state) => state.app.pricing.SHOP);

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
				mode="clothing"
				saveLabel="Save Everything"
				onDiscard={() => setCancelling(true)}
				onSave={() => setSaving(true)}
			/>

			<Dialog title="Cancel?" open={cancelling} onAccept={onCancel} onDecline={() => setCancelling(false)} acceptLang="Yes" declineLang="No">
				<p>All changes will be discarded, are you sure you want to continue?</p>
			</Dialog>
			<Dialog title="Save Outfit?" open={saving} onAccept={onSave} onDecline={() => setSaving(false)}>
				<p>You will be charged <span className={classes.highlight}>{CurrencyFormat.format(cost)}</span>?</p>
				<p>Are you sure you want to save?</p>
			</Dialog>
		</div>
	);
};
