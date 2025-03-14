# Oven

A tool for a multitude of automations.

## Features

### Filament Documentation for AI

We can get the documentation from Filament 3.x in an AI-friendly format.

It updates daily!

There's a file per Filament package, one MD file per package - Panels, Forms, Tables, etc.

It's ideal for local code agents, like Claude Code, Cursor, Windsurf, etc.

By having the documentation concatenated by package, the agent get more efficient and cost saving.

Download [here](https://github.com/ijpatricio/oven/releases/download/filament-docs/filament-3.x-packages-3.x.zip)

Copy-paste and run this script on a root of a project, download docs into `./docs/ai/filament-3.x`.

```bash
mkdir -p ./docs/ai/filament-3.x
curl -L https://github.com/ijpatricio/oven/releases/download/filament-docs/filament-3.x-packages-3.x.zip -o filament-temp.zip
unzip filament-temp.zip -d ./docs/ai/filament-3.x
rm filament-temp.zip
echo "Download and extraction completed successfully to ./docs/ai/filament-3.x"
```

Then, in CLAUDE.md, Cursor rules, Windsurf, you let the AI know about this.

Take this a starting point, and add your instructions for your custom preferences:

```md
# Filament Documentation Integration Rules

## Purpose
These rules define how to use the locally stored Filament documentation when working with this project.

## Documentation Structure
- Documentation is organized by package (Panels, Forms, Tables, etc.)
- Located at: `./docs/ai/filament-3.x/`
- Each package has its own markdown file with comprehensive documentation

## When to Reference Documentation
1. When implementing or modifying any Filament component
2. When troubleshooting Filament-specific issues
3. When exploring available options for a specific Filament feature
4. Before asking general questions about Filament capabilities

## How to Reference Documentation
For any Filament-related task, first check the relevant package documentation:

- For forms: `./docs/ai/filament-3.x/forms.md`
- For tables: `./docs/ai/filament-3.x/tables.md`
- For panels: `./docs/ai/filament-3.x/panels.md`
- For notifications: `./docs/ai/filament-3.x/notifications.md`
- For actions: `./docs/ai/filament-3.x/actions.md`
- For widgets: `./docs/ai/filament-3.x/widgets.md`
- For infolist: `./docs/ai/filament-3.x/infolist.md`

## Best Practices
1. Always reference the specific documentation section relevant to the current task
2. Use documentation examples as templates for implementation
3. Follow Filament's conventions and patterns as shown in documentation
4. When documentation differs from project implementation, prefer project-specific patterns
```

Code assistants:

- Claude Code https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview
- Cursor https://www.cursor.com
- Windsurf https://codeium.com

That's it. Happy coding!

## Usage

```bash
# Process Filament 3.x documentation
./run llm:3.x

# View available commands
./run
```








## Latest Documentation

Latest documentation is available [here](https://github.com/ijpatricio/oven/releases/download/latest-docs/docs-for-ai/filament-3.x-all.md).

Individual package documentation is available as a [ZIP file](https://github.com/ijpatricio/oven/releases/download/latest-docs/docs-for-ai/filament-3.x-packages-3.x.zip).

