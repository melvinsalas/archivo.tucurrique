# archivo.tucurrique

Static site built with Jekyll and deployed to GitHub Pages.

This repository vendors the Mozilla PDF.js web viewer to render PDFs with a full-featured UI in the `minute` layout.

## Requirements

- Docker Desktop 4.x or compatible
- Docker Compose (`docker compose`) or the classic `docker-compose`
- Alternatively, a local Ruby toolchain if you prefer to run without Docker

## Run Locally (Docker)

1. Open a terminal in the repository root.
2. Start the stack: `docker compose up` (or `docker-compose up`). The first run will take longer as gems are installed into the `bundle` volume.
3. Visit <http://localhost:4000>. Livereload is exposed on port 35729.
4. Press `Ctrl+C` to stop.

The container uses a Linux environment similar to GitHub Pages, so CI remains unchanged; Docker is only for local development.

If you update gems (e.g., `bundle update`), restart the container; changes persist in the `bundle` volume.

## Run Locally (Ruby)

1. Install dependencies: `bundle install`
2. Serve with auto-setup of PDF.js: `bundle exec rake serve`

## PDF.js Viewer

- The official Mozilla PDF.js viewer is vendored under `assets/vendor/pdfjs/` and used by the `minute` layout via an iframe.
- Installation/updates are automated with Rake tasks:
  - `bundle exec rake serve` ensures PDF.js is present, then runs Jekyll.
  - `bundle exec rake build` ensures PDF.js is present, then builds the site.
- Desired version is controlled by `.pdfjs-version`:
  - Set to a specific version like `3.11.174`, or use `latest` to fetch the newest release from GitHub.

## GitHub Pages CI (Actions)

This repository includes `.github/workflows/pages.yml` to build and deploy with GitHub Actions:

- Runs on push to `main`/`master` or via manual dispatch.
- Sets up Ruby and dependencies, runs `bundle exec rake build` (downloads PDF.js if needed), and deploys `_site` to GitHub Pages.
- In Settings → Pages, select “GitHub Actions” as the source.
