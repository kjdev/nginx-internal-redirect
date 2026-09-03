# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.2.1] - 2026-09-04

### Fixed

- GitHub's auto-generated release archives (source tarball/zip) exclude
  submodules, so the `nxe-phase` submodule (used for shared PREACCESS
  phase ordering) was missing from the 0.2.0 release archives, breaking a
  build from that source. CI now also uploads a full source archive
  (submodules included) as a release asset.

## [0.2.0] - 2026-09-03

### Fixed

- Handler execution order within `NGX_HTTP_PRECONTENT_PHASE` no longer
  depends on `load_module` order for handlers registered through the
  shared `nxe-phase` submodule; the module now registers via `nxe-phase`
  at a fixed priority so it always runs after other `nxe-phase`-registered
  authorization handlers (e.g. auth-gate, auth-cedar, auth-rbac) in the
  same phase. Handlers registered directly with
  `NGX_HTTP_PRECONTENT_PHASE` (bypassing `nxe-phase`) are unaffected and
  remain subject to `load_module` order

## [0.1.1] - 2026-03-31

### Changed

- Refactor module source to follow nginx coding style

## [0.1.0] - 2024-11-19

### Added

- Initial implementation of the internal redirect module
- `internal_redirect` directive (regular location / named location)
- Dynamic redirect target using nginx variables
- Conditional redirect via empty string
