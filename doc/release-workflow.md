# Release Workflow

GrabKit is developed as a monorepo, but each package is published separately to
pub.dev. Keep normal development convenient, then use a short-lived release
branch for pub.dev-specific manifest changes.

## Branch Roles

- `main`: normal monorepo development. Internal GrabKit dependencies should use
  local `path:` dependencies so all packages can be edited and tested together.
- `integration/git-consumer-test`: optional branch for testing unreleased
  GrabKit changes from real apps through Git dependencies.
- `release/pub-dev-x.y.z`: short-lived release branch used to prepare and
  publish a pub.dev package set.

## Development Manifests

On `main`, module packages should usually keep:

```yaml
publish_to: "none"

dependencies:
  grabkit:
    path: ../..
```

Packages that depend on sibling modules should also use local paths on `main`:

```yaml
dependencies:
  grabkit:
    path: ../..
  grabkit_network:
    path: ../grabkit_network
```

This keeps local analysis, tests, examples, and cross-package edits simple.

## Git Consumer Testing

Use this branch when an app needs to test unreleased GrabKit changes before a
pub.dev release.

```yaml
dependencies:
  grabkit:
    git:
      url: https://github.com/pandytconsulting/GrabKit.git
      ref: integration/git-consumer-test
      path: .
```

For subpackages:

```yaml
dependencies:
  grabkit_network:
    git:
      url: https://github.com/pandytconsulting/GrabKit.git
      ref: integration/git-consumer-test
      path: packages/grabkit_network
```

When the Git branch moves, app lockfiles stay pinned to the old commit. Refresh
them with:

```sh
flutter pub upgrade \
  grabkit \
  grabkit_environment \
  grabkit_export \
  grabkit_logs \
  grabkit_network \
  grabkit_network_dio \
  grabkit_realtime
```

Fully stop and restart the app after changing package sources.

## Pub.dev Release Branch

Create a branch from the release-ready `main` commit:

```sh
git checkout main
git pull
git checkout -b release/pub-dev-x.y.z
```

On this branch:

- remove `publish_to: "none"` from packages that will be published;
- replace internal local paths with hosted constraints for the release version;
- update each package `version`;
- update every package `CHANGELOG.md`;
- run dry-runs before publishing.

Example hosted dependency shape:

```yaml
dependencies:
  grabkit: ^0.1.1
  grabkit_network: ^0.1.1
```

## .pubignore Gotcha

Do not let the root `.pubignore` hide `packages/` while publishing module
packages. If the root `.pubignore` contains:

```text
packages/
```

then running `flutter pub publish --dry-run` inside
`packages/grabkit_environment` can make Pub report that `pubspec.yaml`,
`LICENSE`, `README.md`, and `CHANGELOG.md` are missing.

For module publishing, root `.pubignore` must not hide `packages/`.

For future root `grabkit` publishes, decide intentionally whether the root
archive should include or exclude the monorepo `packages/` directory. If it
should exclude modules, make that a release-branch-only change and restore the
module-friendly ignore state before publishing subpackages.

## Publish Order

Publish packages in dependency order:

1. `grabkit`
2. `grabkit_environment`
3. `grabkit_logs`
4. `grabkit_realtime`
5. `grabkit_network`
6. `grabkit_network_dio`
7. `grabkit_export`
8. `grabkit_all`

Commands:

```sh
flutter pub publish --dry-run
flutter pub publish
```

Run those from each package directory in the order above.

## Validation Checklist

Before publishing:

- `git status` is clean except intentional release-branch changes;
- package versions and internal constraints match the target release;
- package READMEs, LICENSE files, and CHANGELOGs are present;
- root and package GitHub metadata points to
  `https://github.com/pandytconsulting/GrabKit`;
- `flutter pub publish --dry-run` passes for each package;
- at least one real app has tested the release candidate through Git or hosted
  dependencies.

## Tagging

After all packages publish successfully:

```sh
git tag vX.Y.Z
git push origin vX.Y.Z
```

Then restore `main` to normal development mode if release-only manifest changes
were merged or applied there.

## Post-Release Cleanup

After publishing:

- restore local `path:` dependencies on `main`;
- restore `publish_to: "none"` on `main` if packages should not be published
  accidentally during development;
- keep the release branch or tag for audit history;
- update consumer apps from Git dependencies to hosted pub.dev constraints when
  they are ready.
