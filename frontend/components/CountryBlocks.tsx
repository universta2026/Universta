import type { ReactNode } from "react";
import {
  ArrowRight,
  Award,
  BookOpen,
  CalendarDays,
  CircleHelp,
  ClipboardList,
  FileCheck,
  Globe,
  GraduationCap,
  Landmark,
  Megaphone,
  Plane,
  ShieldCheck,
  Sparkles,
  Wallet,
  type LucideIcon,
} from "lucide-react";

// Building blocks for the study-abroad country page: a section with an icon header,
// a call-to-action strip and an advertisement slot. They live inside a <Band> (see ui.tsx).

const ICONS: Record<string, LucideIcon> = {
  why: Sparkles,
  subjects: BookOpen,
  courses: GraduationCap,
  universities: Landmark,
  exams: FileCheck,
  scholarships: Award,
  visa: Plane,
  applications: ClipboardList,
  intakes: CalendarDays,
  costs: Wallet,
  eligibility: ShieldCheck,
  nearby: Globe,
  faq: CircleHelp,
};

export function sectionIcon(id: string): LucideIcon {
  return ICONS[id] ?? Sparkles;
}

// Section with a coloured icon tile, a small label above the title and a big faded number (the number comes from CSS).
export function BandSection({
  id,
  title,
  intro,
  children,
}: {
  id: string;
  title: string;
  intro?: string | null;
  children: ReactNode;
}) {
  const Icon = sectionIcon(id);
  return (
    <section id={id} data-section className="band-section">
      <div className="band-head">
        <span className="band-ico">
          <Icon className="ico" aria-hidden />
        </span>
        <div>
          <h2 className="t-h2">{title}</h2>
          {intro && <p className="sec-intro">{intro}</p>}
        </div>
      </div>
      <div className="band-body">{children}</div>
    </section>
  );
}

// Blue call-to-action strip. Both buttons open the enquiry pop-up (links to #advice).
export function CtaStrip({ title, text, primary, secondary }: { title: string; text: string; primary: string; secondary?: string }) {
  return (
    <div className="cta-strip">
      <span className="cta-strip-ico" aria-hidden>
        <Megaphone className="ico" />
      </span>
      <div className="cta-strip-copy">
        <h3>{title}</h3>
        <p>{text}</p>
      </div>
      <div className="cta-strip-actions">
        <a className="btn btn-white" href="#advice">
          {primary}
          <ArrowRight className="ico" aria-hidden />
        </a>
        {secondary && (
          <a className="btn cta-strip-ghost" href="#advice">
            {secondary}
          </a>
        )}
      </div>
    </div>
  );
}

// Advertisement slot. Pass `ad` to show a real advertiser (always labelled, link is rel="sponsored").
// Without it a neutral "ad space" placeholder is shown, so the layout is ready for when ads are sold.
export type AdContent = { title: string; text?: string; href?: string; cta?: string };

export function AdSlot({ ad, size = "banner" }: { ad?: AdContent; size?: "banner" | "wide" }) {
  return (
    <aside className={`ad-slot ad-${size}`} aria-label="Advertisement">
      <span className="ad-label">Advertisement</span>
      {ad ? (
        <div className="ad-body">
          <div>
            <strong>{ad.title}</strong>
            {ad.text && <p>{ad.text}</p>}
          </div>
          {ad.href && (
            <a className="btn btn-primary btn-sm" href={ad.href} target="_blank" rel="noopener noreferrer sponsored">
              {ad.cta ?? "Learn more"}
            </a>
          )}
        </div>
      ) : (
        <div className="ad-empty">
          <Megaphone className="ico" aria-hidden />
          <span>Ad space</span>
          <small>{size === "wide" ? "970 x 250" : "728 x 90"}</small>
        </div>
      )}
    </aside>
  );
}
