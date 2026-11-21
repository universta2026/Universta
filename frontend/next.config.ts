import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // The study abroad pages moved from /studyabroad to /study-abroad: keep old links and bookmarks working.
  async redirects() {
    return [
      { source: "/studyabroad", destination: "/study-abroad", permanent: true },
      { source: "/studyabroad/:slug*", destination: "/study-abroad/:slug*", permanent: true },
    ];
  },
};

export default nextConfig;
