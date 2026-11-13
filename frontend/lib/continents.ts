// Groups countries by continent using the ISO country_code already stored in the countries table.
// TEMPORARY: the countries table has no continent column yet. When one is added, delete this
// lookup and group by that column instead (only groupByContinent below needs to change).

const CONTINENT_CODES: Record<string, string> = {};
const add = (continent: string, codes: string) => codes.split(" ").forEach((c) => (CONTINENT_CODES[c] = continent));

add("Africa", "DZ AO BJ BW BF BI CV CM CF TD KM CG CD CI DJ EG GQ ER SZ ET GA GM GH GN GW KE LS LR LY MG MW ML MR MU MA MZ NA NE NG RW ST SN SC SL SO ZA SS SD TZ TG TN UG ZM ZW");
add("Asia", "AF AM AZ BH BD BT BN KH CN GE IN ID IR IQ IL JP JO KZ KW KG LA LB MY MV MN MM NP KP OM PK PS PH QA SA SG KR LK SY TW TJ TH TL TR TM AE UZ VN YE");
add("Europe", "AL AD AT BY BE BA BG HR CY CZ DK EE FI FR DE GR HU IS IE IT XK LV LI LT LU MT MD MC ME NL MK NO PL PT RO RU SM RS SK SI ES SE CH UA GB VA");
add("North America", "AG BS BB BZ CA CR CU DM DO SV GD GT HT HN JM MX NI PA KN LC VC TT US");
add("South America", "AR BO BR CL CO EC GY PY PE SR UY VE");
add("Oceania", "AU FJ KI MH FM NR NZ PW PG WS SB TO TV VU");
add("Antarctica", "AQ");

const ORDER = ["Africa", "Antarctica", "Asia", "Europe", "North America", "Oceania", "South America"];

export type ContinentGroup<T> = { name: string; countries: T[] };

/** Continents that have at least one country, A-Z. Countries with an unknown code go to "Other". */
export function groupByContinent<T extends { country_code: string | null }>(countries: T[]): ContinentGroup<T>[] {
  const map = new Map<string, T[]>();
  for (const c of countries) {
    const name = CONTINENT_CODES[(c.country_code ?? "").toUpperCase()] ?? "Other";
    map.set(name, [...(map.get(name) ?? []), c]);
  }
  return [...map.entries()]
    .sort(([a], [b]) => (ORDER.indexOf(a) + 1 || 99) - (ORDER.indexOf(b) + 1 || 99))
    .map(([name, list]) => ({ name, countries: list }));
}
