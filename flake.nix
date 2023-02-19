{
  description = "my setup for data projects";

  outputs = self: rec {

    templates = {
      def = {
        path = ./def;
        description = "default template";
      };

      with_stan = {
        path = ./with_stan;
        description = "default template with cmdstan, cmdstanr";
      };
    };

    defaultTemplate = templates.def;

  };
}
