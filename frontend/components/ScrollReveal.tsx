"use client";

import { useEffect } from "react";
import { usePathname } from "next/navigation";

// Cards, FAQ items and section headings fade up as they scroll into view. Purely visual:
// without JavaScript, or with "reduce motion" turned on, nothing is hidden and nothing moves.
const TARGETS = [
  ".detail-main .t-h2",
  ".grid > *",
  ".next-steps > *",
  ".faq > details",
  ".panel",
  ".note",
  ".cta-banner-inner",
  ".tbl",
].join(",");

export default function ScrollReveal() {
  const pathname = usePathname();

  useEffect(() => {
    if (typeof IntersectionObserver === "undefined" || window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;

    const root = document.documentElement;
    root.classList.add("js-reveal");

    const io = new IntersectionObserver(
      (entries) => {
        for (const e of entries) {
          if (!e.isIntersecting) continue;
          e.target.classList.add("is-in");
          io.unobserve(e.target);
        }
      },
      { rootMargin: "0px 0px -8% 0px", threshold: 0.08 },
    );

    const seen = new WeakSet<Element>();
    const scan = () => {
      document.querySelectorAll(TARGETS).forEach((el) => {
        if (seen.has(el) || el.closest("header, footer, dialog")) return;
        seen.add(el);
        // stagger siblings in a row / grid a little
        const i = Array.prototype.indexOf.call(el.parentElement?.children ?? [], el);
        (el as HTMLElement).style.setProperty("--rd", `${Math.min(i, 7) * 70}ms`);
        el.setAttribute("data-reveal", "");
        io.observe(el);
      });
    };
    scan();
    // content that appears later (client components, tabs, lists)
    const mo = new MutationObserver(scan);
    mo.observe(document.body, { childList: true, subtree: true });

    return () => {
      io.disconnect();
      mo.disconnect();
    };
  }, [pathname]);

  return null;
}
