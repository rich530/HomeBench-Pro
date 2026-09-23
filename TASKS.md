# Task Ledger

Written by the agent during `autorun.sh plan <milestone>`; approved by Rich with `autorun.sh approve <milestone>`.
Format (the runner depends on it exactly):
- [ ] T-001 Short name | accept: the test or evidence that proves it is done
- [x] T-001 ... (done, merged)
- [~] T-001 ... BLOCKED: exactly what Rich must provide

Rules: tasks are small enough for one session (roughly 1 to 3 hours of agent work), ordered by dependency, and each names its acceptance evidence. The last task of every milestone is "T-9xx Milestone acceptance run and handoff".

