# CurseForge publishing

FavorCraft has its addon files and `FavorCraft.toc` at the repository root.
`.pkgmeta` instructs the CurseForge repository packager to put the
addon into a **FavorCraft/** directory and omit development-only files.
`manual-changelog` sends the whole `CHANGELOG.md` as the file notes, so
CurseForge shows those player notes instead of commit messages.
`CHANGELOG.md` stays available to the packager. The other Forever addons
use this same `.pkgmeta` layout.

## Package verification

GitHub Actions creates a downloadable ZIP artifact on pushes to main and on
new version tags. The ZIP has `FavorCraft/FavorCraft.toc` at its root.

CurseForge packages a file when the version tag is pushed, the same way
Social Forever, Roar Forever, and Resist Forever do. The tag is created on
the release commit and pushed with it. GitHub Actions checks the addon and
builds a ZIP for review. It does not create the tag or the CurseForge file.

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
4. Update both TOC versions and `CHANGELOG.md`, commit, then create an
   annotated tag such as `v0.4.9-beta` on that commit. Push `main` and the
   tag together. Create the GitHub prerelease on that tag with the player
   notes and no attached ZIP. CurseForge builds the installable file from
   the tag.
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
  Confirm `.pkgmeta` contains `package-as: FavorCraft`.
- CurseForge app cannot discover the project? Check its approval status and
  that an approved Beta or Release file exists.
- To avoid accidental duplicate versions, never move/overwrite an existing
  published tag simply to retrigger packaging.

Sources:
- https://support.curseforge.com/support/solutions/articles/9000197281
- https://support.curseforge.com/support/solutions/articles/9000203228-manually-triggering-the-auto-packager
