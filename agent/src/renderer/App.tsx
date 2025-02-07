import React, { useEffect, useState } from 'react';
import {
  AppBar,
  Box,
  Container,
  Paper,
  Toolbar,
  Typography,
  CircularProgress,
  Grid,
} from '@mui/material';
import { TaskList } from './components/TaskList';
import { SystemInfo } from './components/SystemInfo';
import { AgentStatus } from './components/AgentStatus';
import { LoginButton } from './components/LoginButton';
import { taskService } from './services/TaskService';
import { agentService } from './services/AgentService';

const App: React.FC = () => {
  const [isInitialized, setIsInitialized] = useState(false);

  useEffect(() => {
    const initializeAgent = async () => {
      try {
        await agentService.initialize();
        setIsInitialized(true);
        taskService.startPolling();
      } catch (error) {
        console.error('Failed to initialize agent:', error);
      }
    };

    initializeAgent();

    return () => {
      taskService.stopPolling();
    };
  }, []);

  if (!isInitialized) {
    return (
      <Box
        display="flex"
        justifyContent="center"
        alignItems="center"
        minHeight="100vh"
      >
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box sx={{ flexGrow: 1 }}>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Rigel@Home Agent
          </Typography>
          <AgentStatus />
          <LoginButton />
        </Toolbar>
      </AppBar>

      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        <Grid container spacing={3}>
          <Grid item xs={12} md={8}>
            <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column' }}>
              <Typography component="h2" variant="h6" color="primary" gutterBottom>
                Tasks
              </Typography>
              <TaskList />
            </Paper>
          </Grid>
          <Grid item xs={12} md={4}>
            <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column' }}>
              <Typography component="h2" variant="h6" color="primary" gutterBottom>
                System Information
              </Typography>
              <SystemInfo />
            </Paper>
          </Grid>
        </Grid>
      </Container>
    </Box>
  );
};

export default App;