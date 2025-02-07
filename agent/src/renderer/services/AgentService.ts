import axios from 'axios';
import { AgentStatus, SystemInfo } from '../types';
import { API_BASE_URL } from '../config';

// Mock IPC for browser-only development
const mockIpc = {
  on: () => {},
  invoke: async () => ({
    memory: 8 * 1024 * 1024 * 1024, // 8GB
    cpuCores: 4,
    features: ['python3', 'openai'],
  }),
};

// Use real IPC in Electron, mock in browser
const ipcRenderer = (window as any).electron?.ipcRenderer || mockIpc;

type StatusCallback = (status: AgentStatus) => void;

class AgentService {
  private statusSubscribers: StatusCallback[] = [];
  private heartbeatInterval: NodeJS.Timeout | null = null;
  private token: string | null = null;

  async initialize() {
    try {
      console.log('Getting system info...');
      const systemInfo = await this.getSystemInfo();
      console.log('System info:', systemInfo);

      const registerUrl = `${API_BASE_URL}/agents/register`;
      console.log('Registering agent at:', registerUrl);

      const registerData = {
        agent: {
          name: `agent-${Math.random().toString(36).substring(7)}`,
          capabilities: systemInfo,
        }
      };
      console.log('Register payload:', registerData);

      const response = await axios.post(registerUrl, registerData);
      console.log('Register response:', response.data);

      this.token = response.data.token;
      axios.defaults.headers.common['Authorization'] = `Bearer ${this.token}`;

      this.startHeartbeat();
      return response.data;
    } catch (error: any) {
      console.error('Failed to initialize agent:', error);
      console.error('Error details:', {
        message: error.message,
        response: error.response?.data,
        status: error.response?.status,
        config: {
          url: error.config?.url,
          method: error.config?.method,
          data: error.config?.data,
        }
      });
      throw error;
    }
  }

  async getSystemInfo(): Promise<SystemInfo> {
    try {
      console.log('Invoking get-system-info...');
      const info = await ipcRenderer.invoke('get-system-info');
      console.log('System info result:', info);
      return info;
    } catch (error) {
      console.error('Failed to get system info:', error);
      throw error;
    }
  }

  subscribeToStatus(callback: StatusCallback) {
    this.statusSubscribers.push(callback);
  }

  unsubscribeFromStatus(callback: StatusCallback) {
    this.statusSubscribers = this.statusSubscribers.filter(cb => cb !== callback);
  }

  private startHeartbeat() {
    this.stopHeartbeat();
    this.heartbeatInterval = setInterval(this.sendHeartbeat.bind(this), 30000);
    this.sendHeartbeat();
  }

  private stopHeartbeat() {
    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval);
      this.heartbeatInterval = null;
    }
  }

  private async sendHeartbeat() {
    try {
      console.log('Sending heartbeat...');
      await axios.post(`${API_BASE_URL}/agents/heartbeat`);
      this.notifyStatusSubscribers('online');
    } catch (error) {
      console.error('Failed to send heartbeat:', error);
      this.notifyStatusSubscribers('offline');
    }
  }

  private notifyStatusSubscribers(status: AgentStatus) {
    console.log('Notifying status subscribers:', status);
    this.statusSubscribers.forEach(callback => callback(status));
  }

  async updateStatus(status: AgentStatus) {
    try {
      console.log('Updating status to:', status);
      await axios.put(`${API_BASE_URL}/agents/status`, { status });
      this.notifyStatusSubscribers(status);
    } catch (error) {
      console.error('Failed to update status:', error);
      throw error;
    }
  }
}

export const agentService = new AgentService();