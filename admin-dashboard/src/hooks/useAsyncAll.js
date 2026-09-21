import { useEffect, useState } from 'react';

/** Runs a set of fetcher functions in parallel and exposes their combined result. */
export function useAsyncAll(fetchers) {
  const [data, setData] = useState(null);
  const [error, setError] = useState('');

  useEffect(() => {
    let cancelled = false;
    setData(null);
    setError('');

    Promise.all(fetchers.map((fetcher) => fetcher()))
      .then((results) => {
        if (!cancelled) setData(results);
      })
      .catch((err) => {
        if (!cancelled) setError(err.message);
      });

    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return { data, error };
}
