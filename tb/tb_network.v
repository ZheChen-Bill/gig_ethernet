`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/10 15:35:12
// Design Name: 
// Module Name: test_networkCentCtrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_network(

    );    
    wire [7:0]     gmii_rxd;              // Received Data to client MAC.d
    wire           gmii_rx_dv;            // Received control signal to client MAC.
    wire           gmii_rx_er;
    
    wire [7:0] gmii_txd;
    wire gmii_tx_en;
    wire gmii_tx_er;
    
    reg [7:0] gmii_txd_error;
    
    reg link_status;
    reg clk_PP;
    reg clk_GMII;
    wire clkTX_msg;
    wire clkRX_msg;
    
    reg clock_100M;
    reg reset;
    
// clk_PP = 380MHz
//    parameter freq_PP = 380000000;
    parameter freq_PP = 125000000;
    parameter period = 1/freq_PP;
    initial begin 
        clk_PP = 1'b0; 
        forever begin 
//            #(1.315) clk_PP = 1'b1;
//            #(1.315) clk_PP = 1'b0;
            #(1.33334) clk_PP = 1'b1;
            #(1.33334) clk_PP = 1'b0;
        end 
    end 


    // clk_GMII = 125MHz
    initial begin 
        clk_GMII = 1'b0; 
        forever begin 
            #4 clk_GMII = 1'b1;
            #4 clk_GMII = 1'b0;
        end 
    end 
    
    // clk_100M = 100MHz
    initial begin 
        clock_100M = 1'b0; 
        forever begin 
            #5 clock_100M = 1'b1;
            #5 clock_100M = 1'b0;
        end 
    end
    
    initial begin 
        reset = 1'b0;
        #5 reset = 1'b1;
        #5 reset = 1'b0;
    end 
         
    initial begin  
        link_status = 1'b1;
    end
    
    initial begin
        B_output_next_pb = 1'b0;
        #6000;
        @(posedge clk_PP) B_output_next_pb = 1'b1;
        #100;
        B_output_next_pb = 1'b0;
    end
    
    initial begin
        gmii_txd_error = 8'd0;
        #60000;
        @(posedge clk_GMII);
        @(posedge clk_GMII) gmii_txd_error = 8'd1;
        @(posedge clk_GMII) gmii_txd_error = 8'd0;
    end 
    
    wire B_busy_PP2Net_TX;                   // BRAMMsgTX is used by PP
    wire B_busy_Net2PP_TX;                  // BRAMMsgTX is used by NetworkCentCtrl
    wire B_msg_stored;                       // msg is stored in BRAMMsgTX by PP 
    
    wire B_busy_PP2Net_RX;                   // BRAMMsgRX is used by PP
    wire B_busy_Net2PP_RX;                  // BRAMMsgRX is used by networkCentCtrl
    wire B_msg_accessed_en_FrameSniffer;
    wire B_msg_accessed;                    // msg is stored in BRAMMsgTX by networkCentCtrl
    
    wire [31:0] B_dataTX_msg;                // message from PP 
    wire [10:0] B_addrTX_msg;               // addr for BRAMMsgTX
    wire [10:0] B_sizeTX_msg;                // transmitting message size
    
    wire [31:0] B_dataRX_msg;               // message pasrsed from Ethernet frame
    wire B_weRX_msg;                        // write enable for BRAMMsgRX
    wire [10:0] B_addrRX_msg;               // addr for BRAMMSGRX
    wire [10:0] B_sizeRX_msg;               // receoved message size
    reg   B_output_next_pb;
    wire B_new_one_pulse;
    
    networkCentCtrl_B #(
        .lost_cycle(26'd30),
        .phy_reset_wait(26'd20)
    ) Unetwork_Bob(
        .reset(reset),                 // system reset
        .clock_100M(clock_100M),            // clock for JTAG module 
        .clk_PP(clk_PP),
        .clkTX_msg(clkTX_msg),                // clock for accessing BRAMMsgTX
        .clkRX_msg(clkRX_msg),                // clock for accessing BRAMMsgRX
    
        // Post Processing interface
        //------------------------------------
        .busy_PP2Net_TX(B_busy_PP2Net_TX),                   // BRAMMsgTX is used by PP
        .busy_Net2PP_TX(B_busy_Net2PP_TX),                  // BRAMMsgTX is used by NetworkCentCtrl
        .msg_stored(B_msg_stored),                       // msg is stored in BRAMMsgTX by PP 
        
        .busy_PP2Net_RX(B_busy_PP2Net_RX),                   // BRAMMsgRX is used by PP
        .busy_Net2PP_RX(B_busy_Net2PP_RX),                  // BRAMMsgRX is used by networkCentCtrl
        .msg_accessed(B_msg_accessed),                    // msg is stored in BRAMMsgTX by networkCentCtrl
    
        .dataTX_msg(B_dataTX_msg),                // message from PP 
        .addrTX_msg(B_addrTX_msg),               // addr for BRAMMsgTX
        .sizeTX_msg(B_sizeTX_msg),                // transmitting message size
        
        .dataRX_msg(B_dataRX_msg),               // message pasrsed from Ethernet frame
        .weRX_msg(B_weRX_msg),                        // write enable for BRAMMsgRX
        .addrRX_msg(B_addrRX_msg),               // addr for BRAMMSGRX
        .sizeRX_msg(B_sizeRX_msg),               // receoved message size
         
        // GMII Interface (client MAC <=> PCS)
        //------------------------------------
        .gmii_tx_clk(clk_GMII),           // Transmit clock from client MAC.
        .gmii_rx_clk(clk_GMII),           // Receive clock to client MAC.
        .link_status(link_status),           // Link status: use status_vector[0]
        .gmii_txd(gmii_txd),              // Transmit data from client MAC.
        .gmii_tx_en(gmii_tx_en),            // Transmit control signal from client MAC.
        .gmii_tx_er(gmii_tx_er),            // Transmit control signal from client MAC.
        .gmii_rxd(gmii_rxd),              // Received Data to client MAC.
        .gmii_rx_dv(gmii_rx_dv),            // Received control signal to client MAC.
        .gmii_rx_er(gmii_rx_er)            // Received control signal to client MAC.
    );
    
    postProcessing UPP_B(
    .reset(reset),
    .clock_100M(clock_100M),
    .clkTX_msg(clkTX_msg),
    .clkRX_msg(clkRX_msg),
    // Test different size 
    .independent_clk_en(1'b1),
    .io_refclk_en(1'b0),
    .gmii_rx_clk_en(1'b0),
     // Post Processing interface
    //------------------------------------
    .busy_PP2Net_TX(B_busy_PP2Net_TX),                   // BRAMMsgTX is used by PP
    .busy_Net2PP_TX(B_busy_Net2PP_TX),                  // BRAMMsgTX is used by NetworkCentCtrl
    .msg_stored(B_msg_stored),                       // msg is stored in BRAMMsgTX by PP 
    
    .busy_PP2Net_RX(B_busy_PP2Net_RX),                   // BRAMMsgRX is used by PP
    .busy_Net2PP_RX(B_busy_Net2PP_RX),                  // BRAMMsgRX is used by networkCentCtrl
    .msg_accessed(B_msg_accessed),                    // msg is stored in BRAMMsgTX by networkCentCtrl
    
    .dataTX_msg(B_dataTX_msg),                // message from PP 
    .addrTX_msg(B_addrTX_msg),               // addr for BRAMMsgTX
    .sizeTX_msg(B_sizeTX_msg),                // transmitting message size
    
    .dataRX_msg(B_dataRX_msg),               // message pasrsed from Ethernet frame
    .weRX_msg(B_weRX_msg),                        // write enable for BRAMMsgRX
    .addrRX_msg(B_addrRX_msg),               // addr for BRAMMSGRX
    .sizeRX_msg(B_sizeRX_msg),               // receoved message size
    .new_one_pulse(B_new_one_pulse)
    );
    
    pushButton Upb_B(
        .clk(clkTX_msg),
        .reset(reset),
//        .pb(output_next_pb),
        .pb((B_output_next_pb|B_next_pb)), //for continuous transportation
        .one_pulse(B_new_one_pulse)
    );
    reg B_next_pb;
    always @(posedge clk_PP or posedge reset) begin
        if (reset) begin
            B_next_pb <= 1'b0;
        end else begin
            if (B_msg_accessed) begin
                B_next_pb <= 1'b1;
            end else if (B_new_one_pulse) begin
                B_next_pb <= 1'b0;
            end else begin
                B_next_pb <= B_next_pb;
            end
        end
    end
    wire A_busy_PP2Net_TX;                   // BRAMMsgTX is used by PP
    wire A_busy_Net2PP_TX;                  // BRAMMsgTX is used by NetworkCentCtrl
    wire A_msg_stored;                       // msg is stored in BRAMMsgTX by PP 
    
    wire A_busy_PP2Net_RX;                   // BRAMMsgRX is used by PP
    wire A_busy_Net2PP_RX;                  // BRAMMsgRX is used by networkCentCtrl
    wire A_msg_accessed_en_FrameSniffer;
    wire A_msg_accessed;                    // msg is stored in BRAMMsgTX by networkCentCtrl
    
    wire [31:0] A_dataTX_msg;                // message from PP 
    wire [10:0] A_addrTX_msg;               // addr for BRAMMsgTX
    wire [10:0] A_sizeTX_msg;                // transmitting message size
    
    wire [31:0] A_dataRX_msg;               // message pasrsed from Ethernet frame
    wire A_weRX_msg;                        // write enable for BRAMMsgRX
    wire [10:0] A_addrRX_msg;               // addr for BRAMMSGRX
    wire [10:0] A_sizeRX_msg;               // receoved message size
    reg A_output_next_pb;
    wire A_new_one_pulse;
    networkCentCtrl_A #(
        .lost_cycle(26'd30),
        .phy_reset_wait(26'd20)
    ) Unetwork_Alice(
        .reset(reset),                 // system reset
        .clock_100M(clock_100M),            // clock for JTAG module 
        .clk_PP(clk_PP),
        .clkTX_msg(clkTX_msg),                // clock for accessing BRAMMsgTX
        .clkRX_msg(clkRX_msg),                // clock for accessing BRAMMsgRX
    
        // Post Processing interface
        //------------------------------------
        .busy_PP2Net_TX(A_busy_PP2Net_TX),                   // BRAMMsgTX is used by PP
        .busy_Net2PP_TX(A_busy_Net2PP_TX),                  // BRAMMsgTX is used by NetworkCentCtrl
        .msg_stored(A_msg_stored),                       // msg is stored in BRAMMsgTX by PP 
        
        .busy_PP2Net_RX(A_busy_PP2Net_RX),                   // BRAMMsgRX is used by PP
        .busy_Net2PP_RX(A_busy_Net2PP_RX),                  // BRAMMsgRX is used by networkCentCtrl
        .msg_accessed(A_msg_accessed),                    // msg is stored in BRAMMsgTX by networkCentCtrl
    
        .dataTX_msg(A_dataTX_msg),                // message from PP 
        .addrTX_msg(A_addrTX_msg),               // addr for BRAMMsgTX
        .sizeTX_msg(A_sizeTX_msg),                // transmitting message size
        
        .dataRX_msg(A_dataRX_msg),               // message pasrsed from Ethernet frame
        .weRX_msg(A_weRX_msg),                        // write enable for BRAMMsgRX
        .addrRX_msg(A_addrRX_msg),               // addr for BRAMMSGRX
        .sizeRX_msg(A_sizeRX_msg),               // receoved message size
         
        // GMII Interface (client MAC <=> PCS)
        //------------------------------------
        .gmii_tx_clk(clk_GMII),           // Transmit clock from client MAC.
        .gmii_rx_clk(clk_GMII),           // Receive clock to client MAC.
        .link_status(link_status),           // Link status: use status_vector[0]
        .gmii_txd(gmii_rxd),              // Transmit data from client MAC.
        .gmii_tx_en(gmii_rx_dv),            // Transmit control signal from client MAC.
        .gmii_tx_er(gmii_rx_er),            // Transmit control signal from client MAC.
        .gmii_rxd((gmii_txd+gmii_txd_error)),              // Received Data to client MAC.
        .gmii_rx_dv(gmii_tx_en),            // Received control signal to client MAC.
        .gmii_rx_er(gmii_tx_er)            // Received control signal to client MAC.
    );
    
    postProcessing UPP_A(
    .reset(reset),
    .clock_100M(clock_100M),
    .clkTX_msg(clkTX_msg),
    .clkRX_msg(clkRX_msg),
    // Test different size 
    .independent_clk_en(1'b0),
    .io_refclk_en(1'b0),
    .gmii_rx_clk_en(1'b0),
     // Post Processing interface
    //------------------------------------
    .busy_PP2Net_TX(A_busy_PP2Net_TX),                   // BRAMMsgTX is used by PP
    .busy_Net2PP_TX(A_busy_Net2PP_TX),                  // BRAMMsgTX is used by NetworkCentCtrl
    .msg_stored(A_msg_stored),                       // msg is stored in BRAMMsgTX by PP 
    
    .busy_PP2Net_RX(A_busy_PP2Net_RX),                   // BRAMMsgRX is used by PP
    .busy_Net2PP_RX(A_busy_Net2PP_RX),                  // BRAMMsgRX is used by networkCentCtrl
    .msg_accessed(A_msg_accessed),                    // msg is stored in BRAMMsgTX by networkCentCtrl
    
    .dataTX_msg(A_dataTX_msg),                // message from PP 
    .addrTX_msg(A_addrTX_msg),               // addr for BRAMMsgTX
    .sizeTX_msg(A_sizeTX_msg),                // transmitting message size
    
    .dataRX_msg(A_dataRX_msg),               // message pasrsed from Ethernet frame
    .weRX_msg(A_weRX_msg),                        // write enable for BRAMMsgRX
    .addrRX_msg(A_addrRX_msg),               // addr for BRAMMSGRX
    .sizeRX_msg(A_sizeRX_msg),               // receoved message size
    .new_one_pulse(A_new_one_pulse)
    );
    
    pushButton Upb_A(
        .clk(clkTX_msg),
        .reset(reset),
//        .pb(A_output_next_pb),
        .pb((A_output_next_pb|A_next_pb)), //for continuous transportation
        .one_pulse(A_new_one_pulse)
    );
    reg A_next_pb;
    always @(posedge clk_PP or posedge reset) begin
        if (reset) begin
            A_next_pb <= 1'b0;
        end else begin
            if (A_msg_accessed) begin
                A_next_pb <= 1'b1;
            end else if (A_new_one_pulse) begin
                A_next_pb <= 1'b0;
            end else begin
                A_next_pb <= A_next_pb;
            end
        end
    end
    wire A_output_next_pb;
    initial begin
        A_output_next_pb = 0;
    end
endmodule