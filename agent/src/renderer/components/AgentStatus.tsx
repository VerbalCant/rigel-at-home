import React, { useEffect, useState } from 'react';
import { Chip } from '@mui/material';
import { agentService } from '../services/AgentService';
import { AgentStatus as AgentStatusType } from '../types';

export const AgentStatus: React.FC = () => {
  const [status, setStatus] = useState<AgentStatusType>('offline');

  useEffect(() => {
    const updateStatus = (newStatus: AgentStatusType) => {
      setStatus(newStatus);
    };

    agentService.subscribeToStatus(updateStatus);
    return () => agentService.unsubscribeFromStatus(updateStatus);
  }, []);

  const getStatusColor = (status: AgentStatusType): 'success' | 'error' | 'warning' => {
    switch (status) {
      case 'online':
        return 'success';
      case 'offline':
        return 'error';
      case 'busy':
        return 'warning';
      default:
        return 'error';
    }
  };

  return (
    <Chip
      label={status.toUpperCase()}
      color={getStatusColor(status)}
      variant="outlined"
      sx={{ ml: 2 }}
    />
  );
};