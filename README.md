# Slate Documenation Builder Action
GitHub action to build repositories Markdown files using the [slate framework](https://github.com/lord/slate)

## Getting Started
The docker image can be used to locally build your markdown files. For this you need, first of all, to build the docker image:

```bash
docker build -t decathlon/slate-builder .
```

Once built run the container using the following command:

```bash
docker run -it --rm -v <md files folder>:/usr/src/doc decathlon/slate-builder
```

The slate build result will be store in the build subdir of `<md files folder>`.

## Using as GitHub Action
To automate the documentation build for your GitHub projects, this builder is also released as [GitHub Action](https://github.com/features/actions).
All you have to do is to create a `main.workflow` in your repository, linking this actions.

```
workflow "Create Slate Documentation On Push" {
  on = "push"
  resolves = ["Build Documentation"]
}

action "Build Documentation" {
  uses = "decathlon/slate-builder-action@master"
  env = {
     DOC_BASE_FOLDER = "."
  }
}
```

The `DOC_BASE_FOLDER` environement variable is the path, in your GitHub repository, containing the Markdown files you want to build as Slate website.

### Advanced configuration
You can override the default Slate template, providing a repository containing your custom slate template.

```
workflow "Create Slate Documentation On Push" {
  on = "push"
  resolves = ["Build Documentation"]
}

action "Build Documentation" {
  uses = "decathlon/slate-builder-action@master"
  secrets = [
    "GH_PAT"
  ]
  env = {
     DOC_BASE_FOLDER = "."
     TEMPLATE_REPO = "decathlon/custom-slate"
  }
}
```

The `GT_PAT` secrets variable contains the [Private Access Token](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line). This secret is mandatory if you want to access to a private repository but you can leave it empty if the template you want to use is opensource.

## Get the Result
The result is built into `DOC_BASE_FOLDER/build` folder. You have to chain this action with one taking care about deployment, delivery, or whatever you want to do with your built documentation.
To simplify the export, the result is zipped into `DOC_BASE_FOLDER/documentation.zip`. You can disable the zipping function providing `ZIP_BUILD=false` as environment variable.

```
workflow "Create Slate Documentation On Push" {
  on = "push"
  resolves = ["Build Documentation"]
}

action "Build Documentation" {
  uses = "decathlon/slate-builder-action@master"
  secrets = [
    "GH_PAT",
  ]
  env = {
     DOC_BASE_FOLDER = "."
     ZIP_BUILD = "false"
  }
}
```

## Complete Workflow Example

Ih this example the workflow is started if we are on the `master` branch and an `md` file is delivered. In this case:
* the documention is built
* the new version is deployed as GitHub Pages

```
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
```
