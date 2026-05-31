class i2cmb_environment extends ncsu_component;
  `ncsu_register_object(i2cmb_environment)

  i2cmb_env_configuration  configuration;
  wb_agent         wb_agent_inst;
  i2c_agent        i2c_agent_inst;
  i2cmb_predictor  pred;
  i2cmb_scoreboard scbd;
  i2cmb_coverage   cov;    

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name, parent);
  endfunction

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void build();
    wb_agent_inst = new("wb_agent_inst", this);
    wb_agent_inst.set_configuration(configuration.wb_agent_config);
    wb_agent_inst.build();

    i2c_agent_inst = new("i2c_agent_inst", this);
    i2c_agent_inst.set_configuration(configuration.i2c_agent_config);
    i2c_agent_inst.build();

    scbd = new("scbd", this);

    pred = new("pred", this);
    pred.set_configuration(configuration);
    pred.set_scoreboard(scbd);

    cov = new("cov", this);
    cov.set_configuration(configuration);

    wb_agent_inst.predictor = pred;

    i2c_agent_inst.scoreboard = scbd;

    scbd.set_coverage(cov);

  endfunction

  function wb_agent get_wb_agent();
    return wb_agent_inst;
  endfunction

  function i2c_agent get_i2c_agent();
    return i2c_agent_inst;
  endfunction

  virtual task run();
    fork
      wb_agent_inst.run();
      i2c_agent_inst.run();
    join_none
  endtask

  virtual function void report();
    scbd.report();
  endfunction

endclass
