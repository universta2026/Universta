import {
  Banknote,
  BookOpen,
  Brain,
  Briefcase,
  Building2,
  Calculator,
  ChefHat,
  Code2,
  Cog,
  Dna,
  Drama,
  Dumbbell,
  FlaskConical,
  Gamepad2,
  GraduationCap,
  Heart,
  HeartHandshake,
  Landmark,
  Megaphone,
  MessageCircle,
  Newspaper,
  Palette,
  PenTool,
  Pill,
  Plane,
  Rocket,
  Scale,
  Ship,
  ShieldAlert,
  Shirt,
  Sprout,
  Stethoscope,
  TreePalm,
  Truck,
  Users,
  Utensils,
  Zap,
  type LucideIcon,
} from "lucide-react";

// Icon per subject, picked by the subject's slug so each subject looks like what it covers.
const SLUG_ICONS: Record<string, LucideIcon> = {
  "agriculture-environmental-sciences": Sprout,
  "architecture-built-environment": Building2,
  "arts-humanities-social-sciences": Drama,
  "business-management": Briefcase,
  "computing-information-technology": Code2,
  "education-pgce-teaching": GraduationCap,
  engineering: Cog,
  science: FlaskConical,
  "creative-arts-design-communication": Palette,
  "communication-media-journalism": Newspaper,
  "health-medicine-veterinary-studies": Stethoscope,
  law: Scale,
  "hospitality-tourism-events": TreePalm,
  "sports-exercise": Dumbbell,
  "psychology-behavioural-sciences": Brain,
  "fashion-textiles": Shirt,
  "hospitality-culinary-food": ChefHat,
  "aviation-aerospace": Plane,
  "maritime-shipping": Ship,
  "media-entertainment-gaming": Gamepad2,
  "public-policy-government-international-studies": Landmark,
  "economics-finance": Banknote,
  "mathematics-statistics": Calculator,
  "biological-life-sciences": Dna,
  "pharmaceutical-pharmaceutical-sciences": Pill,
  "social-work-community-services": HeartHandshake,
  "transport-logistics": Truck,
  "energy-oil-gas": Zap,
  "security-defence-emergency-management": ShieldAlert,
  "emerging-interdisciplinary-subjects": Rocket,
};

// The value typed in the `icon_key` field in Directus picks the icon.
const ICONS: Record<string, LucideIcon> = {
  code: Code2,
  briefcase: Briefcase,
  cog: Cog,
  heart: Heart,
  scale: Scale,
  "pen-tool": PenTool,
  users: Users,
  flask: FlaskConical,
  utensils: Utensils,
  megaphone: Megaphone,
  plane: Plane,
  message: MessageCircle,
};

// size "md" = 48px tile (cards), "lg" = 72px tile (page hero)
// The slug wins; the Directus `icon_key` is used for subjects that have no slug icon above.
export default function SubjectIcon({
  name,
  slug,
  size = "md",
}: {
  name: string | null;
  slug?: string | null;
  size?: "md" | "lg";
}) {
  const Icon = (slug && SLUG_ICONS[slug]) || (name && ICONS[name]) || BookOpen;
  return (
    <span
      className="ico-tile"
      style={size === "lg" ? { width: 72, height: 72, borderRadius: 16 } : undefined}
    >
      <Icon className="ico ico-lg" aria-hidden />
    </span>
  );
}
