# Templates

This repository holds my Nix templates.

## Description

Inside `templates/` folder you'll find a list of different templates. To briefly describe them:

- `blog`: Templates related to my blog articles (will be deprecated soon).
- `project`: The starter kit of all of my projects.

## How to use

If you want to clone one of my templates, just run the following on your terminal:

```console
$ nix flake init -t github:aldoborrero/templates#project /path/to/your/project
```

You can also add an alias to my flake:

```console
$ nix registry add templates-aldo github:aldoborrero/templates
```

## License

See [LICENSE](./LICENSE) for more information.
