import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    host: '10.0.2.200', // バインドするIPアドレス
    port: 5173,         // ポート番号
    strictPort: true,   // このポートを強制的に使用（他のプロセスが使用している場合エラーになります）
  }
});
