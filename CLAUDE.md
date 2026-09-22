# CLAUDE.md

## Project overview
CHRGD marketing site — a static, multi-page marketing/landing site for the CHRGD EV charging network.
No build step, no framework, no package manager. Plain HTML/CSS/JS served as-is.

## Tech stack
- HTML5 (one file per page, at repo root)
- CSS: single stylesheet `style.css` (hand-written, no preprocessor)
- JS: single `script.js` (vanilla, mobile nav toggle)
- Hosting: Firebase Hosting — project `chrgd-8c18f`, site `chrgd-8c18f` (https://chrgd-8c18f.web.app)
- Custom domain of record: `chrgd.org` (see `CNAME`; DNS currently points outside Firebase)

## Layout
```
index.html             # home
about.html             # company
stations.html          # network / locations
how-to-charge.html     # usage guide
pricing.html           # tariffs
app.html               # mobile app
investors.html         # investor relations
contact.html
privacy-policy.html
terms-of-service.html
style.css              # all styles
script.js              # all scripts
logo.png
images/                # photography (jpg)
firebase.json          # hosting config (public: ".", ignore list, cache headers)
.firebaserc            # default project: chrgd-8c18f
server.ps1             # local static server (Windows/PowerShell), not deployed
CNAME                  # custom domain record, not deployed
```

## Commands
```bash
# Local preview (any of these)
python3 -m http.server 8000          # then open http://localhost:8000
firebase serve --only hosting        # serves with the real hosting config
pwsh ./server.ps1                    # Windows helper

# Deploy to production
firebase deploy --only hosting --project chrgd-8c18f

# Preview channel (temporary URL, expires in 7 days)
firebase hosting:channel:deploy preview --project chrgd-8c18f
```
There is no build, test, or codegen step. What is in the repo is what ships.
Pushing to `main` deploys automatically — see "Deploys (CI)" below.

## Deploys (CI)
Pushing to `main` triggers `.github/workflows/firebase-hosting-deploy.yml`, which deploys the
repo contents to the live channel and then smoke-checks the published URLs. No build runs in CI.

- Auth: repo secret `FIREBASE_SERVICE_ACCOUNT_CHRGD_8C18F` holding a Firebase service account
  JSON key. Created by `firebase init hosting:github` (it also writes the secret to GitHub).
- Only `main` deploys. Other branches and PRs do not publish.
- Manual re-run: Actions tab -> "Deploy to Firebase Hosting" -> Run workflow.
- Deploying by hand from a laptop still works and is the fallback if CI auth breaks:
  `firebase deploy --only hosting --project chrgd-8c18f`

## Hosting rules
- `firebase.json` deploys the repo root (`public: "."`). Anything added to the root is public
  unless it is in the `ignore` array — always add non-public files there (`.git/**` is already
  excluded; verify after adding new tooling or config files).
- URLs keep their `.html` extension (`cleanUrls: false`) because every internal link in the
  site is written as `href="page.html"`. Do not enable `cleanUrls` without rewriting all links.
- Cache headers: images 7 days, css/js 1 day, html 5 minutes. Bump asset filenames if a
  cached CSS/JS change must land immediately.

## Code conventions
- One page = one root-level `.html` file. Add new pages at the root, not in subfolders.
- Header and footer markup is duplicated per page (no templating). When changing nav or
  footer links, update **every** `.html` file — grep for the link you are changing.
- All styling goes in `style.css`; no inline `style=` attributes, no per-page `<style>` blocks.
- All scripting goes in `script.js`; no inline `onclick` handlers.
- Relative paths only (`style.css`, `images/foo.jpg`) — never absolute `/…` or full URLs to self.
- Images live in `images/` as `kebab-case.jpg`; keep them web-sized before committing.
- Every page needs `<title>`, `<meta name="description">`, and the shared nav/footer.

## Verifying a deploy
After deploying, spot-check the live pages and confirm nothing private is exposed:
```bash
for p in / /about.html /investors.html /.git/config; do
  printf "%-20s %s\n" "$p" "$(curl -s -o /dev/null -w '%{http_code}' https://chrgd-8c18f.web.app$p)"
done
```
Pages should return 200; `/.git/config` and other internals must return 404.
