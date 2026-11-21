"use client";

import { useCallback, useEffect, useRef } from "react";
import { ArrowRight, Check, X } from "lucide-react";
import LeadForm, { type LeadContext } from "./LeadForm";

// Call-to-action banner above the footer. The button (and every link to "#advice" on the page,
// such as the header's "Get free advice") opens the enquiry form as a pop-up.
export default function LeadBanner({ about, lead }: { about: string; lead?: LeadContext }) {
  const ref = useRef<HTMLDialogElement>(null);

  const open = useCallback(() => {
    const d = ref.current;
    if (!d || d.open) return;
    d.showModal();
    document.documentElement.classList.add("modal-open");
    setTimeout(() => d.querySelector<HTMLInputElement>("input")?.focus({ preventScroll: true }), 60);
  }, []);

  const close = useCallback(() => {
    ref.current?.close();
  }, []);

  useEffect(() => {
    const d = ref.current;
    const onClose = () => document.documentElement.classList.remove("modal-open");
    d?.addEventListener("close", onClose);

    // Any link to #advice opens the pop-up instead of scrolling (capture phase: runs before the header's own handler).
    const onClick = (e: MouseEvent) => {
      const a = (e.target as Element | null)?.closest?.('a[href="#advice"]');
      if (!a) return;
      e.preventDefault();
      e.stopPropagation();
      open();
    };
    document.addEventListener("click", onClick, true);
    if (window.location.hash === "#advice") open();

    return () => {
      d?.removeEventListener("close", onClose);
      document.removeEventListener("click", onClick, true);
      document.documentElement.classList.remove("modal-open");
    };
  }, [open]);

  return (
    <>
      <section className="cta-banner" aria-labelledby="cta-banner-title">
        <span className="cta-orb cta-orb-a" aria-hidden />
        <span className="cta-orb cta-orb-b" aria-hidden />
        <div className="shell cta-banner-inner">
          <div className="cta-banner-copy">
            <span className="cta-pill">Free expert advice</span>
            <h2 id="cta-banner-title" className="t-h2 mt-4">
              Not sure about {about} abroad? Talk to an expert.
            </h2>
            <p className="mt-3">Get a personal shortlist of universities, costs and intakes, matched to your goals. No spam, ever.</p>
            <ul className="cta-points">
              {["Personal shortlist", "For students from any country", "100% free"].map((t) => (
                <li key={t}>
                  <Check className="ico" aria-hidden /> {t}
                </li>
              ))}
            </ul>
          </div>
          <div className="cta-banner-action">
            <button type="button" className="btn btn-white btn-lg cta-banner-btn" onClick={open}>
              Talk to an expert <ArrowRight className="ico" aria-hidden />
            </button>
            <span className="cta-banner-note">Takes less than a minute</span>
          </div>
        </div>
      </section>

      <dialog
        ref={ref}
        className="lead-modal"
        aria-labelledby="lead-modal-title"
        onClick={(e) => {
          if (e.target === ref.current) close(); // click on the dark backdrop
        }}
      >
        <div className="lead-modal-card">
          <button type="button" className="lead-modal-x" aria-label="Close" onClick={close}>
            <X className="ico" aria-hidden />
          </button>
          <span className="eyebrow">Free advice</span>
          <h3 id="lead-modal-title" className="t-h3 mt-2">
            Talk to an expert about {about} abroad
          </h3>
          <p className="muted small mt-2">Tell us a little about you and an adviser will get back to you.</p>
          <LeadForm context={lead} cta="Talk to an expert" />
        </div>
      </dialog>
    </>
  );
}
