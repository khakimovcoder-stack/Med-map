import axios from 'axios';
import toast from 'react-hot-toast';

const BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api/v1';

export const apiClient = axios.create({
  baseURL: BASE_URL,
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  },
});

// Unwrap envelope on success: backend returns { success, data, meta }
apiClient.interceptors.response.use(
  (response) => {
    const body = response.data;
    if (body && typeof body === 'object' && 'success' in body) {
      // Preserve meta on the unwrapped data so callers can read pagination info
      const unwrapped = body.data;
      if (unwrapped && typeof unwrapped === 'object' && !Array.isArray(unwrapped)) {
        Object.defineProperty(unwrapped, '__meta', {
          value: body.meta,
          enumerable: false,
        });
      }
      return unwrapped;
    }
    return body;
  },
  (error) => {
    const body = error?.response?.data;
    const message =
      body?.error?.message ||
      error?.message ||
      'Server bilan bog\'lanishda xatolik';
    // Avoid spamming the same toast on background polling
    toast.error(message, { id: 'api-error' });
    return Promise.reject(error);
  },
);
