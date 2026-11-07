"use client";

import { useId, useState, type FormEvent } from "react";
import { Check } from "lucide-react";
import Ph from "./Ph";
import { LEAD_DESTINATIONS, LEAD_INTAKES } from "./site-config";

// "Get free advice" form. DESIGN ONLY for now: it is not connected to the backend yet
// (the `enquiries` table exists, but there is no API call for it in lib/api.ts).
// When that endpoint is ready, send the form values inside onSubmit before setDone(true).
export default function LeadForm({
  compact = false,
  cta = "Get free advice",
}: {
  compact?: boolean;
  cta?: string;
}) {
  const uid = useId();
  const [done, setDone] = useState(false);

  const onSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setDone(true);
  };

  return (
    <form className={`lead-form${done ? " is-done" : ""}`} data-lead onSubmit={onSubmit}>
      <div className="field">
        <label htmlFor={`${uid}-name`}>Full name</label>
        <input id={`${uid}-name`} className="input" required placeholder="Your name" />
      </div>
      <div className="field">
        <label htmlFor={`${uid}-contact`}>Email or phone</label>
        <input id={`${uid}-contact`} className="input" required placeholder="So we can reply" />
      </div>
      {!compact && (
        <div className="grid g-2 gap-16">
          <div className="field">
            <label htmlFor={`${uid}-dest`}>Destination</label>
            <select id={`${uid}-dest`} className="select" defaultValue="Not sure yet">
              <option>Not sure yet</option>
              {LEAD_DESTINATIONS.map((c) => (
                <option key={c}>{c}</option>
              ))}
            </select>
          </div>
          <div className="field">
            <label htmlFor={`${uid}-intake`}>Planned intake</label>
            <select id={`${uid}-intake`} className="select" defaultValue="Choose intake">
              <option>Choose intake</option>
              {LEAD_INTAKES.map((i) => (
                <option key={i}>{i}</option>
              ))}
            </select>
          </div>
        </div>
      )}
      <button className="btn btn-primary btn-block" type="submit">
        {cta}
      </button>
      <p className="caption">Free, no pressure. We’ll only contact you about your study plans.</p>
      <div className="ok">
        <span className="ico-tile" style={{ background: "#E7F4EF", color: "var(--success)" }}>
          <Check className="ico" aria-hidden />
        </span>
        <h4 className="t-h4 mt-4">Thanks — we’ve got it.</h4>
        <p className="muted small mt-2">
          An adviser will reply within <Ph>TIME</Ph>. No spam, ever.
        </p>
      </div>
    </form>
  );
}
