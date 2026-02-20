import { useEffect, useState } from "react";
import { motion } from "framer-motion";

interface Repo {
  id: number;
  name: string;
  description: string | null;
  html_url: string;
  stargazers_count: number;
  fork: boolean;
}

export default function Portfolio() {
  const username = "barrosoes";
  const [repos, setRepos] = useState<Repo[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch(`https://api.github.com/users/${username}/repos?sort=updated&per_page=12`)
      .then((res) => res.json())
      .then((data: Repo[]) => {
        const filtered = data
          .filter((repo) => !repo.fork)
          .sort((a, b) => b.stargazers_count - a.stargazers_count)
          .slice(0, 6);
        setRepos(filtered);
        setLoading(false);
      })
      .catch(() => setLoading(false));
  }, []);

  return (
    <div className="min-h-screen bg-slate-950 text-white overflow-x-hidden">
      {/* HERO */}
      <section className="relative max-w-6xl mx-auto px-6 pt-32 pb-28 text-center">
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
        >
          <h1 className="text-6xl font-bold mb-8 bg-gradient-to-r from-blue-500 to-cyan-400 bg-clip-text text-transparent">
            Anderson Barroso
          </h1>

          <p className="text-xl text-slate-400 mb-12 max-w-3xl mx-auto leading-relaxed">
            Building production-grade MultiCloud platforms with Kubernetes, GitOps and Infrastructure as Code.
          </p>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3, duration: 0.8 }}
          className="flex justify-center gap-6"
        >
          <motion.a
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.97 }}
            href="https://github.com/barrosoes"
            className="bg-blue-600 hover:bg-blue-700 px-8 py-3 rounded-2xl shadow-xl transition"
          >
            GitHub
          </motion.a>

          <motion.a
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.97 }}
            href="https://www.linkedin.com/in/anderson-rodrigues-barroso/"
            className="bg-slate-800 hover:bg-slate-700 px-8 py-3 rounded-2xl shadow-xl transition"
          >
            LinkedIn
          </motion.a>
        </motion.div>
      </section>

      {/* CORE CAPABILITIES */}
      <section className="max-w-6xl mx-auto px-6 py-24 border-t border-slate-800">
        <h2 className="text-3xl font-semibold mb-16 text-center">Core Capabilities</h2>

        <div className="grid md:grid-cols-3 gap-10">
          {[
            {
              title: "Kubernetes & GitOps",
              desc: "Production clusters on OKE with declarative deployments via ArgoCD."
            },
            {
              title: "CI/CD Automation",
              desc: "Container pipelines, registry integration and environment promotion."
            },
            {
              title: "MultiCloud Architecture",
              desc: "Designing scalable, secure and resilient cloud platforms."
            },
            {
              title: "Infrastructure as Code",
              desc: "Terraform-driven infrastructure with versioned and reproducible environments."
            },
            {
              title: "Performance & Observability",
              desc: "Monitoring, metrics and reliability engineering for production workloads."
            }
          ].map((item, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: index * 0.1 }}
              viewport={{ once: true }}
              whileHover={{ y: -6 }}
              className="bg-slate-900/60 backdrop-blur-sm border border-slate-800 p-8 rounded-2xl"
            >
              <h3 className="text-lg font-semibold mb-4">{item.title}</h3>
              <p className="text-slate-400 text-sm leading-relaxed">
                {item.desc}
              </p>
            </motion.div>
          ))}
        </div>
      </section>

      {/* ARCHITECTURE FLOW */}
      <section className="max-w-6xl mx-auto px-6 py-24 border-t border-slate-800 text-center">
        <h2 className="text-3xl font-semibold mb-16">Production Architecture Flow</h2>

        <div className="flex flex-wrap justify-center gap-6 text-sm text-slate-400">
          {[
            "GitHub",
            "CI Pipeline",
            "Container Registry",
            "ArgoCD (GitOps)",
            "OKE Cluster",
            "Ingress + TLS"
          ].map((step, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, scale: 0.8 }}
              whileInView={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.4, delay: index * 0.1 }}
              viewport={{ once: true }}
              className="bg-slate-900/60 border border-slate-800 px-5 py-3 rounded-full"
            >
              {step}
            </motion.div>
          ))}
        </div>
      </section>

      {/* DATABASE (Secondary) */}
      <section className="max-w-5xl mx-auto px-6 py-20 border-t border-slate-900 text-center">
        <h3 className="text-slate-600 uppercase tracking-wide text-xs mb-10">
          Enterprise Database Expertise
        </h3>

        <div className="grid md:grid-cols-2 gap-6">
          {[
            "Oracle RAC (High Availability)",
            "Oracle Data Guard (Disaster Recovery)",
            "Performance Tuning",
            "Enterprise Database Architecture"
          ].map((item, index) => (
            <div key={index} className="text-slate-500 text-sm">
              {item}
            </div>
          ))}
        </div>
      </section>

      {/* PROJECTS */}
      <section className="max-w-6xl mx-auto px-6 py-24 border-t border-slate-800">
        <h2 className="text-3xl font-semibold mb-16 text-center">Highlighted Projects</h2>

        {loading ? (
          <p className="text-slate-400 text-center">Loading projects...</p>
        ) : (
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-10">
            {repos.map((repo) => (
              <motion.div
                key={repo.id}
                whileHover={{ y: -8 }}
                className="bg-slate-900/60 backdrop-blur-sm border border-slate-800 p-8 rounded-2xl"
              >
                <h3 className="text-lg font-semibold mb-3">{repo.name}</h3>
                <p className="text-slate-400 text-sm mb-6 leading-relaxed">
                  {repo.description || "Cloud / DevOps / Infrastructure Project"}
                </p>
                <div className="flex justify-between items-center text-sm">
                  <span className="text-slate-500">⭐ {repo.stargazers_count}</span>
                  <a
                    href={repo.html_url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-blue-400 hover:underline"
                  >
                    View Repository
                  </a>
                </div>
              </motion.div>
            ))}
          </div>
        )}
      </section>

      {/* CONTACT */}
      <section className="max-w-4xl mx-auto px-6 py-24 border-t border-slate-800 text-center">
        <h2 className="text-3xl font-semibold mb-6">Let’s Build Something Great</h2>
        <p className="text-slate-400 mb-10">
          Available for DevOps, Cloud Architecture and Platform Engineering projects.
        </p>
        <motion.a
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.97 }}
          href="mailto:barrosoes@gmail.com"
          className="bg-gradient-to-r from-blue-600 to-cyan-500 hover:opacity-90 px-10 py-4 rounded-2xl shadow-xl transition"
        >
          Get in Touch
        </motion.a>
      </section>

      <footer className="text-center text-slate-600 text-sm py-12 border-t border-slate-800">
        © {new Date().getFullYear()} Anderson Barroso • Built with React • Deployed via GitOps on OKE
      </footer>
    </div>
  );
}

