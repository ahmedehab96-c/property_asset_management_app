import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(({ command }) => ({
  plugins: [react()],
  base: command === 'build' ? '/dashboard/' : '/',
  build: {
    outDir: '../backend/public/dashboard',
    emptyOutDir: true,
  },
  server: {
    port: 5173,
  },
}));
