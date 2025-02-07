// Default values for development
const defaults = {
  API_BASE_URL: 'http://localhost:3000/api',
  HEARTBEAT_INTERVAL: 30000, // 30 seconds
  TASK_POLL_INTERVAL: 5000, // 5 seconds
};

// Try to get values from process.env, fall back to defaults
export const API_BASE_URL = defaults.API_BASE_URL;
export const HEARTBEAT_INTERVAL = defaults.HEARTBEAT_INTERVAL;
export const TASK_POLL_INTERVAL = defaults.TASK_POLL_INTERVAL;