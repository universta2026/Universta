// Shared page building blocks (server components) - the Universta design system as React.
import { Fragment, type ReactNode } from "react";
import Link from "next/link";
import { ArrowRight, Check, ChevronDown, ChevronRight, Info, Landmark, Globe, Wallet, type LucideIcon } from "lucide-react";
import LeadForm, { type LeadContext } from "./LeadForm";
import Ph from "./Ph";
import { NAV, navHref, TABLE_COUNTRIES } from "./site-config";

export { Ph };

// "Start with what you {love} to learn" -> the word in { } gets the blue highlight block.
export function withHighlight(text: string): ReactNode {
  return text.split(/\{([^{}]+)\}/g).map((part, i) =>
    i % 2 === 1 ? (
      <span key={i} className="hl">
        {part}
      </span>
    ) : (
      part
    ),
  );
}

export const hrefFor = (key: string) => {
  const item = NAV.find((n) => n.key === key);
  return item ? navHref(item) : "#";
};

export function Crumbs({ items }: { items: { label: string; href?: string }[] }) {
  return (
    <nav className="crumbs" aria-label="Breadcrumb">
      {items.map((c, i) => (
        <Fragment key={i}>
          {i > 0 && <ChevronRight className="ico" aria-hidden />}
          {i === items.length - 1 || !c.href ? (
            <span aria-current={i === items.length - 1 ? "page" : undefined}>{c.label}</span>
          ) : (
            <Link href={c.href}>{c.label}</Link>
          )}
        </Fragment>
      ))}
    </nav>
  );
}

export function SecHead({ eyebrow, title, intro }: { eyebrow: string; title: ReactNode; intro?: string }) {
  return (
    <div className="sec-head">
      <div>
        <span className="eyebrow">{eyebrow}</span>
        <h2 className="t-h2">{title}</h2>
        {intro && <p className="muted">{intro}</p>}
      </div>
    </div>
  );
}

export function Section({ id, title, intro, children }: { id: string; title: string; intro?: string | null; children: ReactNode }) {
  return (
    <section id={id} data-section>
      <h2 className="t-h2">{title}</h2>
      {intro && <p className="sec-intro">{intro}</p>}
      <div className="mt-6">{children}</div>
    </section>
  );
}

export type Fact = { icon: LucideIcon; label: string; value: ReactNode };

export function DetailHero({
  crumbs,
  tile,
  title,
  lead,
  actions,
  facts,
}: {
  crumbs: { label: string; href?: string }[];
  tile?: ReactNode;
  title: ReactNode;
  lead?: string | null;
  actions?: ReactNode;
  facts?: Fact[];
}) {
  return (
    <section className="detail-hero">
      <div className="shell">
        <Crumbs items={crumbs} />
        <div className="head">
          {tile}
          <div className="head-main">
            <h1 className="t-h1 mt-0">{title}</h1>
            {lead && <p className="lead">{lead}</p>}
          </div>
          {actions && (
            <div className="actions" style={{ marginTop: 8 }}>
              {actions}
            </div>
          )}
        </div>
        {facts && (
          <div className="facts">
            {facts.map((f) => (
              <div className="fact" key={f.label}>
                <div className="k">
                  <f.icon className="ico" aria-hidden />
                  {f.label}
                </div>
                <div className="v">{f.value}</div>
              </div>
            ))}
          </div>
        )}
      </div>
    </section>
  );
}

export function DetailLayout({ main, aside }: { main: ReactNode; aside: ReactNode }) {
  return (
    <div className="shell">
      <div className="detail">
        <div className="detail-main">{main}</div>
        <aside className="detail-aside">{aside}</aside>
      </div>
    </div>
  );
}

export function Ticks({ items }: { items: ReactNode[] }) {
  return (
    <ul className="ticks">
      {items.map((t, i) => (
        <li key={i}>
          <Check className="ico" aria-hidden />
          <span>{t}</span>
        </li>
      ))}
    </ul>
  );
}

export function Kv({ rows }: { rows: [string, ReactNode][] }) {
  return (
    <dl className="kv">
      {rows.map(([k, v]) => (
        <div key={k}>
          <dt>{k}</dt>
          <dd>{v}</dd>
        </div>
      ))}
    </dl>
  );
}

export function DataTable({ head, rows }: { head: string[]; rows: ReactNode[][] }) {
  return (
    <div className="table-wrap">
      <table className="tbl">
        <thead>
          <tr>
            {head.map((h) => (
              <th key={h}>{h}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((r, i) => (
            <tr key={i}>
              {r.map((c, j) => (
                <td key={j}>{c}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export function Faq({ items }: { items: { q: string; a: ReactNode }[] }) {
  return (
    <div className="faq">
      {items.map((it, i) => (
        <details key={it.q} open={i === 0}>
          <summary>
            {it.q}
            <ChevronDown className="ico" aria-hidden />
          </summary>
          <div className="ans">{it.a}</div>
        </details>
      ))}
    </div>
  );
}

export function Note({ children }: { children: ReactNode }) {
  return (
    <div className="note">
      <Info className="ico" aria-hidden />
      <div>{children}</div>
    </div>
  );
}

export function Source({ children }: { children: ReactNode }) {
  return <p className="source">{children}</p>;
}

// Three headline numbers under "Overview" (values come later, so they are placeholders for now).
export function StatCards() {
  const items: [LucideIcon, string, string][] = [
    [Landmark, "N", "Universities offering it"],
    [Globe, "N", "Countries to choose from"],
    [Wallet, "FEE", "Typical tuition / year"],
  ];
  return (
    <div className="grid g-3 mt-6">
      {items.map(([Icon, v, label]) => (
        <div className="card card-flat" key={label}>
          <span style={{ color: "var(--blue)" }}>
            <Icon className="ico" aria-hidden />
          </span>
          <div className="t-h3 mt-2">
            <Ph>{v}</Ph>
          </div>
          <div className="caption">{label}</div>
        </div>
      ))}
    </div>
  );
}

// "Where to study" / "Costs" table: country names are static, fees are placeholders.
export function CostTable({ lastCol }: { lastCol: "post-study" | "duration"; duration?: string }) {
  const head = ["Country", "Tuition / year", "Living / year", lastCol === "post-study" ? "Post-study work" : "Typical duration"];
  const rows = TABLE_COUNTRIES.map((c) => [
    <strong key="c">{c}</strong>,
    <Ph key="f">FEE</Ph>,
    <Ph key="l">COST</Ph>,
    <Ph key="x">{lastCol === "post-study" ? "YEARS" : "DURATION"}</Ph>,
  ]);
  return (
    <>
      <DataTable head={head} rows={rows} />
      <Source>
        Fees: university websites · last checked <Ph>DATE</Ph>
      </Source>
    </>
  );
}

export function CareersTable() {
  return (
    <>
      <DataTable
        head={["Role", "Typical starting salary", "Demand"]}
        rows={[1, 2, 3].map((n) => [
          <strong key="r">
            <Ph>ROLE</Ph>
          </strong>,
          <Ph key="s">SALARY</Ph>,
          <span key="d" className="tag tag-cloud">
            <Ph>LEVEL</Ph>
          </span>,
        ])}
      />
      <Source>
        Source: <Ph>labour market data</Ph> · last checked <Ph>DATE</Ph>
      </Source>
    </>
  );
}

export function NextStepsBand({ title = "Your next step", items }: { title?: string; items: { icon: LucideIcon; title: string; desc: string; key: string }[] }) {
  return (
    <section className="section-sm bg-cloud">
      <div className="shell">
        <span className="eyebrow">Keep exploring</span>
        <h2 className="t-h3 mt-2" style={{ marginBottom: 24 }}>
          {title}
        </h2>
        <div className="next-steps">
          {items.map((n) => (
            <a className="card" href={hrefFor(n.key)} key={n.key}>
              <span className="ico-tile">
                <n.icon className="ico" aria-hidden />
              </span>
              <span>
                <span className="t">{n.title}</span>
                <span className="d" style={{ display: "block" }}>
                  {n.desc}
                </span>
              </span>
            </a>
          ))}
        </div>
      </div>
    </section>
  );
}

export function CtaBand({ title, text, lead }: { title: ReactNode; text: string; lead?: LeadContext }) {
  return (
    <section className="section bg-ink" id="advice">
      <div className="shell cta-band">
        <div>
          <h2 className="t-h1 mt-4">{title}</h2>
          <p className="lead mt-4">{text}</p>
          <div className="mt-8">
            <Ticks
              items={[
                <>
                  A personal shortlist in <Ph>TIME</Ph>
                </>,
                "For students from any country",
              ]}
            />
          </div>
        </div>
        <LeadForm context={lead} />
      </div>
    </section>
  );
}

export function AsideLead({ about, lead }: { about: string; lead?: LeadContext }) {
  return (
    <div className="aside-cta" id="advice">
      <h3 className="t-h3 mt-2">Talk to an expert about {about} abroad</h3>
      <LeadForm context={lead} cta="Talk to an expert" />
    </div>
  );
}

export function AsideCard({ title, children }: { title: string; children: ReactNode }) {
  return (
    <div className="card">
      <h3 className="t-h4">{title}</h3>
      <div className="mt-4">{children}</div>
    </div>
  );
}

export function AsideLinks({ title, links }: { title: string; links: { label: string; href: string }[] }) {
  return (
    <AsideCard title={title}>
      <ul>
        {links.map((l) => (
          <li key={l.href} style={{ padding: "6px 0" }}>
            <Link className="link-arrow" href={l.href} style={{ fontWeight: 500 }}>
              {l.label}
              <ArrowRight className="ico" aria-hidden />
            </Link>
          </li>
        ))}
      </ul>
    </AsideCard>
  );
}

// Shared FAQ copy used on subject / specialization pages.
export function fieldFaq(name: string): { q: string; a: ReactNode }[] {
  return [
    {
      q: `Do I need a background in ${name} to study it abroad?`,
      a: "For an undergraduate degree, usually not - you need the right school subjects. For a postgraduate degree, most universities expect a related undergraduate degree, but some programmes are designed for career changers.",
    },
    {
      q: `Which country is cheapest for ${name}?`,
      a: "Public universities in Germany charge low or no tuition for most programmes. Compare living costs too - they often matter more than fees.",
    },
    {
      q: "Which English test should I take?",
      a: "IELTS, TOEFL and PTE are widely accepted. Check the exact score each course asks for before you book.",
    },
    {
      q: "Can I work while I study?",
      a: "Most popular destinations allow part-time work during term. Limits differ by country - check each country’s student visa guide.",
    },
  ];
}
