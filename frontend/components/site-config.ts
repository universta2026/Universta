import {
  Award,
  BookOpen,
  FileCheck,
  Globe,
  GraduationCap,
  Landmark,
  MessageCircle,
  Plane,
  Presentation,
  type LucideIcon,
} from "lucide-react";

// ---------------------------------------------------------------------------
// Site navigation. Only `subjects` has pages in this app so far.
// When another section is built, set `live: true` and its link starts working
// in the header, the mobile menu and the footer.
// ---------------------------------------------------------------------------
export type NavItem = {
  key: string;
  name: string; // short label in the header bar
  long: string; // label in the "More" menu and mobile menu
  href: string;
  icon: LucideIcon;
  desc: string;
  live: boolean;
};

export const NAV: NavItem[] = [
  { key: "subjects", name: "Subjects", long: "Subjects & specializations", href: "/subjects", icon: BookOpen, desc: "Find the field that fits you — from AI and nursing to architecture.", live: true },
  { key: "destinations", name: "Destinations", long: "Study destinations", href: "/destinations", icon: Globe, desc: "Compare countries by cost, intakes, work rights and lifestyle.", live: false },
  { key: "universities", name: "Universities", long: "Universities", href: "/universities", icon: Landmark, desc: "Profiles, fees, entry requirements and student life.", live: false },
  { key: "courses", name: "Courses", long: "Courses", href: "/courses", icon: GraduationCap, desc: "Search programmes by level, intake, duration and budget.", live: false },
  { key: "scholarships", name: "Scholarships", long: "Scholarships", href: "/scholarships", icon: Award, desc: "Government, university and private funding — with real deadlines.", live: false },
  { key: "exams", name: "Exams", long: "Exams", href: "/exams", icon: FileCheck, desc: "IELTS, TOEFL, PTE, GRE, GMAT and SAT — formats, fees and scores.", live: false },
  { key: "student-visa", name: "Visa", long: "Student visa", href: "/student-visa", icon: Plane, desc: "Step-by-step visa guides, document checklists and timelines.", live: false },
  { key: "coaching", name: "Coaching", long: "Coaching", href: "/coaching", icon: Presentation, desc: "Test-prep centres near you or online, with real student reviews.", live: false },
  { key: "consultants", name: "Consultants", long: "Study abroad consultants", href: "/consultants", icon: MessageCircle, desc: "Verified advisers for shortlisting, applications and visas.", live: false },
];

export const navHref = (item: NavItem) => (item.live ? item.href : "#");

const byKey = (key: string) => NAV.find((n) => n.key === key)!;

export const FOOTER_COLUMNS: { title: string; links: { label: string; href: string }[] }[] = [
  {
    title: "Explore",
    links: ["subjects", "destinations", "universities", "courses", "scholarships"].map((k) => ({
      label: byKey(k).name,
      href: navHref(byKey(k)),
    })),
  },
  {
    title: "Prepare",
    links: [
      { label: "Exams", href: navHref(byKey("exams")) },
      { label: "Coaching", href: navHref(byKey("coaching")) },
      { label: "Student visa", href: navHref(byKey("student-visa")) },
      { label: "Consultants", href: navHref(byKey("consultants")) },
    ],
  },
  {
    title: "Partners",
    links: ["For universities", "For consultants", "For coaching centres", "List your institution"].map((label) => ({ label, href: "#" })),
  },
  {
    title: "Company",
    links: ["About us", "Contact", "Careers", "Press"].map((label) => ({ label, href: "#" })),
  },
];


// ---------------------------------------------------------------------------
// Static design content (not in the API yet — move to Directus when ready)
// ---------------------------------------------------------------------------

// "Not sure which level fits?" explainer on the Subjects page.
export const LEVEL_GUIDE = [
  { name: "Foundation", duration: "1 year", blurb: "Students who need an extra year to meet entry requirements for a bachelor’s degree." },
  { name: "Diploma & certificate", duration: "1–2 years", blurb: "Practical, career-focused study — often a pathway into the second year of a degree." },
  { name: "Bachelor’s degree", duration: "3–4 years", blurb: "Your first university degree, after finishing secondary school." },
  { name: "Master’s degree", duration: "1–2 years", blurb: "Specialist or career-change study after a bachelor’s degree." },
  { name: "PhD / Doctorate", duration: "3–5 years", blurb: "Original research under a supervisor, usually after a master’s degree." },
];

// Options in the hero search "level" select and the lead forms.
export const LEVEL_OPTIONS = ["Any level", "Foundation year", "Diploma & certificate", "Bachelor’s degree", "Master’s degree", "PhD / Doctorate"];
export const LEAD_DESTINATIONS = ["Australia", "Canada", "France", "Germany", "Ireland", "Japan", "Netherlands", "New Zealand", "United Kingdom", "United States"];
export const LEAD_INTAKES = ["Jan 2027", "Sep 2027", "Jan 2028", "Later"];
// Country rows in the "Where to study" / "Costs" tables (fees are placeholders until the data exists).
export const TABLE_COUNTRIES = ["United Kingdom", "United States", "Canada", "Australia", "Germany", "Ireland"];
