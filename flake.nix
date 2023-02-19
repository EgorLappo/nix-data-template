{
  description = "my setup for data projects";

  outputs = { self }: {

    templates = {
      default = {
        path = ./default;
        description = "default template";
      };

      with_stan = {
        path = ./with_stan;
        description = "default template with cmdstan, cmdstanr";
      };
    };

    defaultTemplate = self.templates.default;

  };
}
