kind: import
sources:
- kind: ostree
  url: https://dl.flathub.org/repo/
  track: runtime/org.kde.Platform/%{arch}/6.9
  ref: 76413ad56178752c98dbda74682640d85a2b10b0d37f6f3680b29adf00265a6b
config:
  source: /files
  target: /usr
runtime-depends:
- symlinks.bst
