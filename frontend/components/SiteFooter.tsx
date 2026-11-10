import Image from "next/image";
import SubscribeForm from "./SubscribeForm";
import { FOOTER_COLUMNS } from "./site-config";

export default function SiteFooter() {
  return (
    <footer className="site-footer">
      <div className="shell">
        <div className="top">
          <div>
            <Image src="/universta-logo-reverse.png" alt="Universta" width={168} height={26} />
            <p className="mt-4" style={{ font: "600 17px/24px var(--font-head)", color: "#fff" }}>
              Your world of universities.
            </p>
            <p className="mt-6 small">Get the monthly study abroad digest</p>
            <SubscribeForm />
          </div>
          {FOOTER_COLUMNS.map((col) => (
            <div key={col.title}>
              <h4>{col.title}</h4>
              <ul>
                {col.links.map((l) => (
                  <li key={l.label}>
                    <a href={l.href}>{l.label}</a>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
        <div className="bottom">
          <span>© 2026 Universta. All rights reserved.</span>
          <span className="row" style={{ gap: 20 }}>
            <a href="#">Privacy</a>
            <a href="#">Terms</a>
            <a href="#">Cookies</a>
          </span>
        </div>
      </div>
    </footer>
  );
}
