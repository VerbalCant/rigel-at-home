export type AgentStatus = 'online' | 'offline' | 'busy';

export interface SystemInfo {
  memory: number;
  cpuCores: number;
  features: string[];
}

export interface Task {
  id: number;
  name: string;
  description?: string;
  code: string;
  status: 'pending' | 'assigned' | 'running' | 'completed' | 'failed';
  progress?: number;
  result?: {
    output?: string;
    error?: string;
    executionTime?: number;
  };
}

export interface TaskProgress {
  percent: number;
  status: string;
  message?: string;
}