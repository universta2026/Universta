import { Globe } from "lucide-react";
import { Flag } from "./ContinentCards";

// Big icon tile in the header of the study-abroad pages.
// Country page -> its flag. Continent page -> a globe showing that part of the world.
const GLOBES: Record<string, string> = {
  Africa: "\u{1F30D}",
  Europe: "\u{1F30D}",
  "North America": "\u{1F30E}",
  "South America": "\u{1F30E}",
  Asia: "\u{1F30F}",
  Oceania: "\u{1F30F}",
};

export function CountryTile({ code }: { code?: string | null }) {
  const has = code?.trim().length === 2;
  return (
    <span className="hero-tile hero-tile-flag">
      {has ? <Flag code={code} w={52} h={38} /> : <Globe className="ico" aria-hidden />}
    </span>
  );
}

export function ContinentTile({ name }: { name: string }) {
  const globe = GLOBES[name];
  return (
    <span className="hero-tile hero-tile-globe">
      {globe ? (
        <span role="img" aria-label={`${name} on the globe`}>
          {globe}
        </span>
      ) : (
        <Globe className="ico" aria-hidden />
      )}
    </span>
  );
}

export function WorldTile() {
  return (
    <span className="hero-tile hero-tile-globe">
      <span role="img" aria-label="World">
        {"\u{1F310}"}
      </span>
    </span>
  );
}
