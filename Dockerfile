# Self-hosted n8n on Dockhold. n8n is distributed under the Sustainable Use
# License (see README) — this image is the upstream n8n plus a small entrypoint
# that wires it to Dockhold's port, managed Postgres, and HTTPS edge.
#
# Pin a specific version for production, e.g. n8nio/n8n:1.70.0.
FROM n8nio/n8n:latest

USER root
COPY entrypoint.sh /dockhold-entrypoint.sh
RUN chmod +x /dockhold-entrypoint.sh
USER node

ENTRYPOINT ["/dockhold-entrypoint.sh"]
