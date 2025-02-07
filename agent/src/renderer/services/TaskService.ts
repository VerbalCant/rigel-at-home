import axios from 'axios';
import { Task, TaskProgress } from '../types';
import { API_BASE_URL } from '../config';
import { agentService } from './AgentService';

// Mock IPC for browser-only development
const mockIpc = {
  on: () => {},
  invoke: async () => ({
    output: 'Task executed successfully',
    executionTime: 1.5
  }),
};

// Use real IPC in Electron, mock in browser
const ipcRenderer = (window as any).electron?.ipcRenderer || mockIpc;

type TaskUpdateCallback = (tasks: Task[]) => void;
type TaskProgressCallback = (progress: TaskProgress) => void;

class TaskService {
  private subscribers: TaskUpdateCallback[] = [];
  private progressSubscribers: TaskProgressCallback[] = [];
  private pollingInterval: NodeJS.Timeout | null = null;

  constructor() {
    ipcRenderer.on('task-progress', (progress: TaskProgress) => {
      this.progressSubscribers.forEach(callback => callback(progress));
    });
  }

  private getAxiosConfig() {
    const token = agentService.getToken();
    return {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': token ? `Bearer ${token}` : undefined
      }
    };
  }

  subscribe(callback: TaskUpdateCallback) {
    this.subscribers.push(callback);
  }

  unsubscribe(callback: TaskUpdateCallback) {
    this.subscribers = this.subscribers.filter(cb => cb !== callback);
  }

  subscribeToProgress(callback: TaskProgressCallback) {
    this.progressSubscribers.push(callback);
  }

  unsubscribeFromProgress(callback: TaskProgressCallback) {
    this.progressSubscribers = this.progressSubscribers.filter(cb => cb !== callback);
  }

  startPolling() {
    this.stopPolling();
    this.pollingInterval = setInterval(this.pollTasks.bind(this), 5000);
    this.pollTasks();
  }

  stopPolling() {
    if (this.pollingInterval) {
      clearInterval(this.pollingInterval);
      this.pollingInterval = null;
    }
  }

  private async pollTasks() {
    try {
      const response = await axios.get<Task[]>(`${API_BASE_URL}/tasks`, this.getAxiosConfig());
      this.subscribers.forEach(callback => callback(response.data));
    } catch (error) {
      console.error('Failed to poll tasks:', error);
    }
  }

  async startTask(taskId: number) {
    try {
      await axios.put(`${API_BASE_URL}/tasks/${taskId}/progress`, {
        status: 'running'
      }, this.getAxiosConfig());
      const result = await ipcRenderer.invoke('execute-task', { id: taskId });
      await axios.put(`${API_BASE_URL}/tasks/${taskId}/complete`, { result }, this.getAxiosConfig());
    } catch (error) {
      console.error('Failed to start task:', error);
      throw error;
    }
  }

  async stopTask(taskId: number) {
    try {
      await axios.put(`${API_BASE_URL}/tasks/${taskId}/fail`, {
        error_message: 'Task stopped by user'
      }, this.getAxiosConfig());
    } catch (error) {
      console.error('Failed to stop task:', error);
      throw error;
    }
  }
}

export const taskService = new TaskService();