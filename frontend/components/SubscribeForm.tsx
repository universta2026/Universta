"use client";

// Footer newsletter box. DESIGN ONLY: not connected to anything yet.
export default function SubscribeForm() {
  return (
    <form className="sub" onSubmit={(e) => e.preventDefault()}>
      <input className="input" type="email" placeholder="Your email" aria-label="Email address" required />
      <button className="btn btn-white" type="submit">
        Subscribe
      </button>
    </form>
  );
}
