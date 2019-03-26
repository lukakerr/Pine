# How To Create A Release

Let `x.x.x` represent the version number.

1. Run `make PINE_VERSION=x.x.x tag` to bump the version
2. Create a git commit titled 'Bump version to x.x.x' and push to remote
3. Run `make release`
4. Compress Pine.app into a .zip file named Pine-x.x.x.zip
5. In GitHub draft a new release
  - Tag version: `x.x.x`
  - Release title: `Pine x.x.x`
  - Describe this release:
    ```
    Pine version x.x.x.

    New features:

    - ...

    Fixes:

    - ...

    Other:

    - ...
    ```
  - Upload Pine.x.x.x.zip
6. Click 'Publish release'
7. Open `lukakerr/homebrew-things` repository
8. Run `shasum -a 256  /path/to/Pine-x.x.x.zip` (using the correct path) and copy the SHA-256 checksum
9. Run `open Casks/pine.rb` and update the cask with the new version and checksum
10. Create a git commit with the message `Update Pine to x.x.x` and push to remote
