# Releasing

## One-time setup

1. Create the project on CurseForge (https://authors.curseforge.com), using `curseforge/project.md` and `curseforge/description.md`. New projects are reviewed by CurseForge before they go public.
2. Add the project's id to the repository: Settings > Secrets and variables > Actions > **Variables** > `CF_PROJECT_ID`.
3. Make an API token at https://legacy.curseforge.com/account/api-tokens and add it as the **secret** `CF_API_TOKEN`.
4. Add `## X-Curse-Project-ID: <id>` to `LoreForeverHush.toc`, so addon managers can match an installed copy to the project.

## Each release

1. Test in game: the zip from the latest Release workflow run on `main` (its Artifacts) is exactly what ships.
2. Bump `## Version:` in `LoreForeverHush.toc` and add a `## <version>` section to `CHANGELOG.md`.
3. Tag and push: `git tag v<version> && git push origin v<version>`.

The tag makes a GitHub release with the zip and uploads it to CurseForge for WoW Forever (game version 1.60.1, `CF_GAME_VERSIONS` in the workflow), with Spoken and Lore Forever as required dependencies.
