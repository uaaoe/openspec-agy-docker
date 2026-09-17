# Template Core Runtime & Security

## Purpose

Define the security boundaries, tool prerequisites, and credential isolation guarantees for the containerized Antigravity CLI and OpenSpec runtime environment.

## Requirements

### Requirement: Unprivileged Container Execution
The agent runtime environment SHALL execute under an unprivileged user identity whose UID and GID match the host user.

#### Scenario: Host user permission alignment
- **WHEN** the container is launched by the host user
- **THEN** all created workspace files and caches are owned by the host UID and GID, and root capabilities are dropped (`CAP_DROP ALL`).

### Requirement: Tool Availability
The runtime container SHALL provide Antigravity CLI (`agy`), OpenSpec CLI (`openspec`), and Git.

#### Scenario: Command-line tool verification
- **WHEN** `agy`, `openspec`, or `git` commands are executed inside the container
- **THEN** each executable is located on the system `$PATH` and responds successfully.

### Requirement: Credential and Secrets Isolation
Third-party AI API keys SHALL be loaded exclusively via environment files and never committed to version control.

#### Scenario: Environment configuration
- **WHEN** third-party keys are defined in `.env`
- **THEN** Docker Compose passes them to the container without exposing them in Git or shell command history.
