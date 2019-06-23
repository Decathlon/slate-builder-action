workflow "Deploy Documentation - Master Branch" {
  on = "push"
  resolves = ["Deploy documentation to GitHub Pages"]
}

action "filter master branch" {
  uses = "juankaram/regex-filter@master"
  args = ["refs/heads/master"]
}

action "files filter" {
  uses = "wcchristian/gh-pattern-filter-action@master"
  args = ".*\\.md$"
  needs = "filter master branch"
}

action "Slate Documentation builder" {
  uses = "./"
  needs = "files filter"
  env = {
     DOC_BASE_FOLDER = "test-documentation"
  }
  secrets = ["GH_PAT"]
}

action "Deploy documentation to GitHub Pages" {
  uses = "maxheld83/ghpages@v0.2.1"
  needs = "Slate Documentation builder"
  env = {
    BUILD_DIR = "test-documentation/build/"
  }
  secrets = ["GH_PAT"]
}

