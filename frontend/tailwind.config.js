/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        // my.gov.uz palette — bright, slightly cooler primary,
        // generous gold accent for badges/buttons.
        gov: {
          50: '#eef4fb',
          100: '#d9e7f6',
          200: '#aac9ea',
          300: '#75a7dc',
          400: '#4287cc',
          500: '#1c6cba',
          600: '#0F5BA8', // primary brand (close to my.gov.uz)
          700: '#0a4789',
          800: '#0a3567',
          900: '#06203f',
        },
        govgray: {
          50:  '#f5f7fa',
          100: '#eceff4',
          200: '#dde2ea',
          300: '#c5cdd9',
          500: '#67738a',
          700: '#3b4759',
          900: '#13223b',
        },
        govgold: {
          50:  '#fdf6e3',
          400: '#f1c232',
          500: '#e5a516',
          600: '#bd820b',
        },
        govaccent: '#e5f1fb',
        // legacy aliases for existing components
        'brand-blue': {
          50:  '#f0f6fc',
          100: '#dceaf7',
          500: '#1f6fb6',
          800: '#005EAA',
          900: '#003366',
        },
        success: {
          100: '#dcfce7',
          500: '#16a34a',
          700: '#15803d',
        },
        danger: {
          100: '#fee2e2',
          500: '#dc2626',
        },
        unknown: '#94a3b8',
        warning: '#d97706',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'Segoe UI', 'sans-serif'],
      },
      boxShadow: {
        'card': '0 1px 2px rgba(0,0,0,0.05)',
        'card-hover': '0 4px 6px -1px rgba(0,0,0,0.1)',
        'elevated': '0 10px 15px -3px rgba(0,0,0,0.1)',
      },
      transitionTimingFunction: {
        'out-expo': 'cubic-bezier(0.16, 1, 0.3, 1)',
      },
      keyframes: {
        shimmer: {
          '0%': { backgroundPosition: '-1000px 0' },
          '100%': { backgroundPosition: '1000px 0' },
        },
        'fade-in': {
          '0%': { opacity: '0', transform: 'translateY(4px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
      },
      animation: {
        shimmer: 'shimmer 2s linear infinite',
        'fade-in': 'fade-in 300ms cubic-bezier(0.16, 1, 0.3, 1)',
      },
    },
  },
  plugins: [],
};
