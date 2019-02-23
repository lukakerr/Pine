# How To Create A Release

Let `x.x.x` represent the version number.

1. In Xcode select the Twig project from the sidebar
2. Under the 'General' tab, bump the version number
3. Create a git commit titled 'Bump version to x.x.x' and push to remote
4. From the menubar select Product > Archive
5. From the popup window select 'Distribute App'
6. Select 'Copy App' and click next
7. Save to a location
8. Compress Twig.app into a .zip file named Twig-x.x.x.zip
9. In GitHub draft a new release
  - Tag version: `x.x.x`
  - Release title: `Twig x.x.x`
  - Describe this release:
    ```
    Twig version x.x.x.

    New features:

    - ...

    Fixes:

    - ...

    Other:

    - ...
    ```
  - Upload Twig.x.x.x.zip
10. Click 'Publish release'
11. Download the Twig.x.x.x.zip from the newly created release
12. Open `lukakerr/homebrew-casks` repository
13. Create a new branch if one already doesn't exist
14. Run `shasum -a 256  ~/Downloads/Twig-x.x.x.zip` and copy the SHA-256 checksum
15. Run `open Casks/twig.rb` and update the cask with the new version and checksum
16. Create a git commit with the message `Update Twig to x.x.x` and push to remote
