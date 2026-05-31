class i2cmb_scoreboard extends ncsu_component#(.T(i2c_transaction));
  `ncsu_register_object(i2cmb_scoreboard)

  i2c_transaction  predicted_q[$];
  i2cmb_coverage   cov;          
  int match_count    = 0;
  int mismatch_count = 0;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name, parent);
  endfunction

  function void set_coverage(i2cmb_coverage c);
    this.cov = c;
  endfunction

  function void predict(i2c_transaction trans);
    predicted_q.push_back(trans);
  endfunction

  virtual function void nb_put(T trans);
    i2c_transaction predicted;
    bit match;
    bit [7:0] actual_data;
    bit [7:0] pred_data;

    if (cov != null) cov.nb_put(trans);

    actual_data = (trans.data.size() > 0) ? trans.data[0] : 8'h00;

    if (predicted_q.size() == 0) begin
      $display("SCOREBOARD MISMATCH: no prediction for actual op:%s addr:0x%02x data:%0d",
               trans.op.name(), trans.addr, actual_data);
      mismatch_count++;
      return;
    end

    predicted = predicted_q.pop_front();
    pred_data = (predicted.data.size() > 0) ? predicted.data[0] : 8'h00;

    if (predicted.op == i2c_pkg::write)
      $display("EXPECTED: I2C_BUS WRITE Transfer: address=0x%0h data=%0d",
               predicted.addr, pred_data);
    else
      $display("EXPECTED: I2C_BUS READ Transfer:  address=0x%0h data=%0d",
               predicted.addr, actual_data);

    if (trans.op == i2c_pkg::write)
      $display("ACTUAL:   I2C_BUS WRITE Transfer: address=0x%0h data=%0d",
               trans.addr, actual_data);
    else
      $display("ACTUAL:   I2C_BUS READ Transfer:  address=0x%0h data=%0d",
               trans.addr, actual_data);

    if (trans.op == i2c_pkg::write)
      match = (trans.addr == predicted.addr &&
               trans.op   == predicted.op   &&
               actual_data == pred_data);
    else
      match = (trans.addr == predicted.addr &&
               trans.op   == predicted.op);

    if (match) begin
      $display("RESULT:   MATCH");
      match_count++;
    end else begin
      $display("RESULT:   MISMATCH");
      mismatch_count++;
    end
  endfunction

  function void report();
    $display("------------------------------------------------------");
    $display("SCOREBOARD SUMMARY: %0d MATCHES  %0d MISMATCHES",
             match_count, mismatch_count);
    $display("------------------------------------------------------");
  endfunction

endclass
