FROM ubuntu:22.04

# Lean 4 (core toolchain only — no mathlib, so the image stays light and the proof is fully
# self-contained). elan installs the pinned toolchain at build time; runs are --network none.
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV ELAN_HOME=/opt/elan
RUN curl -fsSL https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh \
      | sh -s -- -y --default-toolchain none --no-modify-path \
    && /opt/elan/bin/elan toolchain install leanprover/lean4:v4.15.0 \
    && /opt/elan/bin/elan default leanprover/lean4:v4.15.0 \
    && ln -s "$(ls -d /opt/elan/toolchains/*/ | head -1)" /opt/lean \
    && chmod -R a+rX /opt/elan /opt/lean

# put the REAL lean binary on PATH (not the elan shim) so the agent never triggers a network
# self-update under --network none.
ENV PATH=/opt/lean/bin:$PATH
RUN lean --version

# non-root user the agent runs as; it edits Problem.lean and runs `lean` to iterate.
# Tamper-proofing is elsewhere: the grader re-checks the locked prelude/statement and runs
# `#print axioms` itself (never trusting the agent's own lean output).
RUN useradd -m -u 1000 agent

WORKDIR /app
COPY app /app
RUN chown -R agent:agent /app

CMD ["sleep", "infinity"]
