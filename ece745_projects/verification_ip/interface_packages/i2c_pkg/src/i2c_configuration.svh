class i2c_configuration extends ncsu_configuration;
`ncsu_register_object(i2c_configuration)
  virtual i2c_if bus;

  function new(string name="");
    super.new(name);
  endfunction

  virtual function string convert2string();
     return {super.convert2string};
  endfunction

endclass
