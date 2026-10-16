# CurseForge publishing

FavorCraft has its addon files and `FavorCraft.toc` at the repository root.
`pkgmeta.yaml` instructs the CurseForge repository packager to put the
addon into a **FavorCraft/** directory and omit development-only files.
`manual-changelog` sends the whole `CHANGELOG.md` as the file notes, so
CurseForge shows those player notes instead of commit messages.

## Package verification

GitHub Actions creates a downloadable ZIP artifact on pushes to main and on
new version tags. The ZIP has `FavorCraft/FavorCraft.toc` at its root.

A validated main-branch commit with subject beginning `Release FavorCraft `
triggers a workflow that attempts to create the matching `v<version>` tag
and GitHub prerelease, attaching the installable ZIP. Existing tags are
never overwritten. GitHub Actions must have repository contents write access.

The ZIP can also be uploaded manually to the CurseForge project dashboard.
An ordinary GitHub source archive is **not** the same as a packaged addon.

## Enabling CurseForge automation

1. Create/approve the WoW addon project on CurseForge and configure the
   project's Source / Repository settings for
   `https://github.com/Morkahja/favorcraft`.
2. For CurseForge's repository auto-packager, generate an API token **in your
   CurseForge account** and add a **GitHub repository webhook** with payload:
   `https://www.curseforge.com/api/projects/PROJECT_ID/package?token=TOKEN`.
   The project ID comes from the CurseForge project page.
   Use Content type `application/json` and push events. **Never commit the
   token to this repository, an issue, or a screenshot.**
3. Check the GitHub webhook deliveries for a successful HTTP result.
4. Update the TOC versions and changelog and push a release commit on
   `main` with a subject beginning `Release FavorCraft `. The workflow then
   creates a matching tag such as `v0.4.2-beta` and a GitHub prerelease ZIP.
   The CurseForge webhook must be configured to receive the tag push.
5. Check the CurseForge project **Files** page for the packaged ZIP and
   the correct WoW Forever game version. A new project/file may require
   CurseForge moderation before it becomes publicly installable.

**Important:** A new Git commit, GitHub Release, or Actions ZIP by itself
cannot make CurseForge import an addon. The CurseForge repository connection
and delivery mechanism must be configured.

## Troubleshooting

- No GitHub webhook delivery? Set up/repair the CurseForge webhook.
- Delivery succeeded but no file? Check CurseForge Source/Packaging settings
  and ask CurseForge support to review the project, source URL and webhook.
- Only Alpha is available? Make sure a *new tagged commit* was pushed with
  a tag containing `beta` or `alpha` as intended.
- The published archive has scattered files instead of the addon folder?
  Confirm `pkgmeta.yaml` contains `package-as: FavorCraft`.
- CurseForge app cannot discover the project? Check its approval status and
  that an approved Beta or Release file exists.
- To avoid accidental duplicate versions, never move/overwrite an existing
  published tag simply to retrigger packaging.

Sources:
- https://support.curseforge.com/support/solutions/articles/9000197281
- https://support.curseforge.com/support/solutions/articles/9000203228-manually-triggering-the-auto-packager
