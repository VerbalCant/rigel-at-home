import axios from 'axios';
import { API_BASE_URL } from '../config';

export interface LoginOptions {
  providers: {
    [key: string]: {
      url: string;
      name: string;
    };
  };
}

export interface User {
  id: number;
  email: string;
  name: string;
  provider: string;
}

type AuthCallback = (user: User | null) => void;

class AuthService {
  private token: string | null = null;
  private user: User | null = null;
  private subscribers: AuthCallback[] = [];

  constructor() {
    // Try to restore session from localStorage
    const savedToken = localStorage.getItem('userToken');
    const savedUser = localStorage.getItem('user');
    if (savedToken && savedUser) {
      this.token = savedToken;
      this.user = JSON.parse(savedUser);
      this.notifySubscribers();
    }
  }

  subscribe(callback: AuthCallback) {
    this.subscribers.push(callback);
    // Immediately notify with current state
    callback(this.user);
  }

  unsubscribe(callback: AuthCallback) {
    this.subscribers = this.subscribers.filter(cb => cb !== callback);
  }

  private notifySubscribers() {
    this.subscribers.forEach(callback => callback(this.user));
  }

  async getLoginOptions(): Promise<LoginOptions> {
    const response = await axios.get(`${API_BASE_URL}/auth/login_options`);
    return response.data;
  }

  getUser(): User | null {
    return this.user;
  }

  getToken(): string | null {
    return this.token;
  }

  setSession(token: string, user: User) {
    this.token = token;
    this.user = user;
    localStorage.setItem('userToken', token);
    localStorage.setItem('user', JSON.stringify(user));
    this.notifySubscribers();
  }

  logout() {
    this.token = null;
    this.user = null;
    localStorage.removeItem('userToken');
    localStorage.removeItem('user');
    this.notifySubscribers();
  }

  async checkAuthStatus(): Promise<boolean> {
    try {
      const response = await axios.get(`${API_BASE_URL}/auth/test`, {
        headers: this.token ? { Authorization: `Bearer ${this.token}` } : undefined
      });
      
      if (response.data.authenticated) {
        this.user = response.data.user;
        this.notifySubscribers();
        return true;
      } else {
        this.logout();
        return false;
      }
    } catch (error) {
      this.logout();
      return false;
    }
  }
}

export const authService = new AuthService(); 