{
  description = "My Nix Flake templates";

  outputs = {self} : {
    templates = let
      mkTemplate = path: description: {
        inherit path description;
      };
    in {
      # default template
      default = self.templates.project;

      # list of templates
      project = mkTemplate ./templates/project "Project / A Nix Flake template for a generic project";
      python-poetry = mkTemplate ./templates/python-poetry "Python Poetry / A Nix Flake template for Python projects backed by Poetry";
      python-setuptools = mkTemplate ./templates/python-setuptools "Python Setuptools / A Nix Flake template for Python projects backed by Setuptools";
    };
  };
}
