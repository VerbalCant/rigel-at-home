import React, { useEffect, useState } from 'react';
import {
  List,
  ListItem,
  ListItemText,
  CircularProgress,
  Chip,
  Box,
  Typography,
} from '@mui/material';
import { agentService } from '../services/AgentService';
import { SystemInfo as SystemInfoType } from '../types';

export const SystemInfo: React.FC = () => {
  const [systemInfo, setSystemInfo] = useState<SystemInfoType | null>(null);

  useEffect(() => {
    const fetchSystemInfo = async () => {
      try {
        const info = await agentService.getSystemInfo();
        setSystemInfo(info);
      } catch (error) {
        console.error('Failed to fetch system info:', error);
      }
    };

    fetchSystemInfo();
  }, []);

  if (!systemInfo) {
    return <CircularProgress />;
  }

  const formatMemory = (bytes: number): string => {
    const gb = bytes / (1024 * 1024 * 1024);
    return `${gb.toFixed(1)} GB`;
  };

  return (
    <List>
      <ListItem>
        <ListItemText
          primary="Memory"
          secondary={formatMemory(systemInfo.memory)}
        />
      </ListItem>
      <ListItem>
        <ListItemText
          primary="CPU Cores"
          secondary={systemInfo.cpuCores}
        />
      </ListItem>
      <ListItem>
        <ListItemText
          primary="Features"
          secondary={
            <Typography component="span" variant="body2">
              <Box sx={{ mt: 1 }}>
                {systemInfo.features.map((feature) => (
                  <Chip
                    key={feature}
                    label={feature}
                    size="small"
                    sx={{ mr: 1, mb: 1 }}
                  />
                ))}
              </Box>
            </Typography>
          }
        />
      </ListItem>
    </List>
  );
};