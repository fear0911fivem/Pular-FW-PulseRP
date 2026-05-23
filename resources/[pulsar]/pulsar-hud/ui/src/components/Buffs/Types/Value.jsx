import React from 'react';
import BuffIcon from './BuffIcon';

export default ({ buff }) => <BuffIcon buff={buff} progress={buff.val} />;
