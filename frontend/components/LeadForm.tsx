"use client";

import { useEffect, useId, useState, type FormEvent } from "react";
import { Check } from "lucide-react";
import Ph from "./Ph";
import SubjectPicker, { type SubjectGroup } from "./SubjectPicker";
import { DIAL_CODES, detectCountry } from "./phone-codes";
import { FORM_LEVELS, LEAD_DESTINATIONS } from "./site-config";

// What the page knows about the visitor's interest. It pre-selects the Subject and Level fields.
export type LeadContext = {
  subjects: SubjectGroup[]; // every subject with its specializations, for the dropdown
  subject?: string; // the subject page the visitor is on
  specialization?: string; // the specialization page the visitor is on
  level?: string; // the study level page the visitor is on
};

// "Get free advice" form with 6 fields. DESIGN ONLY for now: it is not connected to the backend yet
// (the `enquiries` table exists, but there is no API call for it in lib/api.ts).
// When that endpoint is ready, send the form values inside onSubmit before setDone(true).
export default function LeadForm({ context, cta = "Get free advice" }: { context?: LeadContext; cta?: string }) {
  const uid = useId();
  const [done, setDone] = useState(false);
  const [iso, setIso] = useState("");

  // Pick the country code from the visitor's location (time zone / browser language).
  useEffect(() => {
    setIso(detectCountry() ?? "");
  }, []);

  const subjects = context?.subjects ?? [];
  const spec = context?.specialization;
  const subjectDefault = spec ?? context?.subject ?? "";

  const level = context?.level;
  const levelOptions = [...FORM_LEVELS];
  let levelDefault = "";
  if (level) {
    const lv = level.toLowerCase();
    levelDefault =
      levelOptions.find((o) => o.toLowerCase() === lv) ??
      levelOptions.find((o) => o.toLowerCase().startsWith(lv.split(/[\s/]/)[0])) ??
      "";
    if (!levelDefault) {
      levelOptions.push(level);
      levelDefault = level;
    }
  }

  const onSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setDone(true);
  };

  return (
    <form className={`lead-form${done ? " is-done" : ""}`} data-lead onSubmit={onSubmit}>
      <div className="field">
        <label htmlFor={`${uid}-name`}>Full name</label>
        <input id={`${uid}-name`} className="input" required autoComplete="name" placeholder="Your name" />
      </div>

      <div className="field">
        <label htmlFor={`${uid}-phone`}>Phone number</label>
        <div className="phone-row">
          <select className="select" aria-label="Country code" value={iso} onChange={(e) => setIso(e.target.value)}>
            <option value="">Code</option>
            {DIAL_CODES.map((d) => (
              <option key={d.iso} value={d.iso} title={d.name}>
                {d.iso} +{d.code}
              </option>
            ))}
          </select>
          <input
            id={`${uid}-phone`}
            className="input"
            type="tel"
            inputMode="tel"
            required
            autoComplete="tel-national"
            placeholder="Phone number"
          />
        </div>
      </div>

      <div className="field">
        <label htmlFor={`${uid}-email`}>Email address</label>
        <input id={`${uid}-email`} className="input" type="email" required autoComplete="email" placeholder="you@example.com" />
      </div>

      <div className="field">
        <label htmlFor={`${uid}-dest`}>Desired study destination</label>
        <select id={`${uid}-dest`} className="select" defaultValue="">
          <option value="">Select destination</option>
          <option>Not sure yet</option>
          {LEAD_DESTINATIONS.map((c) => (
            <option key={c}>{c}</option>
          ))}
        </select>
      </div>

      <div className="field">
        <label htmlFor={`${uid}-subject`}>Subject and specialization</label>
        <SubjectPicker id={`${uid}-subject`} groups={subjects} defaultValue={subjectDefault} />
      </div>

      <div className="field">
        <label htmlFor={`${uid}-level`}>Study level</label>
        <select id={`${uid}-level`} name="level" className="select" defaultValue={levelDefault}>
          <option value="">Select study level</option>
          {levelOptions.map((l) => (
            <option key={l} value={l}>
              {l}
            </option>
          ))}
        </select>
      </div>

      <button className="btn btn-primary btn-block" type="submit">
        {cta}
      </button>
      <div className="ok">
        <span className="ico-tile" style={{ background: "#E7F4EF", color: "var(--success)" }}>
          <Check className="ico" aria-hidden />
        </span>
        <h4 className="t-h4 mt-4">Thanks - we’ve got it.</h4>
        <p className="muted small mt-2">
          An adviser will reply within <Ph>TIME</Ph>. No spam, ever.
        </p>
      </div>
    </form>
  );
}
