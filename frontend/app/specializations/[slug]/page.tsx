import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { getSpecialization } from "@/lib/api";

type Props = { params: Promise<{ slug: string }> };

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const spec = await getSpecialization(slug);
  return { title: spec ? `${spec.name} | Universta` : "Specialization not found | Universta" };
}

export default async function SpecializationPage({ params }: Props) {
  const { slug } = await params;
  const spec = await getSpecialization(slug);
  if (!spec) notFound();

  return (
    <main className="mx-auto max-w-4xl px-4 py-8">
      <nav className="text-xs text-slate-500">
        <Link href="/" className="hover:text-slate-900">Home</Link>
        <span className="mx-2">›</span>
        <Link href="/subjects" className="hover:text-slate-900">Subjects</Link>
        <span className="mx-2">›</span>
        <Link href={`/subjects/${spec.subject_slug}`} className="hover:text-slate-900">
          {spec.subject_name}
        </Link>
        <span className="mx-2">›</span>
        <span className="text-slate-900">{spec.name}</span>
      </nav>

      <p className="mt-6 text-xs font-semibold tracking-widest text-blue-600">SPECIALIZATION</p>
      <h1 className="mt-2 text-3xl font-bold text-slate-900">{spec.name}</h1>
      {spec.description && <p className="mt-3 max-w-2xl text-slate-700">{spec.description}</p>}

      <Link
        href={`/subjects/${spec.subject_slug}`}
        className="mt-8 inline-block rounded-lg border border-slate-300 px-4 py-2 text-sm font-medium hover:border-blue-400"
      >
        ← Back to {spec.subject_name}
      </Link>
    </main>
  );
}
