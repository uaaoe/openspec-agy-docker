# Antigravity Workspace Directives: Containerized Sandbox

You are operating inside an isolated, containerized execution environment for software engineering, specification planning, and testing.

---

## 1. Execution Environment & Boundaries

* **Workspace Root:** Your workspace is strictly scoped to `/workspace` (which mounts the project root).
* **Unprivileged User Identity:** You run as an unprivileged user (`sandboxuser`) whose `UID:GID` matches the host user. You do not have `root` or `sudo` privileges. Linux capabilities are dropped (`CAP_DROP ALL`) and privilege escalation is blocked (`no-new-privileges:true`).
* **Git Identity & Ownership:** All workspace files and Git commits are owned by the host user identity. Host Git author identity (`user.name`, `user.email`) and signing configurations are mounted read-only from `~/.gitconfig`.
* **Network & Security Restrictions:**
  * Outbound internet access is enabled for calling AI APIs, downloading dependencies, and fetching remote git repositories.
  * You are strictly prohibited from probing local RFC 1918 subnets (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`).

---

## 2. Secrets & Credential Protocols

* **Gemini Authentication:** Antigravity CLI reuses cached OAuth credentials via the mounted `~/.gemini` directory or the `GEMINI_API_KEY` loaded from `.env`.
* **Third-Party API Keys:** Third-party keys (`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`) are accessible only through environment variables populated by Docker Compose via `.env`.
* **Hygiene:** Never log, print, commit, or hardcode API keys or secret tokens. Ensure `.env` is never committed to Git.

---

## 3. Spec-Driven Development (OpenSpec Protocol)

This workspace integrates **OpenSpec** (`@fission-ai/openspec`) for spec-driven changes:

1. **Specs Directory:** Long-lived domain specifications live in `openspec/specs/`.
2. **Changes Directory:** In-flight proposals and task lists live in `openspec/changes/`.
3. **Workflow Cycle:**
   - **Explore / Propose:** Inspect requirements and create structured change proposals (`/opsx:propose`).
   - **Apply:** Implement tasks sequentially against accepted specifications (`/opsx:apply`).
   - **Archive:** Merge approved spec deltas into main specifications once completed (`/opsx:archive`).
   - **Validate:** Run `openspec validate --all` before declaring work complete.

---

## 4. Reversibility & Clean Execution

* Check status and diffs (`git status`, `git diff`) before and after changes.
* Never execute destructive Git actions (e.g. `git reset --hard`, `git push --force`) without explicit instruction.
* Keep packages and tools installed at the workspace or user level.
