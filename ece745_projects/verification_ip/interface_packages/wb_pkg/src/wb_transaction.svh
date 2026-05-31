class wb_transaction extends ncsu_transaction;
  `ncsu_register_object(wb_transaction)
      bit [1:0] addr;
      bit [7:0] data; 
      bit we;

  function new(string name="");
    super.new(name);
  endfunction

  virtual function string convert2string();
     return {super.convert2string(),$sformatf("addr:0x%x data:0x%x we:0x%x", addr, data, we)};
  endfunction

  function bit compare(wb_transaction rhs);
    return ((this.addr  == rhs.addr ) &&
            (this.data == rhs.data) &&
            (this.we == rhs.we) );
  endfunction

  virtual function void add_to_wave(int transaction_viewing_stream_h);
     super.add_to_wave(transaction_viewing_stream_h);
     $add_attribute(transaction_view_h,addr,"addr");
     $add_attribute(transaction_view_h,data,"data");
     $add_attribute(transaction_view_h,we,"we");
     $end_transaction(transaction_view_h,end_time);
     $free_transaction(transaction_view_h);
  endfunction

endclass
