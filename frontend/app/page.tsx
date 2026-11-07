import { redirect } from "next/navigation";

// Temporary: the home page is not built yet, so send visitors to /subjects.
export default function Home() {
  redirect("/subjects");
}
