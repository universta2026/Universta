// Country dial codes for the phone field, and a best-guess of the visitor's country.
export type Dial = { iso: string; name: string; code: string };

export const DIAL_CODES: Dial[] = [
  { iso: "AU", name: "Australia", code: "61" },
  { iso: "BH", name: "Bahrain", code: "973" },
  { iso: "BD", name: "Bangladesh", code: "880" },
  { iso: "BR", name: "Brazil", code: "55" },
  { iso: "CA", name: "Canada", code: "1" },
  { iso: "CN", name: "China", code: "86" },
  { iso: "EG", name: "Egypt", code: "20" },
  { iso: "FR", name: "France", code: "33" },
  { iso: "DE", name: "Germany", code: "49" },
  { iso: "GH", name: "Ghana", code: "233" },
  { iso: "HK", name: "Hong Kong", code: "852" },
  { iso: "IN", name: "India", code: "91" },
  { iso: "ID", name: "Indonesia", code: "62" },
  { iso: "IR", name: "Iran", code: "98" },
  { iso: "IE", name: "Ireland", code: "353" },
  { iso: "IT", name: "Italy", code: "39" },
  { iso: "JP", name: "Japan", code: "81" },
  { iso: "KZ", name: "Kazakhstan", code: "7" },
  { iso: "KE", name: "Kenya", code: "254" },
  { iso: "KW", name: "Kuwait", code: "965" },
  { iso: "MY", name: "Malaysia", code: "60" },
  { iso: "MX", name: "Mexico", code: "52" },
  { iso: "NP", name: "Nepal", code: "977" },
  { iso: "NL", name: "Netherlands", code: "31" },
  { iso: "NZ", name: "New Zealand", code: "64" },
  { iso: "NG", name: "Nigeria", code: "234" },
  { iso: "OM", name: "Oman", code: "968" },
  { iso: "PK", name: "Pakistan", code: "92" },
  { iso: "PH", name: "Philippines", code: "63" },
  { iso: "QA", name: "Qatar", code: "974" },
  { iso: "RU", name: "Russia", code: "7" },
  { iso: "SA", name: "Saudi Arabia", code: "966" },
  { iso: "SG", name: "Singapore", code: "65" },
  { iso: "ZA", name: "South Africa", code: "27" },
  { iso: "KR", name: "South Korea", code: "82" },
  { iso: "ES", name: "Spain", code: "34" },
  { iso: "LK", name: "Sri Lanka", code: "94" },
  { iso: "SE", name: "Sweden", code: "46" },
  { iso: "CH", name: "Switzerland", code: "41" },
  { iso: "TH", name: "Thailand", code: "66" },
  { iso: "TR", name: "Turkey", code: "90" },
  { iso: "AE", name: "United Arab Emirates", code: "971" },
  { iso: "GB", name: "United Kingdom", code: "44" },
  { iso: "US", name: "United States", code: "1" },
  { iso: "UZ", name: "Uzbekistan", code: "998" },
  { iso: "VN", name: "Vietnam", code: "84" },
];

// The visitor's time zone is the best location hint available in the browser without asking for
// permission or calling a third-party service. The browser language region is the fallback.
const TIMEZONES: Record<string, string> = {
  "Asia/Kolkata": "IN", "Asia/Calcutta": "IN", "Asia/Karachi": "PK", "Asia/Dhaka": "BD",
  "Asia/Kathmandu": "NP", "Asia/Katmandu": "NP", "Asia/Colombo": "LK", "Asia/Dubai": "AE",
  "Asia/Riyadh": "SA", "Asia/Qatar": "QA", "Asia/Kuwait": "KW", "Asia/Muscat": "OM",
  "Asia/Bahrain": "BH", "Asia/Singapore": "SG", "Asia/Kuala_Lumpur": "MY", "Asia/Jakarta": "ID",
  "Asia/Manila": "PH", "Asia/Ho_Chi_Minh": "VN", "Asia/Saigon": "VN", "Asia/Bangkok": "TH",
  "Asia/Shanghai": "CN", "Asia/Hong_Kong": "HK", "Asia/Tokyo": "JP", "Asia/Seoul": "KR",
  "Asia/Tashkent": "UZ", "Asia/Almaty": "KZ", "Asia/Tehran": "IR", "Europe/Istanbul": "TR",
  "Africa/Cairo": "EG", "Africa/Lagos": "NG", "Africa/Accra": "GH", "Africa/Nairobi": "KE",
  "Africa/Johannesburg": "ZA", "Europe/London": "GB", "Europe/Dublin": "IE", "Europe/Berlin": "DE",
  "Europe/Paris": "FR", "Europe/Amsterdam": "NL", "Europe/Rome": "IT", "Europe/Madrid": "ES",
  "Europe/Stockholm": "SE", "Europe/Zurich": "CH", "Europe/Moscow": "RU", "Pacific/Auckland": "NZ",
  "America/New_York": "US", "America/Chicago": "US", "America/Denver": "US", "America/Los_Angeles": "US",
  "America/Phoenix": "US", "America/Anchorage": "US", "America/Detroit": "US",
  "America/Toronto": "CA", "America/Vancouver": "CA", "America/Edmonton": "CA", "America/Winnipeg": "CA",
  "America/Halifax": "CA", "America/Regina": "CA", "America/St_Johns": "CA",
  "America/Sao_Paulo": "BR", "America/Mexico_City": "MX",
};

export function detectCountry(): string | undefined {
  const known = (iso: string | undefined) => (iso && DIAL_CODES.some((d) => d.iso === iso) ? iso : undefined);
  try {
    const tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
    const fromTz = tz?.startsWith("Australia/") ? "AU" : TIMEZONES[tz];
    if (known(fromTz)) return fromTz;
    const langs = navigator.languages?.length ? navigator.languages : [navigator.language];
    for (const l of langs) {
      const m = l.match(/-([A-Za-z]{2})\b/);
      if (m && known(m[1].toUpperCase())) return m[1].toUpperCase();
    }
  } catch {
    // no location hint available: the visitor picks the code
  }
  return undefined;
}
