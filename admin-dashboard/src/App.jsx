import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import { LocaleProvider, useLocale } from './context/LocaleContext';
import { resources } from './config/resources';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Analytics from './pages/Analytics';
import ResourceListPage from './pages/resources/ResourceListPage';
import ResourceFormPage from './pages/resources/ResourceFormPage';

function AuthenticatedRoutes() {
  return (
    <Routes>
      <Route path="/" element={<Dashboard />} />
      <Route path="/analytics" element={<Analytics />} />
      {Object.values(resources).map((resource) => (
        <Route key={resource.key} path={`/${resource.key}`}>
          <Route index element={<ResourceListPage resource={resource} />} />
          <Route path="create" element={<ResourceFormPage resource={resource} />} />
          <Route path=":id/edit" element={<ResourceFormPage resource={resource} />} />
        </Route>
      ))}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

function Root() {
  const { status } = useAuth();
  const { t } = useLocale();

  if (status === 'checking') {
    return <div className="state-message">{t.loading}</div>;
  }

  return status === 'authenticated' ? <AuthenticatedRoutes /> : <Login />;
}

const basename = import.meta.env.BASE_URL.replace(/\/$/, '');

export default function App() {
  return (
    <BrowserRouter basename={basename}>
      <LocaleProvider>
        <AuthProvider>
          <Root />
        </AuthProvider>
      </LocaleProvider>
    </BrowserRouter>
  );
}
