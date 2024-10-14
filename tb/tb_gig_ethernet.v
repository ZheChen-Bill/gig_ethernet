`timescale 1 ps/1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/18 20:36:02
// Design Name: 
// Module Name: tb_gig_ethernet
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


module tb_gig_ethernet(

    );
  // testbench control semaphores
  reg  configuration_finished;
  reg  configuration_finished_B;
  wire tx_monitor_finished;
  wire rx_monitor_finished;
  wire simulation_finished;
  //----------------------------------------------------------------------------
  // DUT signals
  //----------------------------------------------------------------------------

  // An independent clock source used as the freerun and drp clock for  GT transceiver  logic.
  reg  independent_clock;
  // An independent clock source used as the reference clock for an
  // IDELAYCTRL and other IO logic components 
  reg io_refclk;
  reg stim_tx_clk;
  // System Reset
  reg  reset;

  // Transceiver Interface
  //----------------------
  reg  gtrefclk_p;
  reg  gtrefclk_n;
  wire  rxuserclk2;
  wire txp;
  wire txn;
  wire rxp;
  wire rxn;

  // GMII Interface
  //---------------
  wire gmii_tx_clk;
  wire gmii_rx_clk;
  wire [7:0] gmii_txd;
  wire gmii_tx_en;
  wire gmii_tx_er;
  wire [7:0] gmii_rxd;
  wire gmii_rx_dv;
  wire gmii_rx_er;

  wire [7:0] gmii_txd_A;
  wire gmii_tx_en_A;
  wire gmii_tx_er_A;
  wire [7:0] gmii_rxd_A;
  wire gmii_rx_dv_A;
  wire gmii_rx_er_A;

  // Management: Alternative to MDIO Interface
  //------------------------------------------
  reg [4:0] configuration_vector;
  reg [4:0] configuration_vector_B;



  wire signal_detect;
  wire [15:0] status_vector;
  wire [15:0] status_vector_B;



  //----------------------------------------------------------------------------
  // Create clock sources
  //----------------------------------------------------------------------------

   // An independent clock source used as the reference clock for an
   // IDELAYCTRL (if present) and other Select IO Components 
   // This testbench uses the frequency of 300MHz.
  initial
  begin
    io_refclk <= 1'b0;
    forever
    begin
      io_refclk <= 1'b0;
      #1667;
      io_refclk <= 1'b1;
      #1667;
    end
  end

  initial
  begin
    independent_clock <= 1'b0;
    forever
    begin
      independent_clock <= 1'b0;
      #8000;
      independent_clock <= 1'b1;
      #8000;
    end
  end

  // Create the transceiver Reference clock (125 MHz)
  initial
  begin
    gtrefclk_p <= 1'b0;
    gtrefclk_n <= 1'b1;
    forever
    begin
      gtrefclk_p <= 1'b0;
      gtrefclk_n <= 1'b1;
      #3200;
      gtrefclk_p <= 1'b1;
      gtrefclk_n <= 1'b0;
      #3200;
    end
  end

  initial                 // drives stim_tx_clk at 125 MH
  begin
    #100;
    stim_tx_clk <= 1'b0;
    forever
    begin
      stim_tx_clk <= 1'b0;
      #4000;
      stim_tx_clk <= 1'b1;
      #4000;
    end
  end
  
  reg stim_tx_clk2;
  initial                 // drives stim_tx_clk at 125 MH
  begin
    #100;
    stim_tx_clk2 <= 1'b0;
    forever
    begin
      stim_tx_clk2 <= 1'b0;
      #4000;
      stim_tx_clk2 <= 1'b1;
      #4000;
    end
  end
  assign gmii_tx_clk = stim_tx_clk;
  
  wire gmii_rx_clk2;
  wire gmii_tx_clk2;
  assign gmii_tx_clk2 = stim_tx_clk2;

  //----------------------------------------------------------------------------
  // Wire up Device Under Test
  //----------------------------------------------------------------------------
  gig_ethernet_pcs_pma_0_example_design dut_A
     (
      .independent_clock      (independent_clock),
      .io_refclk              (io_refclk),
      .gtrefclk_p             (gtrefclk_p),
      .gtrefclk_n             (gtrefclk_n),
      .rxuserclk2             (rxuserclk2),
      .txp                    (txp),
      .txn                    (txn),
      .rxp                    (rxp),
      .rxn                    (rxn),
      .gmii_tx_clk            (gmii_tx_clk),
      .gmii_rx_clk            (gmii_rx_clk),
      .gmii_txd               (gmii_txd),
      .gmii_tx_en             (gmii_tx_en),
      .gmii_tx_er             (gmii_tx_er),
      .gmii_rxd               (gmii_rxd),
      .gmii_rx_dv             (gmii_rx_dv),
      .gmii_rx_er             (gmii_rx_er),
      .configuration_vector   (configuration_vector),
      .status_vector          (status_vector),
      .reset                  (reset),
      .signal_detect          (signal_detect)
      );
 
  //----------------------------------------------------------------------------
  // Wire up Device Under Test
  //----------------------------------------------------------------------------
  gig_ethernet_pcs_pma_0_example_design dut_B
     (
      .independent_clock      (independent_clock),
      .io_refclk              (io_refclk),
      .gtrefclk_p             (gtrefclk_p),
      .gtrefclk_n             (gtrefclk_n),
      .rxuserclk2             (rxuserclk2),
      .txp                    (rxp),
      .txn                    (rxn),
      .rxp                    (txp),
      .rxn                    (txn),
      .gmii_tx_clk            (gmii_tx_clk2),
      .gmii_rx_clk            (gmii_rx_clk2),
      .gmii_txd               (gmii_txd_A),
      .gmii_tx_en             (gmii_tx_en_A),
      .gmii_tx_er             (gmii_tx_er_A),
      .gmii_rxd               (gmii_rxd_A),
      .gmii_rx_dv             (gmii_rx_dv_A),
      .gmii_rx_er             (gmii_rx_er_A),
      .configuration_vector   (configuration_vector_B),
      .status_vector          (status_vector_B),
      .reset                  (reset),
      .signal_detect          (signal_detect)
      );
      
  assign signal_detect = 1'b1;
  
  initial
  begin : p_configuration
    $display("** Note: Timing checks are not valid");

    configuration_finished <= 0;
    configuration_finished_B <= 0;

    configuration_vector[1:0] <= 2'b00;   // Disable Loopback
    configuration_vector[2]   <= 1'b0;   // Disable POWERDOWN
    configuration_vector[3]   <= 1'b0;   // Disable ISOLATE
    configuration_vector[4]   <= 1'b0;   // Enable  Auto-Neg
    
    configuration_vector_B[1:0] <= 2'b00;   // Disable Loopback
    configuration_vector_B[2]   <= 1'b0;   // Disable POWERDOWN
    configuration_vector_B[3]   <= 1'b0;   // Disable ISOLATE
    configuration_vector_B[4]   <= 1'b0;   // Enable  Auto-Neg
    // reset the core
    $display("Resetting core...");
    reset <= 1'b1;
    #1000000
    reset <= 1'b0;

    // wait for core to obtain synchronisation
//    #300000000                     
    #100000000                     
    

    wait ((status_vector[1] == 1) && (status_vector[1] == 1));
    #80000000

    @(posedge gtrefclk_p)

    configuration_finished <= 1;
    configuration_finished_B <= 1;
//    $finish;
  end // p_configuration
  
    reg [7:0] gmii_txd_error;
    
    reg link_status;
    reg clk_PP;
//    reg clk_GMII;
    wire clkTX_msg_A;
    wire clkRX_msg_A;
    wire clkTX_msg_B;
    wire clkRX_msg_B;    
    reg clock_100M;
    reg reset_network;
    
// clk_PP = 380MHz
//    parameter freq_PP = 380000000;
    parameter freq_PP = 125000000;
    parameter period = 1/freq_PP;
    initial begin 
        clk_PP = 1'b0; 
        forever begin 
//            #(1.315) clk_PP = 1'b1;
//            #(1.315) clk_PP = 1'b0;
            #(1334) clk_PP = 1'b1;
            #(1334) clk_PP = 1'b0;
        end 
    end 

    initial begin 
        clock_100M = 1'b0; 
        forever begin 
            #(5000) clock_100M = 1'b1;
            #(5000) clock_100M = 1'b0;
        end 
    end 

    initial begin  
        link_status = 1'b1;
    end
    
    initial begin  
        reset_network = 1'b0;
        wait ((configuration_finished == 1) && (configuration_finished_B == 1));
        reset_network = 1'b1;
        #100000;
        reset_network = 1'b0;
    end    
    
    initial begin
        B_output_next_pb = 1'b0;
        #200000000;
        @(posedge clk_PP) B_output_next_pb = 1'b1;
        #500000;
        B_output_next_pb = 1'b0;
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
    reg B_output_next_pb;
    wire B_new_one_pulse;
    
    networkCentCtrl_B #(
        .lost_cycle(26'd30),
        .phy_reset_wait(26'd20)
    ) Unetwork_Bob(
        .reset(reset_network),                 // system reset
//        .clock_100M(clock_100M),            // clock for JTAG module 
        .clk_PP(clk_PP),
        .clkTX_msg(clkTX_msg_B),                // clock for accessing BRAMMsgTX
        .clkRX_msg(clkRX_msg_B),                // clock for accessing BRAMMsgRX
    
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
        .gmii_tx_clk(gmii_tx_clk),           // Transmit clock from client MAC.
        .gmii_rx_clk(gmii_rx_clk),           // Receive clock to client MAC.
        .link_status(link_status),           // Link status: use status_vector[0]
        .gmii_txd(gmii_txd),              // Transmit data from client MAC.
        .gmii_tx_en(gmii_tx_en),            // Transmit control signal from client MAC.
        .gmii_tx_er(gmii_tx_er),            // Transmit control signal from client MAC.
        .gmii_rxd(gmii_rxd),              // Received Data to client MAC.
        .gmii_rx_dv(gmii_rx_dv),            // Received control signal to client MAC.
        .gmii_rx_er(gmii_rx_er)            // Received control signal to client MAC.
    );
    
    
    
    postProcessing UPP_B(
    .reset(reset_network),
//    .clock_100M(clock_100M),
    .clkTX_msg(clkTX_msg_B),
    .clkRX_msg(clkRX_msg_B),
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
        .clk(clkTX_msg_B),
        .reset(reset_network),
//        .pb(B_output_next_pb),
        .pb(B_output_next_pb|B_next_pb),
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
        .reset(reset_network),                 // system reset
//        .clock_100M(clock_100M),            // clock for JTAG module 
        .clk_PP(clk_PP),
        .clkTX_msg(clkTX_msg_A),                // clock for accessing BRAMMsgTX
        .clkRX_msg(clkRX_msg_A),                // clock for accessing BRAMMsgRX
    
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
//        .gmii_tx_clk(gmii_tx_clk2),           // Transmit clock from client MAC.
//        .gmii_rx_clk(gmii_rx_clk2),           // Receive clock to client MAC.
        .gmii_tx_clk(gmii_rx_clk),           // Transmit clock from client MAC.
        .gmii_rx_clk(gmii_tx_clk),           // Receive clock to client MAC.
        .link_status(link_status),           // Link status: use status_vector[0]
        .gmii_txd(gmii_txd_A),              // Transmit data from client MAC.
        .gmii_tx_en(gmii_tx_en_A),            // Transmit control signal from client MAC.
        .gmii_tx_er(gmii_tx_er_A),            // Transmit control signal from client MAC.
        .gmii_rxd(gmii_rxd_A),              // Received Data to client MAC.
        .gmii_rx_dv(gmii_rx_dv_A),            // Received control signal to client MAC.
        .gmii_rx_er(gmii_rx_er_A)            // Received control signal to client MAC.
    );
    
    postProcessing UPP_A(
    .reset(reset_network),
//    .clock_100M(clock_100M),
    .clkTX_msg(clkTX_msg_A),
    .clkRX_msg(clkRX_msg_A),
    // Test different size 
    .independent_clk_en(1'b1),
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
        .clk(clkTX_msg_A),
        .reset(reset_network),
//        .pb(A_output_next_pb),
        .pb(A_output_next_pb|A_next_pb),
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
