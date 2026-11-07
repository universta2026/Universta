"use client";

import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useRef, useState, type MouseEvent, type ReactNode } from "react";
import { ChevronDown, Menu, X } from "lucide-react";
import { NAV, navHref, type NavItem } from "./site-config";

const noop = (e: MouseEvent) => e.preventDefault();

// Sections without pages yet render as "#" links (see `live` in site-config.ts).
function NavLink({ item, className, children, onClick }: { item: NavItem; className?: string; children: ReactNode; onClick?: () => void }) {
  if (item.live) {
    return (
      <Link href={navHref(item)} className={className} onClick={onClick}>
        {children}
      </Link>
    );
  }
  return (
    <a href="#" className={className} title="Coming soon" onClick={noop}>
      {children}
    </a>
  );
}

function scrollToAdvice(e: MouseEvent) {
  const target = document.getElementById("advice") ?? document.querySelector("[data-lead]");
  if (!target) return;
  e.preventDefault();
  target.scrollIntoView({ behavior: "smooth", block: "center" });
  const input = target.querySelector("input");
  if (input) setTimeout(() => input.focus({ preventScroll: true }), 400);
}

export default function SiteHeader() {
  const pathname = usePathname();
  const [moreOpen, setMoreOpen] = useState(false);
  const [drawerOpen, setDrawerOpen] = useState(false);
  const moreRef = useRef<HTMLDivElement>(null);

  const active =
    pathname.startsWith("/specializations") || pathname.startsWith("/subjects")
      ? "subjects"
      : NAV.find((n) => n.live && pathname.startsWith(n.href))?.key;

  const main = NAV.slice(0, 7);
  const more = NAV.slice(7);

  useEffect(() => {
    const onDown = (e: Event) => {
      if (moreRef.current && !moreRef.current.contains(e.target as Node)) setMoreOpen(false);
    };
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        setMoreOpen(false);
        setDrawerOpen(false);
      }
    };
    document.addEventListener("click", onDown);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("click", onDown);
      document.removeEventListener("keydown", onKey);
    };
  }, []);

  return (
    <>
      <header className="site-header">
        <div className="shell">
          <Link className="brand" href="/" aria-label="Universta home">
            <Image src="/universta-logo.png" alt="Universta" width={152} height={24} priority />
          </Link>

          <nav className="nav" aria-label="Main">
            {main.map((s) => (
              <NavLink
                key={s.key}
                item={s}
                className={active === s.key ? "is-active" : undefined}
              >
                {s.name}
              </NavLink>
            ))}
            <div className={`nav-more${moreOpen ? " is-open" : ""}`} ref={moreRef}>
              <button type="button" aria-haspopup="true" aria-expanded={moreOpen} onClick={() => setMoreOpen((o) => !o)}>
                More <ChevronDown className="ico ico-sm" aria-hidden />
              </button>
              <div className="menu">
                {more.map((s) => (
                  <NavLink key={s.key} item={s}>
                    <span className="ico-tile" style={{ width: 36, height: 36, borderRadius: 8 }}>
                      <s.icon className="ico ico-sm" aria-hidden />
                    </span>
                    <span>
                      {s.long}
                      <small>{s.desc}</small>
                    </span>
                  </NavLink>
                ))}
              </div>
            </div>
          </nav>

          <div className="header-actions">
            <a className="btn btn-ghost btn-sm hide-sm" href="#" onClick={noop}>
              Sign in
            </a>
            <a className="btn btn-primary btn-sm" href="#advice" onClick={scrollToAdvice}>
              Get free advice
            </a>
            <button className="icon-btn menu-btn" type="button" aria-label="Open menu" onClick={() => setDrawerOpen(true)}>
              <Menu className="ico" aria-hidden />
            </button>
          </div>
        </div>
      </header>

      <div className={`drawer${drawerOpen ? " is-open" : ""}`}>
        <div className="drawer-scrim" onClick={() => setDrawerOpen(false)} />
        <div className="drawer-panel">
          <div className="row between">
            <Image src="/universta-logo.png" alt="Universta" width={132} height={21} />
            <button className="icon-btn" type="button" aria-label="Close menu" onClick={() => setDrawerOpen(false)}>
              <X className="ico" aria-hidden />
            </button>
          </div>
          <div className="mt-6">
            {NAV.map((s) => (
              <NavLink key={s.key} item={s} className="dl" onClick={() => setDrawerOpen(false)}>
                <span className="ico-tile" style={{ width: 36, height: 36, borderRadius: 8 }}>
                  <s.icon className="ico ico-sm" aria-hidden />
                </span>
                {s.long}
              </NavLink>
            ))}
          </div>
          <a className="btn btn-ghost btn-block mt-6" href="#" onClick={noop}>
            Sign in
          </a>
        </div>
      </div>
    </>
  );
}
