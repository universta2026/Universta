"use client";

import { useState } from "react";
import { Bookmark } from "lucide-react";

// "Save" toggle in the page hero. Remembers nothing yet (design only).
export default function SaveButton() {
  const [on, setOn] = useState(false);
  return (
    <button
      type="button"
      className={`btn btn-ghost${on ? " is-on" : ""}`}
      aria-pressed={on}
      onClick={() => setOn((v) => !v)}
    >
      <Bookmark className="ico ico-sm" aria-hidden />
      {on ? "Saved" : "Save"}
    </button>
  );
}
