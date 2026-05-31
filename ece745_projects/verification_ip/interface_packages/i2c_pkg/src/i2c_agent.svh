class i2c_agent extends ncsu_component#(.T(i2c_transaction));
`ncsu_register_object(i2c_agent)
  i2c_configuration configuration;
  i2c_driver        driver;
  i2c_monitor       monitor;
  virtual i2c_if    bus;
  ncsu_component#(i2c_transaction) scoreboard;
  function new(string name = "", ncsu_component_base  parent = null);
    super.new(name,parent);
    if ( !(ncsu_config_db#(virtual i2c_if)::get(get_full_name(), this.bus))) begin
      $display("i2c_agent::ncsu_config_db::get() call for BFM handle failed for name: %s ",get_full_name());
      $finish;
    end
  endfunction
  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction
  virtual function void build();
    driver = new("driver",this);
    driver.set_configuration(configuration);
    driver.build();
    driver.bus = this.bus;
    driver.agent = this;
    monitor = new("monitor",this);
    monitor.set_configuration(configuration);
    monitor.set_agent(this);
    monitor.enable_transaction_viewing = 1;
    monitor.build();
    monitor.bus = this.bus;
  endfunction
  virtual function void nb_put(T trans);
    if (scoreboard != null) scoreboard.nb_put(trans);
  endfunction
  virtual task bl_put(T trans);
    driver.bl_put(trans);
  endtask
  virtual task run();
    fork monitor.run(); join_none
  endtask
endclass
