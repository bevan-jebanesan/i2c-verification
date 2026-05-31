class i2c_driver extends ncsu_component#(.T(i2c_transaction));
`ncsu_register_object(i2c_driver)

  virtual i2c_if bus;
  i2c_configuration configuration;
  ncsu_component#(i2c_transaction) agent;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name, parent);
  endfunction

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  virtual task bl_put(T trans);
    bit op;               
    bit [7:0] write_data[];
    bit transfer_complete;

    if (trans.op == i2c_pkg::write) begin
      bus.wait_for_i2c_transfer(op, write_data);
    end else begin
      bus.provide_read_data(trans.data, transfer_complete);
    end
  endtask

endclass
