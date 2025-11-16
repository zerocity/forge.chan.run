import { useState, useEffect } from 'react';

interface Item {
  id: number;
  name: string;
  description: string;
}

function App() {
  const [message, setMessage] = useState<string>('');
  const [items, setItems] = useState<Item[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string>('');

  useEffect(() => {
    const fetchData = async () => {
      try {
        const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:3000';

        // Fetch hello message
        const helloRes = await fetch(`${apiUrl}/api/hello`);
        const helloData = await helloRes.json();
        setMessage(helloData.message);

        // Fetch items
        const itemsRes = await fetch(`${apiUrl}/api/data`);
        const itemsData = await itemsRes.json();
        setItems(itemsData.items);

        setLoading(false);
      } catch (err) {
        setError('Failed to fetch data from backend');
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  if (loading) {
    return (
      <div style={styles.container}>
        <h1>Loading...</h1>
      </div>
    );
  }

  if (error) {
    return (
      <div style={styles.container}>
        <h1 style={styles.error}>{error}</h1>
        <p>Make sure the backend is running on port 3000</p>
      </div>
    );
  }

  return (
    <div style={styles.container}>
      <h1 style={styles.title}>Dummy Test Project</h1>
      <p style={styles.subtitle}>React + TypeScript + Vite + Express</p>

      <div style={styles.card}>
        <h2>Backend Message:</h2>
        <p style={styles.message}>{message}</p>
      </div>

      <div style={styles.card}>
        <h2>Data from Backend:</h2>
        <ul style={styles.list}>
          {items.map((item) => (
            <li key={item.id} style={styles.listItem}>
              <strong>{item.name}</strong>: {item.description}
            </li>
          ))}
        </ul>
      </div>

      <div style={styles.footer}>
        <p>
          QA Tools: TypeScript | ESLint | Prettier | Vitest | Playwright
        </p>
      </div>
    </div>
  );
}

const styles = {
  container: {
    maxWidth: '800px',
    margin: '0 auto',
    padding: '2rem',
    fontFamily: 'system-ui, -apple-system, sans-serif',
  },
  title: {
    fontSize: '2.5rem',
    color: '#333',
    marginBottom: '0.5rem',
  },
  subtitle: {
    fontSize: '1.2rem',
    color: '#666',
    marginBottom: '2rem',
  },
  card: {
    backgroundColor: '#f5f5f5',
    borderRadius: '8px',
    padding: '1.5rem',
    marginBottom: '1.5rem',
  },
  message: {
    fontSize: '1.1rem',
    color: '#0066cc',
    fontWeight: 500,
  },
  list: {
    listStyle: 'none',
    padding: 0,
  },
  listItem: {
    padding: '0.75rem',
    backgroundColor: 'white',
    marginBottom: '0.5rem',
    borderRadius: '4px',
    border: '1px solid #e0e0e0',
  },
  error: {
    color: '#cc0000',
  },
  footer: {
    textAlign: 'center' as const,
    color: '#999',
    marginTop: '2rem',
    fontSize: '0.9rem',
  },
};

export default App;
