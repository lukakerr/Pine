# How To Create A Release

Let `x.x.x` represent the version number.

1. In Xcode select the Pine project from the sidebar
2. Under the 'General' tab, bump the version number
3. Create a git commit titled 'Bump version to x.x.x' and push to remote
4. Run `make release`
5. Compress Pine.app into a .zip file named Pine-x.x.x.zip
6. In GitHub draft a new release
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
7. Click 'Publish release'
8. Download the Pine.x.x.x.zip from the newly created release
9. Open `lukakerr/homebrew-casks` repository
10. Create a new branch if one already doesn't exist
11. Run `shasum -a 256  ~/Downloads/Pine-x.x.x.zip` and copy the SHA-256 checksum
12. Run `open Casks/pine.rb` and update the cask with the new version and checksum
13. Create a git commit with the message `Update Pine to x.x.x` and push to remote
