kind: import
sources:
- kind: ostree
  url: https://flathub.org/repo/
  track: runtime/org.kde.Sdk/%{arch}/6.9
  ref: 742d4371cca387a7bb7a2e12c02303a9f5f84d7779d00e6fb683b621516833c0
config:
  source: /files
  target: /usr
runtime-depends:
- symlinks.bst
