import React, { useEffect, useState } from 'react';
import {
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
  IconButton,
  CircularProgress,
  Typography,
} from '@mui/material';
import { PlayArrow, Stop } from '@mui/icons-material';
import { taskService } from '../services/TaskService';
import { Task } from '../types';

export const TaskList: React.FC = () => {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const updateTasks = (newTasks: Task[]) => {
      setTasks(newTasks);
      setLoading(false);
    };

    taskService.subscribe(updateTasks);
    return () => taskService.unsubscribe(updateTasks);
  }, []);

  const handleStartTask = async (taskId: number) => {
    try {
      await taskService.startTask(taskId);
    } catch (error) {
      console.error('Failed to start task:', error);
    }
  };

  const handleStopTask = async (taskId: number) => {
    try {
      await taskService.stopTask(taskId);
    } catch (error) {
      console.error('Failed to stop task:', error);
    }
  };

  if (loading) {
    return <CircularProgress />;
  }

  if (tasks.length === 0) {
    return (
      <Typography variant="body1" color="textSecondary">
        No tasks available
      </Typography>
    );
  }

  return (
    <List>
      {tasks.map((task) => (
        <ListItem key={task.id}>
          <ListItemText
            primary={task.name}
            secondary={`Status: ${task.status} | Progress: ${task.progress || 0}%`}
          />
          <ListItemSecondaryAction>
            {task.status === 'pending' && (
              <IconButton
                edge="end"
                aria-label="start"
                onClick={() => handleStartTask(task.id)}
              >
                <PlayArrow />
              </IconButton>
            )}
            {task.status === 'running' && (
              <IconButton
                edge="end"
                aria-label="stop"
                onClick={() => handleStopTask(task.id)}
              >
                <Stop />
              </IconButton>
            )}
          </ListItemSecondaryAction>
        </ListItem>
      ))}
    </List>
  );
};