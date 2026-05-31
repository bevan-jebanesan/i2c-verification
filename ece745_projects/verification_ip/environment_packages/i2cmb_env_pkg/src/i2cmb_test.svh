class i2cmb_test extends ncsu_component;
  `ncsu_register_object(i2cmb_test)

  i2cmb_env_configuration  cfg;
  i2cmb_generator          gen;
  i2cmb_environment        env;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name, parent);
    cfg = new("cfg");
    env = new("env", this);
    env.set_configuration(cfg);
    gen = new("gen", this);
    gen.set_configuration(cfg);
  endfunction

  virtual function void build();
    env.build();
    gen.set_wb_agent(env.get_wb_agent());
    gen.set_i2c_agent(env.get_i2c_agent());
  endfunction

endclass
