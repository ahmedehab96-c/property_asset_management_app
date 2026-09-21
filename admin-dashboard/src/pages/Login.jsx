import { useState } from 'react';
import { BuildingOffice2Icon } from '@heroicons/react/24/outline';
import { useAuth } from '../context/AuthContext';
import { useLocale } from '../context/LocaleContext';
import LocaleSwitcher from '../components/layout/LocaleSwitcher';

export default function Login() {
  const { login } = useAuth();
  const { t } = useLocale();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setError('');
    setSubmitting(true);
    try {
      await login(email, password);
    } catch (err) {
      setError(err.message || t.loadError);
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <div className="login-page">
      <div style={{ position: 'absolute', top: '1.25rem', insetInlineEnd: '1.25rem' }}>
        <LocaleSwitcher />
      </div>
      <form className="panel login-card" onSubmit={handleSubmit}>
        <div className="login-brand">
          <BuildingOffice2Icon />
          <span>{t.brand}</span>
        </div>
        {error && <div className="form-error">{error}</div>}
        <div className="form-field">
          <label htmlFor="email">{t.login.email}</label>
          <input
            id="email"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            autoComplete="email"
          />
        </div>
        <div className="form-field">
          <label htmlFor="password">{t.login.password}</label>
          <input
            id="password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            autoComplete="current-password"
          />
        </div>
        <button type="submit" className="btn-primary" disabled={submitting}>
          {submitting ? t.login.submitting : t.login.submit}
        </button>
      </form>
    </div>
  );
}
