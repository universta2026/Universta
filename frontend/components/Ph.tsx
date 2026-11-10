// A bracketed placeholder for a value the API does not return yet, e.g. <Ph>FEE</Ph> -> [FEE].
// Replace these with real data once the matching field exists in the backend / Directus.
export default function Ph({ children }: { children: React.ReactNode }) {
  return <span className="ph">[{children}]</span>;
}
