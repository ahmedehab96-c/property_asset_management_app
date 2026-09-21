import { useState } from 'react';
import Sidebar from './Sidebar';
import Topbar from './Topbar';

export default function DashboardLayout({ heading, children }) {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="app-shell">
      <Sidebar open={sidebarOpen} onClose={() => setSidebarOpen(false)} />
      <div className="main-column">
        <Topbar heading={heading} onMenuClick={() => setSidebarOpen(true)} />
        <main className="main-content">{children}</main>
      </div>
    </div>
  );
}
