import React, { useState } from 'react';
import useInterval from 'react-useinterval';
import BuffIcon from './BuffIcon';

export default ({ buff }) => {
    const [pct, setPct] = useState(Math.floor(Date.now() / 1000) - buff?.startTime);
    useInterval(
        () => {
            setPct(Math.floor(Date.now() / 1000) - buff?.startTime);
        },
        pct > buff.val ? null : (Boolean(buff?.options?.customInterval) ? buff?.options?.customInterval : 1000),
    );

    if (pct > buff.val) return null;
    return (
        <BuffIcon
            buff={buff}
            progress={Math.floor(
                ((buff.val - (pct > 0 ? pct - 1 : pct)) / buff.val) * 100,
            )}
        />
    );
};
