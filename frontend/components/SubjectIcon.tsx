import {
  BookOpen,
  Briefcase,
  Code2,
  Cog,
  FlaskConical,
  Heart,
  Megaphone,
  PenTool,
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
};

export default function SubjectIcon({ name }: { name: string | null }) {
  const Icon = (name && ICONS[name]) || BookOpen;
  return (
    <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-blue-50 text-blue-600">
      <Icon size={20} />
    </span>
  );
}
