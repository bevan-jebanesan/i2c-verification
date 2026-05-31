class wb_configuration extends ncsu_configuration;
  `ncsu_register_object(wb_configuration)
virtual wb_if bus;

  function new(string name="");
    super.new(name);
  endfunction

  virtual function string convert2string();
     return {super.convert2string};
  endfunction

endclass
