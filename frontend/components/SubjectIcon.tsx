import {
  BookOpen,
  Briefcase,
  Code2,
  Cog,
  FlaskConical,
  Heart,
  Megaphone,
  MessageCircle,
  PenTool,
  Plane,
  Scale,
  Users,
  Utensils,
  type LucideIcon,
} from "lucide-react";

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
export default function SubjectIcon({ name, size = "md" }: { name: string | null; size?: "md" | "lg" }) {
  const Icon = (name && ICONS[name]) || BookOpen;
  return (
    <span
      className="ico-tile"
      style={size === "lg" ? { width: 72, height: 72, borderRadius: 16 } : undefined}
    >
      <Icon className="ico ico-lg" aria-hidden />
    </span>
  );
}
