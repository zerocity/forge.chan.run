import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import App from './App';

describe('App Component', () => {
  it('should render the title', () => {
    render(<App />);
    expect(screen.getByText(/Dummy Test Project/i)).toBeInTheDocument();
  });

  it('should render the subtitle', () => {
    render(<App />);
    expect(
      screen.getByText(/React \+ TypeScript \+ Vite \+ Express/i)
    ).toBeInTheDocument();
  });

  it('should render QA tools footer', () => {
    render(<App />);
    expect(
      screen.getByText(/TypeScript | ESLint | Prettier | Vitest | Playwright/i)
    ).toBeInTheDocument();
  });
});
