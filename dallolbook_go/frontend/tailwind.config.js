/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary:  { DEFAULT: '#1a56db', hover: '#1e429f' },
        secondary:{ DEFAULT: '#f59e0b', hover: '#d97706' },
      },
    },
  },
  plugins: [],
}
