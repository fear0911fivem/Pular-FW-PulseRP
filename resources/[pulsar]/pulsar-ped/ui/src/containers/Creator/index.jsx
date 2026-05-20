import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { makeStyles } from '@mui/styles';

import { CancelEdits, SavePed } from '../../actions/pedActions';
import { Dialog } from '../../components/UIComponents';
import SrpPedMenu from '../../components/PedComponents/SrpPedMenu';

const useStyles = makeStyles(() => ({
	wrapper: {
		width: '100%',
		height: '100%',
		position: 'relative',
	},
}));

export default () => {
	const classes = useStyles();
	const dispatch = useDispatch();
	const state = useSelector((state) => state.app.state);

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
				mode="creator"
				saveLabel="Save Everything"
				onDiscard={() => setCancelling(true)}
				onSave={() => setSaving(true)}
			/>

			<Dialog title="Cancel?" open={cancelling} onAccept={onCancel} onDecline={() => setCancelling(false)} acceptLang="Yes" declineLang="No">
				<p>All changes will be discarded, are you sure you want to continue?</p>
			</Dialog>
			<Dialog title="Create Character Ped?" open={saving} onAccept={onSave} onDecline={() => setSaving(false)}>
				<p>Are you sure you want to save?</p>
				<p>
					You may not be able to edit some things after this screen,
					ensure you are totally done creating your character before
					you continue!
				</p>
			</Dialog>
		</div>
	);
};
