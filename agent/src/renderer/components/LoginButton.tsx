import React, { useEffect, useState } from 'react';
import {
  Button,
  Menu,
  MenuItem,
  Avatar,
  IconButton,
  CircularProgress,
} from '@mui/material';
import { Google as GoogleIcon } from '@mui/icons-material';
import { authService, type User, type LoginOptions } from '../services/AuthService';

export const LoginButton: React.FC = () => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [loginOptions, setLoginOptions] = useState<LoginOptions | null>(null);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);

  useEffect(() => {
    const handleOAuthCallback = async () => {
      console.log('Checking for OAuth callback. Path:', window.location.pathname);
      // Check if we're on the callback route
      if (window.location.pathname === '/auth/callback') {
        const urlParams = new URLSearchParams(window.location.search);
        const error = urlParams.get('error');
        console.log('OAuth callback params:', Object.fromEntries(urlParams.entries()));

        if (error) {
          console.error('OAuth error:', error);
          return;
        }

        try {
          const token = urlParams.get('token');
          // Construct user object from URL parameters
          const user = {
            id: parseInt(urlParams.get('user[id]') || '0', 10),
            email: urlParams.get('user[email]') || '',
            name: urlParams.get('user[name]') || '',
            provider: urlParams.get('user[provider]') || ''
          };
          
          console.log('Constructed user data:', user);
          
          if (token && user.id && user.email) {
            authService.setSession(token, user);
            console.log('Session set successfully');
          }
          
          // Use window.location.replace to avoid adding to browser history
          window.location.replace('/');
        } catch (error) {
          console.error('Failed to handle OAuth callback:', error);
        }
      }
    };

    const updateUser = (newUser: User | null) => {
      console.log('User state updated:', newUser);
      setUser(newUser);
      setLoading(false);
    };

    const loadLoginOptions = async () => {
      try {
        const options = await authService.getLoginOptions();
        console.log('Loaded login options:', options);
        setLoginOptions(options);
      } catch (error) {
        console.error('Failed to load login options:', error);
      }
    };

    // Check if we have a saved session on mount
    const savedUser = authService.getUser();
    console.log('Initial saved user:', savedUser);
    if (savedUser) {
      updateUser(savedUser);
    }

    handleOAuthCallback();
    authService.subscribe(updateUser);
    loadLoginOptions();

    return () => {
      authService.unsubscribe(updateUser);
    };
  }, []);

  const handleLogin = () => {
    if (loginOptions?.providers.google) {
      // Use the full URL for OAuth redirect
      window.location.href = `http://localhost:3000${loginOptions.providers.google.url}`;
    }
  };

  const handleMenuClick = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
  };

  const handleLogout = () => {
    authService.logout();
    handleMenuClose();
  };

  if (loading) {
    return <CircularProgress size={24} />;
  }

  if (user) {
    return (
      <>
        <IconButton
          onClick={handleMenuClick}
          size="small"
          sx={{ ml: 2 }}
          aria-controls={Boolean(anchorEl) ? 'account-menu' : undefined}
          aria-haspopup="true"
          aria-expanded={Boolean(anchorEl) ? 'true' : undefined}
        >
          <Avatar sx={{ width: 32, height: 32 }}>
            {user.name.charAt(0).toUpperCase()}
          </Avatar>
        </IconButton>
        <Menu
          anchorEl={anchorEl}
          open={Boolean(anchorEl)}
          onClose={handleMenuClose}
          onClick={handleMenuClose}
          transformOrigin={{ horizontal: 'right', vertical: 'top' }}
          anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
        >
          <MenuItem disabled>
            {user.email}
          </MenuItem>
          <MenuItem onClick={handleLogout}>
            Logout
          </MenuItem>
        </Menu>
      </>
    );
  }

  return (
    <Button
      variant="outlined"
      startIcon={<GoogleIcon />}
      onClick={handleLogin}
      sx={{ ml: 2 }}
    >
      Sign in with Google
    </Button>
  );
}; 