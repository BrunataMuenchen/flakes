{
  description = "A collection of nix flake templates create by Brunata";

  outputs = { self }: {
    templates = {
      devshell-c = {
        path = ./templates/devshell-c;
        description = "A devshell with some useful C tools set up.";
      };
    defaultTemplate = self.templates.devshell-c;
  };
}