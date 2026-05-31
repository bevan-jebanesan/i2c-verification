class wb_driver extends ncsu_component#(.T(wb_transaction));
`ncsu_register_object(wb_driver)

  function new(string name = "", ncsu_component_base  parent = null);
    super.new(name,parent);
  endfunction

  virtual wb_if bus;
  wb_configuration configuration;
  wb_transaction wb_trans;

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  virtual task bl_put(T trans);
    if (bus == null) $display("DRIVER BUS IS NULL!");
    
    if (trans.we)
      bus.master_write(trans.addr, trans.data);
    else begin
      bit [7:0] rdata;
      bus.master_read(trans.addr, rdata);
      trans.data = rdata;
    end
  endtask

endclass
