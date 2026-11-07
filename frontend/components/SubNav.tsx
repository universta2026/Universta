"use client";

import { useEffect, useRef, useState } from "react";

// Sticky in-page tabs. Highlights the section that is currently in view.
export default function SubNav({ items }: { items: { id: string; label: string }[] }) {
  const [current, setCurrent] = useState(items[0]?.id);
  const strip = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const spy = new IntersectionObserver(
      (entries) => {
        entries.forEach((e) => {
          if (e.isIntersecting) setCurrent(e.target.id);
        });
      },
      { rootMargin: "-140px 0px -65% 0px" },
    );
    document.querySelectorAll("[data-section]").forEach((s) => spy.observe(s));
    return () => spy.disconnect();
  }, []);

  // Keep the active tab visible on small screens (scrolls the strip only, not the page).
  useEffect(() => {
    const el = strip.current;
    const a = el?.querySelector<HTMLAnchorElement>(`a[data-anchor="${current}"]`);
    if (el && a && el.scrollWidth > el.clientWidth) {
      el.scrollTo({ left: a.offsetLeft - (el.clientWidth - a.offsetWidth) / 2, behavior: "smooth" });
    }
  }, [current]);

  return (
    <nav className="subnav" aria-label="On this page">
      <div className="shell" ref={strip}>
        {items.map((i) => (
          <a
            key={i.id}
            href={`#${i.id}`}
            data-anchor={i.id}
            className={i.id === current ? "is-active" : undefined}
          >
            {i.label}
          </a>
        ))}
      </div>
    </nav>
  );
}
