---
description: Create a new git worktree for a feature branch
---

# Create New Worktree

Ask the user for the following information:

1. **Branch name**: What should the new branch be called?
2. **Description**: A short description of what they're working on in this feature

Then:

1. Create a new git worktree in `../{repo-name}-{branch-name}` with the
   specified branch name (where {repo-name} is the current repository
   directory name)
2. Ensure the worktree is created from the current branch (usually `main`)
3. Display the path to the new worktree
4. Remind the user they can `cd` into the new worktree to start working

Use the command:

```bash
git worktree add -b {branch-name} ../{repo-name}-{branch-name}
```

After creation, inform the user:

- The worktree location
- The branch name
- The description (for their reference)
- How to navigate to it: `cd ../{repo-name}-{branch-name}`
