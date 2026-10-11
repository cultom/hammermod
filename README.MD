[![ContentDB](https://content.minetest.net/packages/cultom/hammermod/shields/title/)](https://content.minetest.net/packages/cultom/hammermod/)

## Releasing

Releases are made from git tags. Push an annotated version tag; its message becomes the release notes:

```sh
git tag -a 0.2.0 -m "Works in Mineclonia and VoxeLibre; uses xcompat materials when installed"
git push origin 0.2.0
```

- **GitHub (immediately):** CI runs the tests in Minetest Game, Mineclonia and VoxeLibre and creates a
  GitHub release with a zip.
- **ContentDB (nightly):** the package's *automatic releases* are set to "New Tag" / "Create release"
  ([update settings](https://content.luanti.org/packages/cultom/hammermod/update-config/), editable by every
  maintainer). ContentDB checks the repository once a day and releases the newest tag.

The release workflow can also publish to ContentDB right away, but ContentDB only accepts API tokens of
the package's author ([contentdb#612](https://github.com/luanti-org/contentdb/issues/612)). For that, a
repository admin stores cultom's token once with [avanti-luanti](https://github.com/culmat/avanti-luanti):
`avanti secrets setup && avanti secrets push cultom/hammermod`. Both ways can run side by side;
ContentDB never releases the same commit twice.
