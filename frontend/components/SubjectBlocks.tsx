// Cards for the extra content of the Subject Detail page (rows of subject_sections).
// Uses the existing design system classes only (.card, .tag, .grid, .link-arrow ...).
import Link from "next/link";
import { ArrowRight } from "lucide-react";
import RichText from "@/components/RichText";
import type { SectionItem } from "@/lib/api";
import { safeHref } from "@/lib/url";

function SectionCard({ item, linkLabel }: { item: SectionItem; linkLabel: string }) {
  const href = safeHref(item.url);

  return (
    <div className="card">
      <div className="row between">
        <h3 className="card-title">{item.title}</h3>
        {item.is_sponsored && <span className="tag tag-amber">Sponsored</span>}
      </div>
      {item.subtitle && <p className="muted small mt-2">{item.subtitle}</p>}
      {item.body && (
        <div className="small mt-2">
          <RichText html={item.body} />
        </div>
      )}
      {href && <CardLink href={href} label={linkLabel} sponsored={item.is_sponsored} />}
    </div>
  );
}

function CardLink({ href, label, sponsored }: { href: string; label: string; sponsored: boolean }) {
  const arrow = <ArrowRight className="ico" aria-hidden />;

  if (href.startsWith("/")) {
    return (
      <Link className="link-arrow mt-4" href={href}>
        {label}
        {arrow}
      </Link>
    );
  }
  if (href.startsWith("https://")) {
    return (
      <a
        className="link-arrow mt-4"
        href={href}
        target="_blank"
        rel={sponsored ? "noopener noreferrer sponsored" : "noopener noreferrer"}
      >
        {label}
        {arrow}
      </a>
    );
  }
  // "#anchor", mailto: and tel: open in the same tab
  return (
    <a className="link-arrow mt-4" href={href}>
      {label}
      {arrow}
    </a>
  );
}

export function SectionCards({ items, linkLabel = "Visit website" }: { items: SectionItem[]; linkLabel?: string }) {
  return (
    <div className="grid g-2">
      {items.map((item) => (
        <SectionCard key={item.id} item={item} linkLabel={linkLabel} />
      ))}
    </div>
  );
}

// Advertisement slot of a level page (section = "advertisement"). Always labelled, links are rel="sponsored".
export function AdBlock({ item }: { item: SectionItem }) {
  const href = safeHref(item.url);
  return (
    <aside className="card" aria-label="Advertisement">
      <span className="tag tag-amber">Advertisement</span>
      <h3 className="card-title mt-4">{item.title}</h3>
      {item.subtitle && <p className="muted small mt-2">{item.subtitle}</p>}
      {item.body && (
        <div className="small mt-2">
          <RichText html={item.body} />
        </div>
      )}
      {href && <CardLink href={href} label="Learn more" sponsored />}
    </aside>
  );
}

// Call-to-action block of a level page (section = "cta"). The subtitle is the button text;
// without a link the button scrolls to the enquiry form.
export function CtaBlock({ item }: { item: SectionItem }) {
  const href = safeHref(item.url) ?? "#advice";
  const external = href.startsWith("https://");
  return (
    <div className="card">
      <h3 className="card-title">{item.title}</h3>
      {item.body && (
        <div className="small mt-2">
          <RichText html={item.body} />
        </div>
      )}
      <a
        className="btn btn-dark mt-4"
        href={href}
        {...(external ? { target: "_blank", rel: "noopener noreferrer" } : {})}
      >
        {item.subtitle || "Talk to an expert"}
      </a>
    </div>
  );
}
