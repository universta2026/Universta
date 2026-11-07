import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Universta",
  description: "Find the field that fits you",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="bg-white text-slate-900 antialiased">{children}</body>
    </html>
  );
}
