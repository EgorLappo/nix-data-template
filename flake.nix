{
  description = "my setup for data projects";

  outputs = self: rec {

    templates = {
      def = {
        path = ./def;
        description = "default template";
      };

      with_cmdstan = {
        path = ./with_cmdstan;
        description = "default template with cmdstan, cmdstanr";
      };
      
      with_rstan = {
        path = ./with_rstan;
        description = "default template with rstan";
      };
    };

    defaultTemplate = templates.def;

  };
}
