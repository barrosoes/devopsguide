import { motion } from "framer-motion";

interface Repo {
  id: number;
  name: string;
  description: string | null;
  html_url: string;
  stargazers_count: number;
}

export default function ProjectsSection({
  repos,
  loading,
}: {
  repos: Repo[];
  loading: boolean;
}) {
  return (
    <section className="max-w-6xl mx-auto px-6 py-24 border-t border-slate-800">
      <h2 className="text-3xl font-semibold mb-16 text-center">
        Highlighted Projects
      </h2>

      {loading ? (
        <p className="text-slate-400 text-center">Loading...</p>
      ) : (
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-10">
          {repos.map((repo) => (
            <motion.div
              key={repo.id}
              whileHover={{ y: -6 }}
              className="bg-slate-900/60 border border-slate-800 p-8 rounded-2xl"
            >
              <h3 className="text-lg font-semibold mb-3">
                {repo.name}
              </h3>

              <p className="text-slate-400 text-sm mb-6">
                {repo.description || "Cloud / DevOps / Infrastructure Project"}
              </p>

              <div className="flex justify-between text-sm">
                <span className="text-slate-500">
                  ⭐ {repo.stargazers_count}
                </span>

                <a
                  href={repo.html_url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-blue-400 hover:underline"
                >
                  View →
                </a>
              </div>
            </motion.div>
          ))}
        </div>
      )}
    </section>
  );
}

