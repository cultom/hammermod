[![ContentDB](https://content.minetest.net/packages/cultom/hammermod/shields/title/)](https://content.minetest.net/packages/cultom/hammermod/)

## Releasing

Releases are made from git tags. Push a version tag such as `0.1.5`: CI runs the tests in Minetest Game,
Mineclonia and VoxeLibre, creates a GitHub release with a zip, and after the `contentdb` deployment is
approved, ContentDB imports the tag.

One-time setup by a repository admin, using a ContentDB token of the package author (cultom), with
[avanti-luanti](https://github.com/culmat/avanti-luanti):

```sh
avanti secrets setup                    # paste the ContentDB token
avanti secrets push cultom/hammermod    # environment "contentdb" with required approval
```

