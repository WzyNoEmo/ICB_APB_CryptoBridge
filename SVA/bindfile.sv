module binding_module();

    bind dut_top icb_assertion icb_assertion_bind_dut_top
    (
        .icb(           icb.monitor      )
    );

    bind dut_top apb_assertion #(.channel_id(0)) apb0_assertion_bind_dut_top
    (
        .apb(           apb0.monitor     )
    );

    bind dut_top apb_assertion #(.channel_id(1)) apb1_assertion_bind_dut_top
    (
        .apb(           apb1.monitor     )
    );

    bind dut_top apb_assertion #(.channel_id(2)) apb2_assertion_bind_dut_top
    (
        .apb(           apb2.monitor     )
    );

    bind dut_top apb_assertion #(.channel_id(3)) apb3_assertion_bind_dut_top
    (
        .apb(           apb3.monitor     )
    );


    // fifo type : 0 RFIFO 1 WFIFO

    bind dut_top fifo_assertion #(.fifo_type(0)) rfifo_assertion_bind_dut_top
    (
        .rclk(           i_dut.u_rfifo.rclk      ),
        .wclk(           i_dut.u_rfifo.wclk      ),
        .rst_n(          i_dut.u_rfifo.rst_n     ),
        .empty(         i_dut.u_rfifo.empty     ),
        .full(          i_dut.u_rfifo.full      ),
        .wptr(          i_dut.u_rfifo.wptr      ),
        .rptr(          i_dut.u_rfifo.rptr      ),
        .wptr_gray(     i_dut.u_rfifo.wptr_gray ),
        .rptr_gray(     i_dut.u_rfifo.rptr_gray ),
        .wptr_gray_sync1( i_dut.u_rfifo.wptr_gray_sync1 ),
        .wptr_gray_sync2( i_dut.u_rfifo.wptr_gray_sync2 ),
        .rptr_gray_sync1( i_dut.u_rfifo.rptr_gray_sync1 ),
        .rptr_gray_sync2( i_dut.u_rfifo.rptr_gray_sync2 ),
        .rdata_en(      i_dut.u_rfifo.rdata_en  ),
        .wdata_vld(     i_dut.u_rfifo.wdata_vld )
    );

    bind dut_top fifo_assertion #(.fifo_type(1)) wfifo_assertion_bind_dut_top
    (
        .rclk(           i_dut.u_wfifo.rclk      ),
        .wclk(           i_dut.u_wfifo.wclk      ),
        .rst_n(          i_dut.u_wfifo.rst_n     ),
        .empty(         i_dut.u_wfifo.empty     ),
        .full(          i_dut.u_wfifo.full      ),
        .wptr(          i_dut.u_wfifo.wptr      ),
        .rptr(          i_dut.u_wfifo.rptr      ),
        .wptr_gray(     i_dut.u_wfifo.wptr_gray ),
        .rptr_gray(     i_dut.u_wfifo.rptr_gray ),
        .wptr_gray_sync1( i_dut.u_wfifo.wptr_gray_sync1 ),
        .wptr_gray_sync2( i_dut.u_wfifo.wptr_gray_sync2 ),
        .rptr_gray_sync1( i_dut.u_wfifo.rptr_gray_sync1 ),
        .rptr_gray_sync2( i_dut.u_wfifo.rptr_gray_sync2 ),
        .rdata_en(      i_dut.u_wfifo.rdata_en  ),
        .wdata_vld(     i_dut.u_wfifo.wdata_vld )
    );

endmodule