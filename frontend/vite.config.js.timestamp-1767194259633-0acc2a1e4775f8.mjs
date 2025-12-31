// vite.config.js
import { defineConfig } from "file:///home/project/frontend/node_modules/vite/dist/node/index.js";
import react from "file:///home/project/frontend/node_modules/@vitejs/plugin-react/dist/index.js";
import path from "path";
var __vite_injected_original_dirname = "/home/project/frontend";
var vite_config_default = defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__vite_injected_original_dirname, "./src")
    }
  },
  define: {
    "import.meta.env.VITE_SUPABASE_URL": JSON.stringify("https://lunifcuuhhsacibvbvwi.supabase.co"),
    "import.meta.env.VITE_SUPABASE_ANON_KEY": JSON.stringify("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx1bmlmY3V1aGhzYWNpYnZidndpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYzODY5OTksImV4cCI6MjA4MTk2Mjk5OX0.nFBKnJBqEARvErvygrNfHDY6KuAsgomSchhfB0L8iIE")
  },
  server: {
    port: 3e3,
    host: true
  },
  build: {
    outDir: "dist",
    sourcemap: false,
    chunkSizeWarningLimit: 1e3,
    rollupOptions: {
      output: {
        manualChunks: {
          recharts: ["recharts"],
          "ui-components": [
            "@/components/ui/card",
            "@/components/ui/button",
            "@/components/ui/input",
            "@/components/ui/select",
            "@/components/ui/dialog",
            "@/components/ui/table"
          ]
        }
      }
    }
  }
});
export {
  vite_config_default as default
};
//# sourceMappingURL=data:application/json;base64,ewogICJ2ZXJzaW9uIjogMywKICAic291cmNlcyI6IFsidml0ZS5jb25maWcuanMiXSwKICAic291cmNlc0NvbnRlbnQiOiBbImNvbnN0IF9fdml0ZV9pbmplY3RlZF9vcmlnaW5hbF9kaXJuYW1lID0gXCIvaG9tZS9wcm9qZWN0L2Zyb250ZW5kXCI7Y29uc3QgX192aXRlX2luamVjdGVkX29yaWdpbmFsX2ZpbGVuYW1lID0gXCIvaG9tZS9wcm9qZWN0L2Zyb250ZW5kL3ZpdGUuY29uZmlnLmpzXCI7Y29uc3QgX192aXRlX2luamVjdGVkX29yaWdpbmFsX2ltcG9ydF9tZXRhX3VybCA9IFwiZmlsZTovLy9ob21lL3Byb2plY3QvZnJvbnRlbmQvdml0ZS5jb25maWcuanNcIjtpbXBvcnQgeyBkZWZpbmVDb25maWcgfSBmcm9tICd2aXRlJ1xuaW1wb3J0IHJlYWN0IGZyb20gJ0B2aXRlanMvcGx1Z2luLXJlYWN0J1xuaW1wb3J0IHBhdGggZnJvbSAncGF0aCdcblxuZXhwb3J0IGRlZmF1bHQgZGVmaW5lQ29uZmlnKHtcbiAgcGx1Z2luczogW3JlYWN0KCldLFxuICByZXNvbHZlOiB7XG4gICAgYWxpYXM6IHtcbiAgICAgICdAJzogcGF0aC5yZXNvbHZlKF9fZGlybmFtZSwgJy4vc3JjJyksXG4gICAgfSxcbiAgfSxcbiAgZGVmaW5lOiB7XG4gICAgJ2ltcG9ydC5tZXRhLmVudi5WSVRFX1NVUEFCQVNFX1VSTCc6IEpTT04uc3RyaW5naWZ5KCdodHRwczovL2x1bmlmY3V1aGhzYWNpYnZidndpLnN1cGFiYXNlLmNvJyksXG4gICAgJ2ltcG9ydC5tZXRhLmVudi5WSVRFX1NVUEFCQVNFX0FOT05fS0VZJzogSlNPTi5zdHJpbmdpZnkoJ2V5SmhiR2NpT2lKSVV6STFOaUlzSW5SNWNDSTZJa3BYVkNKOS5leUpwYzNNaU9pSnpkWEJoWW1GelpTSXNJbkpsWmlJNklteDFibWxtWTNWMWFHaHpZV05wWW5aaWRuZHBJaXdpY205c1pTSTZJbUZ1YjI0aUxDSnBZWFFpT2pFM05qWXpPRFk1T1Rrc0ltVjRjQ0k2TWpBNE1UazJNams1T1gwLm5GQktuSkJxRUFSdkVydnlnck5mSERZNkt1QXNnb21TY2hoZkIwTDhpSUUnKSxcbiAgfSxcbiAgc2VydmVyOiB7XG4gICAgcG9ydDogMzAwMCxcbiAgICBob3N0OiB0cnVlLFxuICB9LFxuICBidWlsZDoge1xuICAgIG91dERpcjogJ2Rpc3QnLFxuICAgIHNvdXJjZW1hcDogZmFsc2UsXG4gICAgY2h1bmtTaXplV2FybmluZ0xpbWl0OiAxMDAwLFxuICAgIHJvbGx1cE9wdGlvbnM6IHtcbiAgICAgIG91dHB1dDoge1xuICAgICAgICBtYW51YWxDaHVua3M6IHtcbiAgICAgICAgICByZWNoYXJ0czogWydyZWNoYXJ0cyddLFxuICAgICAgICAgICd1aS1jb21wb25lbnRzJzogW1xuICAgICAgICAgICAgJ0AvY29tcG9uZW50cy91aS9jYXJkJyxcbiAgICAgICAgICAgICdAL2NvbXBvbmVudHMvdWkvYnV0dG9uJyxcbiAgICAgICAgICAgICdAL2NvbXBvbmVudHMvdWkvaW5wdXQnLFxuICAgICAgICAgICAgJ0AvY29tcG9uZW50cy91aS9zZWxlY3QnLFxuICAgICAgICAgICAgJ0AvY29tcG9uZW50cy91aS9kaWFsb2cnLFxuICAgICAgICAgICAgJ0AvY29tcG9uZW50cy91aS90YWJsZSdcbiAgICAgICAgICBdXG4gICAgICAgIH1cbiAgICAgIH1cbiAgICB9XG4gIH0sXG59KVxuIl0sCiAgIm1hcHBpbmdzIjogIjtBQUFvUCxTQUFTLG9CQUFvQjtBQUNqUixPQUFPLFdBQVc7QUFDbEIsT0FBTyxVQUFVO0FBRmpCLElBQU0sbUNBQW1DO0FBSXpDLElBQU8sc0JBQVEsYUFBYTtBQUFBLEVBQzFCLFNBQVMsQ0FBQyxNQUFNLENBQUM7QUFBQSxFQUNqQixTQUFTO0FBQUEsSUFDUCxPQUFPO0FBQUEsTUFDTCxLQUFLLEtBQUssUUFBUSxrQ0FBVyxPQUFPO0FBQUEsSUFDdEM7QUFBQSxFQUNGO0FBQUEsRUFDQSxRQUFRO0FBQUEsSUFDTixxQ0FBcUMsS0FBSyxVQUFVLDBDQUEwQztBQUFBLElBQzlGLDBDQUEwQyxLQUFLLFVBQVUsa05BQWtOO0FBQUEsRUFDN1E7QUFBQSxFQUNBLFFBQVE7QUFBQSxJQUNOLE1BQU07QUFBQSxJQUNOLE1BQU07QUFBQSxFQUNSO0FBQUEsRUFDQSxPQUFPO0FBQUEsSUFDTCxRQUFRO0FBQUEsSUFDUixXQUFXO0FBQUEsSUFDWCx1QkFBdUI7QUFBQSxJQUN2QixlQUFlO0FBQUEsTUFDYixRQUFRO0FBQUEsUUFDTixjQUFjO0FBQUEsVUFDWixVQUFVLENBQUMsVUFBVTtBQUFBLFVBQ3JCLGlCQUFpQjtBQUFBLFlBQ2Y7QUFBQSxZQUNBO0FBQUEsWUFDQTtBQUFBLFlBQ0E7QUFBQSxZQUNBO0FBQUEsWUFDQTtBQUFBLFVBQ0Y7QUFBQSxRQUNGO0FBQUEsTUFDRjtBQUFBLElBQ0Y7QUFBQSxFQUNGO0FBQ0YsQ0FBQzsiLAogICJuYW1lcyI6IFtdCn0K
