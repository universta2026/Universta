# Study Abroad country content: status and future work

## How country pages are filled
| Block | Source | Linked to |
|---|---|---|
| Why, visa, application, cost, eligibility | text columns on `countries` | - |
| Top subjects | `country_sections` (`section='subject'`) | `subject_id` -> `subjects` (page `/subjects/<slug>`) |
| Top courses | `country_sections` (`section='course'`) | `specialization_id` -> `specializations` (page `/specializations/<slug>`) |
| Universities, exams, scholarships, intakes | `country_sections` text rows | **no table yet** (see below) |

Linked rows get their URL from the API (`GET /countries/{slug}/sections`) when `url` is empty and the target is published.

## Content batches (seed_country_content_batchN.sql)
- Batch 1 (done, Nov 2026): United Kingdom, United States, Canada, Australia, Germany.
- Batch 2 (done, Nov 2026): Ireland, France, Netherlands, New Zealand, United Arab Emirates.
- Batch 3 (done, Nov 2026): Spain, Italy, Singapore, Sweden, Malaysia.
- Remaining: all other countries in `seed_countries.sql`. Next suggested batch: Netherlands-style European picks Switzerland, Austria, Denmark, Finland, Poland; or Asia picks Japan, South Korea, China, Hong Kong, Turkey.

## Tables to create in future (to be updated)
These blocks are stop-gap text rows today. When each table exists, add a nullable FK on `country_sections` (like `subject_id`) or a country link table, then migrate the rows:
- `universities` (name, city, country, QS rank, website) -> "Top universities"
- `exams` (IELTS, TOEFL, PTE, GRE, GMAT, TestDaF...) -> "Exam requirements"
- `scholarships` (name, provider, level, deadline, countries) -> "Scholarships"
- `intakes` (country, term, start month, application deadline) -> "Intakes"
- Course level on courses: courses are linked to specializations only; a study level (`study_levels`) per row is not linked.

## Figures to re-check before publishing widely
Taken from secondary sources (university and consultancy pages), not official portals:
- UK: visa fee about £558, IHS about £776, funds £1,529/£1,171 per month, Graduate visa 18 months from 1 Jan 2027 (a government statement mentions 2 years for some universities).
- US: SEVIS $350 and visa $185, visa integrity fee status, duration-of-status rule (15 Sep 2026), proposed OPT fee.
- Canada: CA$23,448 funds (from 1 Sep 2026), 2026 cap about 408,000.
- Australia: AUD 2,500 visa fee from 1 Jul 2026 (sources conflict), AUD 29,710 funds.
- Germany: EUR 11,904 blocked account (sources conflict slightly), BW fee EUR 1,500 per semester.
- Ireland: EUR 10,000 funds (reported from mid-2025), Stamp 2 hours, Graduate Scheme lengths.
- France: EUR 877.50 a month from 1 Aug 2026 (official page still showed EUR 615), tuition about EUR 2,900 / 3,900 at public universities (from memory of recent years, not re-checked).
- Netherlands: IND fee EUR 243-254, study norm about EUR 1,180 a month, non-EU tuition range (not found in research).
- New Zealand: NZ$850 visa fee and 20 vs 25 work hours conflict; tuition range not found in research.
- UAE: visa cost AED 5,500-8,500 (one source); tuition range and Golden Visa criteria not found in research.
- Spain: IPREM EUR 600 a month and 30 work hours (reported); public/private tuition ranges and post-study permit length are not from research.
- Italy: EUR 10,179.85 funds (embassy pages); tuition ranges and the 20-hour work limit are not from research; embassy visa deadlines differ.
- Singapore: S$45 / S$60 / S$30 pass fees (ICA); tuition amounts, grant work bond (3 years is typical) and work-hour limit are not from research.
- Sweden: SEK 10,656 funds and SEK 1,500 permit fee (Migrationsverket); the 15-hour work limit from 11 June 2026 looks unusual, so confirm it. Tuition range and the SEK 900 application fee are not from research.
- Malaysia: EMGS fee conflict (RM 1,500-2,500 vs 2,650-3,850); tuition and living-cost ranges are not from research; UM rank 56 is from one news report.
- QS 2027 ranks: Confirmed ranks are shown (NUS 10, NTU 12; Trinity 75, PSL 34, Auckland 67, Khalifa 147; TU Delft 48 was unconfirmed so left out). Melbourne and the German universities have no rank in the text because the search did not confirm them.

## Batches 4-10 status (50 countries done)

| Batch | Countries |
|---|---|
| 4 | Switzerland, Austria, Denmark, Finland, Poland |
| 5 | Japan, South Korea, China, Turkey, Portugal (Hong Kong skipped: not in `countries`) |
| 6 | Belgium, Norway, Czechia, Hungary, Greece |
| 7 | Saudi Arabia, Qatar, Thailand, Vietnam, Indonesia |
| 8 | Cyprus, Malta, Lithuania, Latvia, Estonia |
| 9 | Russia, Georgia, Kazakhstan, Philippines, South Africa |
| 10 | Mexico, Brazil, Argentina, Chile, Egypt |

### Figures to re-check against official sources (batches 8-10)
- Tuition ranges marked "estimate" were not found in search results: Cyprus, Lithuania, Latvia, Estonia, Russia, Georgia, Philippines, South Africa, Mexico (private), Brazil (private), Chile, all batches 8-10.
- Proof-of-funds figures conflict between sources: Latvia, Estonia, South Africa (ZAR 30k-120k), Cyprus (deposit amount unconfirmed).
- Georgia: 2026 tighter student-permit rules reported but final text not confirmed.
- Argentina: free public-university tuition for foreigners is under policy debate.
- Egypt: student work rights conflict between sources; Al-Azhar free tuition unconfirmed.
- Chile: work rights conflict (30 h/week vs none).
- QS 2027 ranks from press/aggregators only: Lomonosov (=115), UCT (184), UP Philippines (402), UBA (84), UC Chile (119), USP (133), UNAM (145). Nazarbayev and AUC ranks not found, so none shown.
- Several `exams`/`sch` rows have empty URLs where no official link was verified.

## Batches 11-20 status (100 countries done)

| Batch | Countries |
|---|---|
| 11 | Romania, Bulgaria, Croatia, Serbia, Slovakia |
| 12 | Slovenia, Iceland, Luxembourg, Ukraine, Uzbekistan |
| 13 | Kyrgyzstan, Armenia, Azerbaijan, Bahrain, Kuwait |
| 14 | Oman, Jordan, Lebanon, Israel, Iran |
| 15 | Nepal, Bangladesh, Sri Lanka, Pakistan, Mauritius |
| 16 | Mongolia, Fiji, Brunei, Cambodia, Maldives |
| 17 | Nigeria, Ghana, Kenya, Uganda, Tanzania |
| 18 | Colombia, Peru, Costa Rica, Panama, Uruguay |
| 19 | Morocco, Tunisia, Ethiopia, Rwanda, Zambia |
| 20 | Ecuador, Cuba, Jamaica, Moldova, Trinidad and Tobago |

### Weak spots to re-check (batches 11-20)
- Visa/permit steps not found in search (confirm with embassy): Uzbekistan, Uganda, Nepal (no 2026 student visa rules), Iran, Kuwait fees.
- Tuition not found or conflicting: Kuwait, Lebanon, Israel, Iran, Panama (University of Panama), Cuba (ELAM "free" vs "not reported"), Ethiopia, Rwanda (only 2017-19 tables), Zambia (two conflicting UNZA schedules), Morocco, Tunisia, Mongolia (year unnamed).
- Fee/permit figures that conflict between sources: Armenia (TRP fee and start date 1 Aug vs 1 Nov 2026), Luxembourg (per-semester fee), Maldives (2x vs 5x international fee), Sri Lanka (visa fee), Kenya (pass fee USD 100 vs KES 5,000), Ecuador (visa fee), Colombia (visa fee), Malta/Latvia/Estonia (funds).
- Policy changes reported but unconfirmed: Georgia 2026 permit rules, Kyrgyzstan new admission centre and medical accreditation, Luxembourg Visa D from 1 Oct 2026, Iceland non-EEA tuition levels.
- Safety/travel advisories noted in text: Lebanon, Israel, Iran, Cuba, Ethiopia, Ukraine, Russia.
- Colombia: the M visa vs V Estudiante category conflicts across sources.
- Several `exams`/`sch` rows have empty URLs where no official link was verified.
- Not seeded: `usa` and `amr` slugs exist in `countries` (likely duplicate or placeholder rows); `united-states` was done in batch 1.

## Batches 21-30 status (all 195 published countries seeded)

| Batch | Countries |
|---|---|
| 21 | India, Albania, Bosnia and Herzegovina, North Macedonia, Montenegro, Belarus, Liechtenstein, Andorra |
| 22 | Algeria, Botswana, Zimbabwe, Namibia, Senegal, Cameroon, Angola, Mozambique, Bhutan |
| 23 | Bolivia, Paraguay, Venezuela, Guatemala, Honduras, El Salvador, Nicaragua, Dominican Republic, Haiti, Guyana |
| 24 | Bahamas, Barbados, Belize, Antigua and Barbuda, Dominica, Grenada, Saint Kitts and Nevis, Saint Lucia, Saint Vincent |
| 25 | Afghanistan, Iraq, Libya, Palestine, Myanmar, Laos, North Korea, Tajikistan, Turkmenistan |
| 26 | Gambia, Sierra Leone, Liberia, Malawi, Lesotho, Eswatini, Seychelles, South Sudan, Sudan |
| 27 | Benin, Burkina Faso, Cote d'Ivoire, Mali, Niger, Togo, Guinea, Madagascar, Gabon |
| 28 | Burundi, Cabo Verde, Central African Republic, Chad, Comoros, DR Congo, Djibouti, Equatorial Guinea, Eritrea, Guinea-Bissau |
| 29 | Kiribati, Marshall Islands, Micronesia, Nauru, Palau, Papua New Guinea, Samoa, Solomon Islands, Tonga, Tuvalu, Vanuatu |
| 30 | Mauritania, Monaco, Republic of the Congo, San Marino, Sao Tome and Principe, Somalia, Suriname, Syria, Timor-Leste, Vatican City, Yemen |

Check: `select count(*) from countries c where status='published' and not exists (select 1 from country_sections s where s.country_id=c.id)` returns 0.

### Weak spots to re-check (batches 21-30)
- Many small or fragile countries have no official visa or fee source. Their text says so and uses aggregator ranges or "contact the university". Re-check these first: Afghanistan, Libya, Somalia, South Sudan, Sudan, Syria, Yemen, Haiti, North Korea, Eritrea, Central African Republic, Chad, Turkmenistan, Myanmar, Venezuela, Nicaragua.
- Tuition or fee figures that conflict between sources: Seychelles (UniSey), Lesotho (NUL), Guinea, Niger, Liberia (UL), Burundi, Cabo Verde (free tuition claim), Guatemala (USAC), El Salvador, Dominican Republic (medicine), Bhutan (RTC vs RUB), Solomon Islands, Somalia (SIMAD), Suriname, Timor-Leste, Vanuatu (USP).
- Visa fee figures from secondary sources: Botswana, Zimbabwe (US$200 permit), Namibia (NAD 2,200), Belize (BZ$200/750/3,000), Barbados (BBD 300), Samoa (SAT 450), Togo (65,000 F CFA), Burundi, Timor-Leste (US$50 vs 80), Venezuela, Honduras, Paraguay.
- Policy changes noted but unconfirmed: UK student-visa pause for Afghanistan, Cameroon, Myanmar, Sudan (from 26 March 2026), Nicaragua Provision 002-2026, Chad e-Visa (11 May 2026), Somalia ETAS, Bhutan 2026 student visa guideline, Mauritania e-visa, Antigua US visa restrictions.
- Travel advisories noted in text (no recommendation to travel): Afghanistan, Haiti, Libya, North Korea, Somalia, South Sudan, Sudan, Syria, Venezuela, Yemen, Nicaragua, Eritrea, Central African Republic.
- Dominica text notes that Ross University School of Medicine now sits in Barbados.
- Many `unis` rows have empty URLs where no official link was verified.
- Subject and course rows for Pacific islands, Monaco, San Marino and Vatican City use custom lists; others default to the medicine-centred list.
- Not seeded: draft rows `usa` and `amr` (not published).
