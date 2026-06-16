# Self-hosted n8n on Dockhold

Run your **own** [n8n](https://n8n.io) automation instance on
[Dockhold](https://dockhold.eu) — wired to a managed database so your workflows
and credentials persist. This template is the upstream n8n image plus a small
entrypoint that configures it for Dockhold's port, database, and HTTPS edge.

[![Deploy to Dockhold](https://img.shields.io/badge/Deploy%20to-Dockhold-2563eb?style=for-the-badge)](https://app.dockhold.eu/new?repo=https://github.com/dockhold/n8n-starter)

## License — read this first

n8n is **not** MIT/open-source. It's distributed under the
[**Sustainable Use License**](https://docs.n8n.io/sustainable-use-license/)
(fair-code). In plain terms:

- ✅ You **may** run this for your **own** internal or business automations, and
  build workflows for clients.
- ❌ You **may not** offer this n8n instance as a paid service to others,
  white-label it, or charge people for access — that needs a
  [commercial license from n8n](https://n8n.io). That restriction is **your**
  responsibility as the operator.

This template's own glue (Dockerfile, entrypoint) is MIT; n8n itself remains
under its own license.

## Deploy it

> **Needs the Pro plan.** The n8n image is large and n8n wants more memory than
> the free tier provides, so deploy this on Pro (or higher).

1. Click **Use this template** (or fork this repo).
2. **Before deploying**, plan to set `N8N_ENCRYPTION_KEY` (see below) — saved
   credentials are encrypted with it.
3. [Deploy it](https://app.dockhold.eu/new?repo=https://github.com/dockhold/n8n-starter)
   and **check "Add a managed database."** Dockhold injects `DATABASE_URL`; the
   entrypoint points n8n at Postgres automatically.
4. In the dashboard set:
   - `N8N_ENCRYPTION_KEY` — a stable secret (**use the Vault**). Generate one:
     `openssl rand -hex 16`. **Set this before you create any credentials** — if
     it changes, saved credentials can't be decrypted.
   - `N8N_HOST` = your app's host (e.g. `n8n-starter-xxxx.dockhold.app`)
   - `WEBHOOK_URL` = `https://<that host>/`
   Then restart.
5. Open the URL and create your owner account.

## How it works

The [`entrypoint.sh`](entrypoint.sh) adapts upstream n8n to Dockhold:

- **Port:** binds `0.0.0.0:$PORT` (`N8N_PORT`/`N8N_LISTEN_ADDRESS`).
- **Database:** maps the injected `DATABASE_URL` to n8n's `DB_TYPE=postgresdb`
  and `DB_POSTGRESDB_*`. **This is essential** — app filesystems are ephemeral,
  so without Postgres n8n would lose everything on restart.
- **User folder:** `/tmp/n8n` (the container runs as a non-root user that can't
  write n8n's default home). Real state is in Postgres + the encryption key, so
  an ephemeral folder is fine.
- **HTTPS:** sets `N8N_PROTOCOL=https` and trusts the proxy so the editor and
  login work behind Dockhold's edge.

## Pin a version

For production, change `FROM n8nio/n8n:latest` in the [`Dockerfile`](Dockerfile)
to a specific version (e.g. `n8nio/n8n:1.70.0`) so deploys are reproducible.

## Full walkthrough

[Deploy n8n](https://dockhold.eu/docs/recipes/deploy-n8n) — the step-by-step
recipe, including the required variables and the license note.
