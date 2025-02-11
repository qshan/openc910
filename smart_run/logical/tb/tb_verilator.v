/*Copyright 2019-2021 T-Head Semiconductor Co., Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
/*Copyright 2019-2021 T-Head Semiconductor Co., Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

`timescale 1ns/100ps

`define CLK_PERIOD          10
`define TCLK_PERIOD         40
`define MAX_RUN_TIME        32'h3000000

`define SOC_TOP             top.x_soc
`define RTL_MEM             top.x_soc.x_axi_slave128.x_f_spsram_large

`define CPU_TOP             top.x_soc.x_cpu_sub_system_axi.x_rv_integration_platform.x_cpu_top
`define tb_retire0          `CPU_TOP.core0_pad_retire0
`define retire0_pc          `CPU_TOP.core0_pad_retire0_pc[39:0]
`define tb_retire1          `CPU_TOP.core0_pad_retire1
`define retire1_pc          `CPU_TOP.core0_pad_retire1_pc[39:0]
`define tb_retire2          `CPU_TOP.core0_pad_retire2
`define retire2_pc          `CPU_TOP.core0_pad_retire2_pc[39:0]
`define CPU_CLK             `CPU_TOP.pll_cpu_clk
`define CPU_RST             `CPU_TOP.pad_cpu_rst_b
`define clk_en              `CPU_TOP.axim_clk_en
`define CP0_RSLT_VLD        `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_cp0_top.x_ct_cp0_iui.cp0_iu_ex3_rslt_vld
`define CP0_RSLT            `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_cp0_top.x_ct_cp0_iui.cp0_iu_ex3_rslt_data[63:0]

`define EVT_ICACHE_ACCESS          32'd1
`define EVT_ICACHE_MISS            32'd2
`define EVT_TLB_IUTLB_MISS         32'd3
`define EVT_TLB_DUTLB_MISS         32'd4
`define EVT_TLB_JTLB_MISS          32'd5
`define EVT_BHT_MISPRED            32'd6
`define EVT_INST012_CONDBR         32'd7
`define EVT_JMP_MISPRED            32'd8
`define EVT_INST012_JMP            32'd9
`define EVT_SPEC_FAIL              32'd10
`define EVT_INST012_STORE          32'd11
`define EVT_DCACHE_RD_ACCESS       32'd12
`define EVT_DCACHE_RD_MISS         32'd13
`define EVT_DCACHE_WR_ACCESS       32'd14
`define EVT_DCACHE_WR_MISS         32'd15
`define EVT_PIPE01234567_LCH_FAIL  32'd20
`define EVT_PIPE345_REG_LCH_FAIL   32'd21
`define EVT_PIPE01234567_INST_VLD  32'd22
`define EVT_LD_ST_CROSS_4K_STALL   32'd23
`define EVT_LD_ST_OTHER_STALL      32'd24
`define EVT_SQ_DISCARD             32'd25
`define EVT_SQ_DATA_DISCARD        32'd26
`define EVT_BRANCH_TARGET_MISPRED  32'd27
`define EVT_BRANCH_TARGET_INSTALL  32'd28
`define EVT_IR_INST0123_ALU        32'd29
`define EVT_IR_INST0123_LDST       32'd30
`define EVT_IR_INST0123_VEC        32'd31
`define EVT_IR_INST0123_CSR        32'd32
`define EVT_IR_INST0123_SYNC       32'd33
`define EVT_UNALIGN_INST           32'd34
`define EVT_INT_ACK_VLD            32'd35
`define EVT_INT_DISABLE            32'd36
`define EVT_INST0123_ECALL         32'd37
`define EVT_INST0123_LONGJUMP      32'd38
`define EVT_FRONTEND_STALL         32'd39
`define EVT_BACKEND_STALL          32'd40
`define EVT_SYNC_STALL             32'd41
`define EVT_INST0123_FPU           32'd42


// `define APB_BASE_ADDR       40'h4000000000
`define APB_BASE_ADDR       40'hb0000000

module top(
  input wire clk
);
  reg jclk;
  reg rst_b;
  reg jrst_b;
  reg jtap_en;
  wire jtg_tms;
  wire jtg_tdi;
  wire jtg_tdo;
  wire  pad_yy_gate_clk_en_b;

  reg [100*8:0] EVENT_NAME [0:41];

  static integer FILE;

  wire uart0_sin;
  wire [7:0]b_pad_gpio_porta;

  assign pad_yy_gate_clk_en_b = 1'b1;

  //initial
  //begin
  //  clk =0;
  //  forever begin
  //    #(`CLK_PERIOD/2) clk = ~clk;
  //  end
  //end



  integer jclkCnt;
  initial
  begin
    jclk = 0;
    jclkCnt = 0;
    //forever begin
    //  #(`TCLK_PERIOD/2) jclk = ~jclk;
    //end

    force `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.cnt_mask        = 32'h0;
    force `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt3_value  = `EVT_FRONTEND_STALL;
    force `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt4_value  = `EVT_BACKEND_STALL;
    force `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt5_value  = `EVT_ICACHE_ACCESS;
    force `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt6_value  = `EVT_ICACHE_MISS;
    force `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt7_value  = `EVT_BHT_MISPRED;
    force `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt8_value  = `EVT_INST012_CONDBR;
    force `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt9_value  = `EVT_JMP_MISPRED;
    force `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt10_value = `EVT_SPEC_FAIL;
    force `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt11_value = `EVT_INST012_STORE;
    force `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt12_value = `EVT_DCACHE_RD_ACCESS;
    force `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt13_value = `EVT_DCACHE_RD_MISS;
    force `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt14_value = `EVT_DCACHE_WR_ACCESS;
    force `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt15_value = `EVT_DCACHE_WR_MISS;
    force `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt16_value = `EVT_PIPE01234567_LCH_FAIL;
    force `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt17_value = `EVT_PIPE345_REG_LCH_FAIL;
    force `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt18_value = `EVT_PIPE01234567_INST_VLD;


    EVENT_NAME[`EVT_ICACHE_ACCESS]          = "TOP.x_ct_top_0: ICACHE_ACCESS";
    EVENT_NAME[`EVT_ICACHE_MISS]            = "TOP.x_ct_top_0: ICACHE_MISS";
    EVENT_NAME[`EVT_TLB_IUTLB_MISS]         = "TOP.x_ct_top_0: TLB_IUTLB_MISS";
    EVENT_NAME[`EVT_TLB_DUTLB_MISS]         = "TOP.x_ct_top_0: TLB_DUTLB_MISS";
    EVENT_NAME[`EVT_TLB_JTLB_MISS]          = "TOP.x_ct_top_0: TLB_JTLB_MISS";
    EVENT_NAME[`EVT_BHT_MISPRED]            = "TOP.x_ct_top_0: BHT_MISPRED";
    EVENT_NAME[`EVT_INST012_CONDBR]         = "TOP.x_ct_top_0: INST012_CONDBR";
    EVENT_NAME[`EVT_JMP_MISPRED]            = "TOP.x_ct_top_0: JMP_MISPRED";
    EVENT_NAME[`EVT_INST012_JMP]            = "TOP.x_ct_top_0: INST012_JMP";
    EVENT_NAME[`EVT_SPEC_FAIL]              = "TOP.x_ct_top_0: SPEC_FAIL";
    EVENT_NAME[`EVT_INST012_STORE]          = "TOP.x_ct_top_0: INST012_STORE";
    EVENT_NAME[`EVT_DCACHE_RD_ACCESS]       = "TOP.x_ct_top_0: DCACHE_RD_ACCESS";
    EVENT_NAME[`EVT_DCACHE_RD_MISS]         = "TOP.x_ct_top_0: DCACHE_RD_MISS";
    EVENT_NAME[`EVT_DCACHE_WR_ACCESS]       = "TOP.x_ct_top_0: DCACHE_WR_ACCESS";
    EVENT_NAME[`EVT_DCACHE_WR_MISS]         = "TOP.x_ct_top_0: DCACHE_WR_MISS";
    EVENT_NAME[`EVT_PIPE01234567_LCH_FAIL]  = "TOP.x_ct_top_0: PIPE01234567_LCH_FAIL";
    EVENT_NAME[`EVT_PIPE345_REG_LCH_FAIL]   = "TOP.x_ct_top_0: PIPE345_REG_LCH_FAIL";
    EVENT_NAME[`EVT_PIPE01234567_INST_VLD]  = "TOP.x_ct_top_0: PIPE01234567_INST_VLD";
    EVENT_NAME[`EVT_LD_ST_CROSS_4K_STALL]   = "TOP.x_ct_top_0: LD_ST_CROSS_4K_STALL";
    EVENT_NAME[`EVT_LD_ST_OTHER_STALL]      = "TOP.x_ct_top_0: LD_ST_OTHER_STALL";
    EVENT_NAME[`EVT_SQ_DISCARD]             = "TOP.x_ct_top_0: SQ_DISCARD";
    EVENT_NAME[`EVT_SQ_DATA_DISCARD]        = "TOP.x_ct_top_0: SQ_DATA_DISCARD";
    EVENT_NAME[`EVT_BRANCH_TARGET_MISPRED]  = "TOP.x_ct_top_0: BRANCH_TARGET_MISPRED";
    EVENT_NAME[`EVT_BRANCH_TARGET_INSTALL]  = "TOP.x_ct_top_0: BRANCH_TARGET_INSTALL";
    EVENT_NAME[`EVT_IR_INST0123_ALU]        = "TOP.x_ct_top_0: IR_INST0123_ALU";
    EVENT_NAME[`EVT_IR_INST0123_LDST]       = "TOP.x_ct_top_0: IR_INST0123_LDST";
    EVENT_NAME[`EVT_IR_INST0123_VEC]        = "TOP.x_ct_top_0: IR_INST0123_VEC";
    EVENT_NAME[`EVT_IR_INST0123_CSR]        = "TOP.x_ct_top_0: IR_INST0123_CSR";
    EVENT_NAME[`EVT_IR_INST0123_SYNC]       = "TOP.x_ct_top_0: IR_INST0123_SYNC";
    EVENT_NAME[`EVT_UNALIGN_INST]           = "TOP.x_ct_top_0: UNALIGN_INST";
    EVENT_NAME[`EVT_INT_ACK_VLD]            = "TOP.x_ct_top_0: INT_ACK_VLD";
    EVENT_NAME[`EVT_INT_DISABLE]            = "TOP.x_ct_top_0: INT_DISABLE";
    EVENT_NAME[`EVT_INST0123_ECALL]         = "TOP.x_ct_top_0: INST0123_ECALL";
    EVENT_NAME[`EVT_INST0123_LONGJUMP]      = "TOP.x_ct_top_0: INST0123_LONGJUMP";
    EVENT_NAME[`EVT_FRONTEND_STALL]         = "TOP.x_ct_top_0: FRONTEND_STALL";
    EVENT_NAME[`EVT_BACKEND_STALL]          = "TOP.x_ct_top_0: BACKEND_STALL";
    EVENT_NAME[`EVT_SYNC_STALL]             = "TOP.x_ct_top_0: SYNC_STALL";
    EVENT_NAME[`EVT_INST0123_FPU]           = "TOP.x_ct_top_0: INST0123_FPU";
  end
  always@(posedge clk) begin
    if(jclkCnt < `TCLK_PERIOD / `CLK_PERIOD / 2 - 1) begin
      jclkCnt = jclkCnt + 1;
    end
    else begin
      jclkCnt = 0;
      jclk = !jclk;
    end
  end

  integer rst_bCnt;
  initial
  begin
    rst_bCnt = 0;
    rst_b = 1;
    //#100;
    //rst_b = 0;
    //#100;
    //rst_b = 1;
  end

  always@(posedge clk) begin
    rst_bCnt = rst_bCnt + 1;
    if(rst_bCnt > 10 && rst_bCnt < 20) rst_b = 0;
    else if(rst_bCnt > 20) rst_b = 1;
  end

  integer jrstCnt;
  initial
  begin
    jrst_b = 1;
    jrstCnt = 0;
    //#400;
    //jrst_b = 0;
    //#400;
    //jrst_b = 1;
  end
  always@(posedge clk) begin
    jrstCnt = jrstCnt + 1;
    if(jrstCnt > 40 && jrstCnt < 80) jrst_b = 0;
    else if(jrstCnt > 80) jrst_b = 1;
  end

  integer i;
  bit [31:0] mem_inst_temp [65536];
  bit [31:0] mem_data_temp [65536];
  integer j;
  initial
  begin
    $display("\t********* Init Program *********");
    $display("\t********* Wipe memory to 0 *********");
    for(i=0; i < 32'h16384; i=i+1)
    begin
      `RTL_MEM.ram0.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram1.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram2.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram3.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram4.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram5.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram6.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram7.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram8.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram9.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram10.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram11.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram12.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram13.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram14.mem[i][7:0] = 8'h0;
      `RTL_MEM.ram15.mem[i][7:0] = 8'h0;
    end

    $display("\t********* Read program *********");
    $readmemh("inst.pat", mem_inst_temp);
    $readmemh("data.pat", mem_data_temp);

    $display("\t********* Load program to memory *********");
    i=0;
    for(j=0;i<32'h4000;i=j/4)
    begin
      `RTL_MEM.ram0.mem[i][7:0] = mem_inst_temp[j][31:24];
      `RTL_MEM.ram1.mem[i][7:0] = mem_inst_temp[j][23:16];
      `RTL_MEM.ram2.mem[i][7:0] = mem_inst_temp[j][15: 8];
      `RTL_MEM.ram3.mem[i][7:0] = mem_inst_temp[j][ 7: 0];
      j = j+1;
      `RTL_MEM.ram4.mem[i][7:0] = mem_inst_temp[j][31:24];
      `RTL_MEM.ram5.mem[i][7:0] = mem_inst_temp[j][23:16];
      `RTL_MEM.ram6.mem[i][7:0] = mem_inst_temp[j][15: 8];
      `RTL_MEM.ram7.mem[i][7:0] = mem_inst_temp[j][ 7: 0];
      j = j+1;
      `RTL_MEM.ram8.mem[i][7:0] = mem_inst_temp[j][31:24];
      `RTL_MEM.ram9.mem[i][7:0] = mem_inst_temp[j][23:16];
      `RTL_MEM.ram10.mem[i][7:0] = mem_inst_temp[j][15: 8];
      `RTL_MEM.ram11.mem[i][7:0] = mem_inst_temp[j][ 7: 0];
      j = j+1;
      `RTL_MEM.ram12.mem[i][7:0] = mem_inst_temp[j][31:24];
      `RTL_MEM.ram13.mem[i][7:0] = mem_inst_temp[j][23:16];
      `RTL_MEM.ram14.mem[i][7:0] = mem_inst_temp[j][15: 8];
      `RTL_MEM.ram15.mem[i][7:0] = mem_inst_temp[j][ 7: 0];
      j = j+1;
    end
    i=0;
    for(j=0;i<32'h4000;i=j/4)
    begin
      `RTL_MEM.ram0.mem[i+32'h4000][7:0]  = mem_data_temp[j][31:24];
      `RTL_MEM.ram1.mem[i+32'h4000][7:0]  = mem_data_temp[j][23:16];
      `RTL_MEM.ram2.mem[i+32'h4000][7:0]  = mem_data_temp[j][15: 8];
      `RTL_MEM.ram3.mem[i+32'h4000][7:0]  = mem_data_temp[j][ 7: 0];
      j = j+1;
      `RTL_MEM.ram4.mem[i+32'h4000][7:0]  = mem_data_temp[j][31:24];
      `RTL_MEM.ram5.mem[i+32'h4000][7:0]  = mem_data_temp[j][23:16];
      `RTL_MEM.ram6.mem[i+32'h4000][7:0]  = mem_data_temp[j][15: 8];
      `RTL_MEM.ram7.mem[i+32'h4000][7:0]  = mem_data_temp[j][ 7: 0];
      j = j+1;
      `RTL_MEM.ram8.mem[i+32'h4000][7:0]   = mem_data_temp[j][31:24];
      `RTL_MEM.ram9.mem[i+32'h4000][7:0]   = mem_data_temp[j][23:16];
      `RTL_MEM.ram10.mem[i+32'h4000][7:0]  = mem_data_temp[j][15: 8];
      `RTL_MEM.ram11.mem[i+32'h4000][7:0]  = mem_data_temp[j][ 7: 0];
      j = j+1;
      `RTL_MEM.ram12.mem[i+32'h4000][7:0]  = mem_data_temp[j][31:24];
      `RTL_MEM.ram13.mem[i+32'h4000][7:0]  = mem_data_temp[j][23:16];
      `RTL_MEM.ram14.mem[i+32'h4000][7:0]  = mem_data_temp[j][15: 8];
      `RTL_MEM.ram15.mem[i+32'h4000][7:0]  = mem_data_temp[j][ 7: 0];
      j = j+1;
    end
  end

  integer clkCnt;
  always@(posedge clk) begin
    clkCnt = clkCnt + 1;
    if(clkCnt > `MAX_RUN_TIME) begin
      $display("**********************************************");
      $display("*   meeting max simulation time, stop!       *");
      $display("**********************************************");
      FILE = $fopen("run_case.report","w");
      $fwrite(FILE,"TEST FAIL");
      $finish;
    end
  end
  initial
  begin
    clkCnt = 0;
  //#(`MAX_RUN_TIME * `CLK_PERIOD);
  //  $display("**********************************************");
  //  $display("*   meeting max simulation time, stop!       *");
  //  $display("**********************************************");
  //  FILE = $fopen("run_case.report","w");
  //  $fwrite(FILE,"TEST FAIL");
  //$finish;
  end

  reg [31:0] retire_inst_in_period;
  reg [31:0] cycle_count;

  `define LAST_CYCLE 50000
  always @(posedge clk or negedge rst_b)
  begin
    if(!rst_b)
    begin
      cycle_count[31:0] <= 32'b1;
      cnt_frontend_bubbles[63:0] <= 0;
      cnt_decoded_uops[63:0] <= 0;
      cnt_lsiq_ctrl_full[63:0] <= 0;
      cnt_sdiq_ctrl_full[63:0] <= 0;
      cnt_aiq0_ctrl_full[63:0] <= 0;
      cnt_aiq1_ctrl_full[63:0] <= 0;
      cnt_viq0_ctrl_full[63:0] <= 0;
      cnt_viq1_ctrl_full[63:0] <= 0;
      cnt_biq_ctrl_full[63:0] <= 0;
      cnt_ctrl_ir_stall[63:0] <= 0;
      cnt_ctrl_ir_stage_stall[63:0] <= 0;
      cnt_ctrl_is_stall[63:0] <= 0;
      cnt_ctrl_ir_stage_is_both_stall[63:0] <= 0;
      cnt_ctrl_ir_preg_stall[63:0] <= 0;
      cnt_ctrl_ir_vreg_stall[63:0] <= 0;
      cnt_ctrl_ir_freg_stall[63:0] <= 0;
      cnt_ctrl_ir_ereg_stall[63:0] <= 0;
      cnt_rtu_idu_flush_stall[63:0] <= 0;
      cnt_iu_idu_mispred_stall[63:0] <= 0;
      cnt_ctrl_is_dis_stall[63:0] <= 0;
      cnt_is_dis_type_stall[63:0] <= 0;
      cnt_ctrl_is_rob_full[63:0] <= 0;
      cnt_ctrl_is_iq_full[63:0] <= 0;
      cnt_ctrl_is_vmb_full[63:0] <= 0;

      cnt_div_inst[63:0] <= 0;
      cnt_special_inst[63:0] <= 0;
      cnt_mul_inst[63:0] <= 0;
      cnt_alu_inst[63:0] <= 0;
      cnt_lsu_inst[63:0] <= 0;
      cnt_staddr_inst[63:0] <= 0;

    end
    else
      cycle_count[31:0] <= cycle_count[31:0] + 1'b1;
  end


  always @(posedge clk or negedge rst_b)
  begin
    if(!rst_b) //reset to zero
      retire_inst_in_period[31:0] <= 32'b0;
    else if( (cycle_count[31:0] % `LAST_CYCLE) == 0)//check and reset retire_inst_in_period every 50000 cycles
    begin
      if(retire_inst_in_period[31:0] == 0)begin
        $display("*************************************************************");
        $display("* Error: There is no instructions retired in the last %d cycles! *", `LAST_CYCLE);
        $display("*              Simulation Fail and Finished!                *");
        $display("*************************************************************");
        //#10;
        FILE = $fopen("run_case.report","w");
        $fwrite(FILE,"TEST FAIL");

        $finish;
      end
      retire_inst_in_period[31:0] <= 32'b0;
    end
    else if(`tb_retire0 || `tb_retire1 || `tb_retire2)
      retire_inst_in_period[31:0] <= retire_inst_in_period[31:0] + 1'b1;
  end

  reg [31:0] cpu_awaddr;
  reg [3:0]  cpu_awlen;
  reg [15:0] cpu_wstrb;
  reg        cpu_wvalid;
  reg [63:0] value0;
  reg [63:0] value1;
  reg [63:0] value2;

  reg [63:0] cnt_cycle;
  reg [63:0] cnt_retire;
  reg [63:0] cnt_inhibit;
  reg [63:0] cnt3;
  reg [63:0] cnt4;
  reg [63:0] cnt5;
  reg [63:0] cnt6;
  reg [63:0] cnt7;
  reg [63:0] cnt8;
  reg [63:0] cnt9;
  reg [63:0] cnt10;
  reg [63:0] cnt11;
  reg [63:0] cnt12;
  reg [63:0] cnt13;
  reg [63:0] cnt14;
  reg [63:0] cnt15;
  reg [63:0] cnt16;
  reg [63:0] cnt17;
  reg [63:0] cnt18;

  reg [63:0] cnt3_select_event;
  reg [63:0] cnt4_select_event;
  reg [63:0] cnt5_select_event;
  reg [63:0] cnt6_select_event;
  reg [63:0] cnt7_select_event;
  reg [63:0] cnt8_select_event;
  reg [63:0] cnt9_select_event;
  reg [63:0] cnt10_select_event;
  reg [63:0] cnt11_select_event;
  reg [63:0] cnt12_select_event;
  reg [63:0] cnt13_select_event;
  reg [63:0] cnt14_select_event;
  reg [63:0] cnt15_select_event;
  reg [63:0] cnt16_select_event;
  reg [63:0] cnt17_select_event;
  reg [63:0] cnt18_select_event;

  reg [63:0] cnt_frontend_bubbles;
  reg [63:0] cnt_decoded_uops;
  reg pipedown_inst0_vld;
  reg pipedown_inst1_vld;
  reg pipedown_inst2_vld;
  reg pipedown_inst3_vld;
  reg [63:0] cnt_lsiq_ctrl_full;
  reg [63:0] cnt_sdiq_ctrl_full;
  reg [63:0] cnt_aiq0_ctrl_full;
  reg [63:0] cnt_aiq1_ctrl_full;
  reg [63:0] cnt_viq0_ctrl_full;
  reg [63:0] cnt_viq1_ctrl_full;
  reg [63:0] cnt_biq_ctrl_full;

  reg [63:0] cnt_ctrl_ir_stall;
  reg [63:0] cnt_ctrl_ir_stage_stall;
  reg [63:0] cnt_ctrl_is_stall;
  reg [63:0] cnt_ctrl_ir_stage_is_both_stall;
  reg [63:0] cnt_ctrl_ir_preg_stall;
  reg [63:0] cnt_ctrl_ir_vreg_stall;
  reg [63:0] cnt_ctrl_ir_freg_stall;
  reg [63:0] cnt_ctrl_ir_ereg_stall;
  reg [63:0] cnt_rtu_idu_flush_stall;
  reg [63:0] cnt_iu_idu_mispred_stall;
  reg [63:0] cnt_ctrl_is_dis_stall;
  reg [63:0] cnt_is_dis_type_stall;
  reg [63:0] cnt_ctrl_is_rob_full;
  reg [63:0] cnt_ctrl_is_iq_full;
  reg [63:0] cnt_ctrl_is_vmb_full;

  reg [63:0] cnt_div_inst;
  reg [63:0] cnt_special_inst;
  reg [63:0] cnt_mul_inst;
  reg [63:0] cnt_alu_inst;
  reg [63:0] cnt_lsu_inst;
  reg [63:0] cnt_staddr_inst;

  always @(posedge clk)
  begin
    cpu_awlen[3:0]   <= `SOC_TOP.x_axi_slave128.awlen[3:0];
    cpu_awaddr[31:0] <= `SOC_TOP.x_axi_slave128.mem_addr[31:0];
    cpu_wvalid       <= `SOC_TOP.biu_pad_wvalid;
    cpu_wstrb        <= `SOC_TOP.biu_pad_wstrb;
    // value0           <= `CPU_TOP.core0_pad_wb0_data[63:0];
    // value1           <= `CPU_TOP.core0_pad_wb1_data[63:0];
    // value2           <= `CPU_TOP.core0_pad_wb2_data[63:0];
    value0              <= `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_iu_top.x_ct_iu_rbus.rbus_pipe0_wb_data[63:0];
    value1              <= `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_iu_top.x_ct_iu_rbus.rbus_pipe1_wb_data[63:0];
    value2              <= `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_lsu_top.x_ct_lsu_ld_wb.ld_wb_preg_data_sign_extend[63:0];
  end

  always @(posedge clk)
  begin
    cnt_inhibit         <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mcntinhbt_value[63:0];
    cnt_cycle           <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.x_hpcp_mcycle.cnt_value[63:0];
    cnt_retire          <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.x_hpcp_minstret.cnt_value[63:0];
    /*cnt3                <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.x_hpcp_mhpmcnt3.cnt_value[63:0];
    cnt4                <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.x_hpcp_mhpmcnt4.cnt_value[63:0];
    cnt5                <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.x_hpcp_mhpmcnt5.cnt_value[63:0];
    cnt6                <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.x_hpcp_mhpmcnt6.cnt_value[63:0];
    cnt7                <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.x_hpcp_mhpmcnt7.cnt_value[63:0];
    cnt8                <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.x_hpcp_mhpmcnt8.cnt_value[63:0];
    cnt9                <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.x_hpcp_mhpmcnt9.cnt_value[63:0];
    cnt10               <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.x_hpcp_mhpmcnt10.cnt_value[63:0];
    cnt11               <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.x_hpcp_mhpmcnt11.cnt_value[63:0];
    cnt12               <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.x_hpcp_mhpmcnt12.cnt_value[63:0];
    cnt13               <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.x_hpcp_mhpmcnt13.cnt_value[63:0];
    cnt14               <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.x_hpcp_mhpmcnt14.cnt_value[63:0];
    cnt15               <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.x_hpcp_mhpmcnt15.cnt_value[63:0];
    cnt16               <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.x_hpcp_mhpmcnt16.cnt_value[63:0];
    cnt17               <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.x_hpcp_mhpmcnt17.cnt_value[63:0];
    cnt18               <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.x_hpcp_mhpmcnt18.cnt_value[63:0];

    cnt3_select_event   <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt3_value;
    cnt4_select_event   <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt4_value;
    cnt5_select_event   <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt5_value;
    cnt6_select_event   <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt6_value;
    cnt7_select_event   <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt7_value;
    cnt8_select_event   <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt8_value;
    cnt9_select_event   <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt9_value;
    cnt10_select_event  <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt10_value;
    cnt11_select_event  <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt11_value;
    cnt12_select_event  <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt12_value;
    cnt13_select_event  <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt13_value;
    cnt14_select_event  <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt14_value;
    cnt15_select_event  <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt15_value;
    cnt16_select_event  <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt16_value;
    cnt17_select_event  <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt17_value;
    cnt18_select_event  <= `CPU_TOP.x_ct_top_0.x_ct_hpcp_top.mhpmevt18_value;*/

    if(`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_id_ctrl.ctrl_ir_stall == 0)
      begin
      pipedown_inst0_vld <= `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_id_ctrl.ctrl_id_pipedown_inst0_vld;
      pipedown_inst1_vld <= `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_id_ctrl.ctrl_id_pipedown_inst1_vld;
      pipedown_inst2_vld <= `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_id_ctrl.ctrl_id_pipedown_inst2_vld;
      pipedown_inst3_vld <= `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_id_ctrl.ctrl_id_pipedown_inst3_vld;
      cnt_frontend_bubbles[63:0] <= cnt_frontend_bubbles[63:0] + !pipedown_inst0_vld + !pipedown_inst1_vld + !pipedown_inst2_vld + !pipedown_inst3_vld;
      cnt_decoded_uops[63:0] <= cnt_decoded_uops[63:0] + pipedown_inst0_vld + pipedown_inst1_vld + pipedown_inst2_vld + pipedown_inst3_vld;
    end

    //cnt_lsiq_ctrl_full[63:0] <= cnt_lsiq_ctrl_full[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_id_ctrl.ctrl_ir_stall && (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.lsiq_ctrl_full || `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.lsiq_ctrl_full_updt));
    //cnt_sdiq_ctrl_full[63:0] <=  cnt_sdiq_ctrl_full[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_id_ctrl.ctrl_ir_stall && (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.sdiq_ctrl_full || `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.sdiq_ctrl_full_updt));
    //cnt_aiq0_ctrl_full[63:0] <= cnt_aiq0_ctrl_full[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_id_ctrl.ctrl_ir_stall && (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.aiq0_ctrl_full || `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.aiq0_ctrl_full_updt));
    //cnt_aiq1_ctrl_full[63:0] <= cnt_aiq1_ctrl_full[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_id_ctrl.ctrl_ir_stall && (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.aiq1_ctrl_full || `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.aiq1_ctrl_full_updt));
    //cnt_biq_ctrl_full[63:0] <= cnt_biq_ctrl_full[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_id_ctrl.ctrl_ir_stall && (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.biq_ctrl_full || `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.biq_ctrl_full_updt));

    //cnt_lsiq_ctrl_full[63:0] <= cnt_lsiq_ctrl_full[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.lsiq_ctrl_full || `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.lsiq_ctrl_full_updt);
    //cnt_sdiq_ctrl_full[63:0] <=  cnt_sdiq_ctrl_full[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.sdiq_ctrl_full || `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.sdiq_ctrl_full_updt);
    //cnt_aiq0_ctrl_full[63:0] <= cnt_aiq0_ctrl_full[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.aiq0_ctrl_full || `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.aiq0_ctrl_full_updt);
    //cnt_aiq1_ctrl_full[63:0] <= cnt_aiq1_ctrl_full[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.aiq1_ctrl_full || `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.aiq1_ctrl_full_updt);
    //cnt_viq0_ctrl_full[63:0] <= cnt_viq0_ctrl_full[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.viq0_ctrl_full || `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.viq0_ctrl_full_updt);
    //cnt_viq1_ctrl_full[63:0] <= cnt_viq1_ctrl_full[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.viq1_ctrl_full || `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.viq1_ctrl_full_updt);
    //cnt_biq_ctrl_full[63:0] <= cnt_biq_ctrl_full[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.biq_ctrl_full;
    cnt_lsiq_ctrl_full[63:0] <= cnt_lsiq_ctrl_full[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.ctrl_is_lsiq_full_updt;
    cnt_sdiq_ctrl_full[63:0] <=  cnt_sdiq_ctrl_full[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.ctrl_is_sdiq_full_updt;
    cnt_aiq0_ctrl_full[63:0] <= cnt_aiq0_ctrl_full[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.ctrl_is_aiq0_full_updt;
    cnt_aiq1_ctrl_full[63:0] <= cnt_aiq1_ctrl_full[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.ctrl_is_aiq1_full_updt;
    cnt_viq0_ctrl_full[63:0] <= cnt_viq0_ctrl_full[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.ctrl_is_viq0_full_updt;
    cnt_viq1_ctrl_full[63:0] <= cnt_viq1_ctrl_full[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.ctrl_is_viq1_full_updt;
    cnt_biq_ctrl_full[63:0] <= cnt_biq_ctrl_full[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.ctrl_is_biq_full_updt;

    cnt_ctrl_ir_stall[63:0] <= cnt_ctrl_ir_stall[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_stall;
    cnt_ctrl_ir_stage_stall[63:0] <= cnt_ctrl_ir_stage_stall[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ir_inst0_vld && `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_stage_stall);
    cnt_ctrl_is_stall[63:0] <= cnt_ctrl_is_stall[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ir_inst0_vld && `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_is_stall);
    cnt_ctrl_ir_stage_is_both_stall[63:0] <= cnt_ctrl_ir_stage_is_both_stall[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ir_inst0_vld && `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_stage_stall && `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_is_stall);

    cnt_ctrl_ir_preg_stall[63:0] <= cnt_ctrl_ir_preg_stall[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ir_inst0_vld && `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_preg_stall);
    cnt_ctrl_ir_vreg_stall[63:0] <= cnt_ctrl_ir_vreg_stall[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ir_inst0_vld && `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_vreg_stall);
    cnt_ctrl_ir_freg_stall[63:0] <= cnt_ctrl_ir_freg_stall[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ir_inst0_vld && `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_freg_stall);
    cnt_ctrl_ir_ereg_stall[63:0] <= cnt_ctrl_ir_ereg_stall[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ir_inst0_vld && `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_ereg_stall);
    cnt_rtu_idu_flush_stall[63:0] <= cnt_rtu_idu_flush_stall[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ir_inst0_vld && `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.rtu_idu_flush_stall);
    cnt_iu_idu_mispred_stall[63:0] <= cnt_iu_idu_mispred_stall[63:0] + (`CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ir_inst0_vld && `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.iu_idu_mispred_stall);
    cnt_ctrl_is_dis_stall[63:0] <= cnt_ctrl_is_dis_stall[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.ctrl_is_dis_stall;
    cnt_is_dis_type_stall[63:0] <= cnt_is_dis_type_stall[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.is_dis_type_stall;
    cnt_ctrl_is_rob_full[63:0] <= cnt_ctrl_is_rob_full[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.ctrl_is_rob_full;
    cnt_ctrl_is_iq_full[63:0] <= cnt_ctrl_is_iq_full[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.ctrl_is_iq_full;
    cnt_ctrl_is_vmb_full[63:0] <= cnt_ctrl_is_vmb_full[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_is_ctrl.ctrl_is_vmb_full;

    cnt_div_inst[63:0] <= cnt_div_inst[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ir_pipedown_inst0_ctrl_info[2]
                          + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ir_pipedown_inst1_ctrl_info[2]
                          + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ir_pipedown_inst2_ctrl_info[2]
                          + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ir_pipedown_inst3_ctrl_info[2];
    cnt_special_inst[63:0] <= cnt_special_inst[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ir_pipedown_inst0_ctrl_info[8]
                          + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ir_pipedown_inst1_ctrl_info[8]
                          + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ir_pipedown_inst2_ctrl_info[8]
                          + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ir_pipedown_inst3_ctrl_info[8];
    cnt_mul_inst[63:0] <= cnt_mul_inst[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_inst0_aiq1_bef_dlb
                          + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_inst1_aiq1_bef_dlb
                          + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_inst2_aiq1_bef_dlb
                          + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_inst3_aiq1_bef_dlb;
    cnt_alu_inst[63:0] <= cnt_alu_inst[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_inst0_aiq01_bef_dlb
                          + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_inst1_aiq01_bef_dlb
                          + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_inst2_aiq01_bef_dlb
                          + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_inst3_aiq01_bef_dlb;
    cnt_lsu_inst[63:0] <= cnt_lsu_inst[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_inst0_lsiq
                          + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_inst1_lsiq
                          + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_inst2_lsiq
                          + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_inst3_lsiq;
    cnt_staddr_inst[63:0] <= cnt_staddr_inst[63:0] + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_inst0_sdiq
                          + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_inst1_sdiq
                          + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_inst2_sdiq
                          + `CPU_TOP.x_ct_top_0.x_ct_core.x_ct_idu_top.x_ct_idu_ir_ctrl.ctrl_ir_inst3_sdiq;

      if(value0 == 64'h444333222 || value1 == 64'h444333222 || value2 == 64'h444333222)
    begin
      FILE = $fopen("perf_openc910.txt", "w");
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0: retire, %0d", cnt_cycle, cnt_retire);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0: frontend_bubbles, %0d", cnt_cycle, cnt_frontend_bubbles);
      //$fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0: decoded_uops, %0d", cnt_cycle, cnt_decoded_uops);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0: bad_spec, %0d", cnt_cycle, cnt_decoded_uops - cnt_retire);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0: backend, %0d", cnt_cycle, cnt_cycle * 4 - cnt_retire - cnt_frontend_bubbles - (cnt_decoded_uops - cnt_retire));
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0: ir_stall, %0d", cnt_cycle, cnt_ctrl_ir_stall);
      //$fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0: ir_stage_is_both_stall, %0d", cnt_cycle, cnt_ctrl_ir_stage_is_both_stall);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0: ir_stage_stall, %0d", cnt_cycle, cnt_ctrl_ir_stage_stall);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0:     ir_preg_stall, %0d", cnt_cycle, cnt_ctrl_ir_preg_stall);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0:     ir_vreg_stall, %0d", cnt_cycle, cnt_ctrl_ir_vreg_stall);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0:     ir_freg_stall, %0d", cnt_cycle, cnt_ctrl_ir_freg_stall);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0:     ir_ereg_stall, %0d", cnt_cycle, cnt_ctrl_ir_ereg_stall);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0:     rtu_idu_flush_stall, %0d", cnt_cycle, cnt_rtu_idu_flush_stall);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0:     iu_idu_mispred_stall, %0d", cnt_cycle, cnt_iu_idu_mispred_stall);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0: is_stall, %0d", cnt_cycle, cnt_ctrl_is_stall);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0:     is_dis_type_stall, %0d", cnt_cycle, cnt_is_dis_type_stall);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0:     is_dis_stall, %0d", cnt_cycle, cnt_ctrl_is_dis_stall);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0:         is_rob_full, %0d", cnt_cycle, cnt_ctrl_is_rob_full);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0:         is_vmb_full, %0d", cnt_cycle, cnt_ctrl_is_vmb_full);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0:         is_iq_full, %0d", cnt_cycle, cnt_ctrl_is_iq_full);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0:             lsiq_ctrl_full, %0d", cnt_cycle, cnt_lsiq_ctrl_full);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0:             sdiq_ctrl_full, %0d", cnt_cycle, cnt_sdiq_ctrl_full);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0:             aiq0_ctrl_full, %0d", cnt_cycle, cnt_aiq0_ctrl_full);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0:             aiq1_ctrl_full, %0d", cnt_cycle, cnt_aiq1_ctrl_full);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0:             viq0_ctrl_full, %0d", cnt_cycle, cnt_viq0_ctrl_full);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0:             viq1_ctrl_full, %0d", cnt_cycle, cnt_viq1_ctrl_full);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0:             biq_ctrl_full, %0d", cnt_cycle, cnt_biq_ctrl_full);
      $fdisplay(FILE, "\n");
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0: div_inst, %0d", cnt_cycle, cnt_div_inst);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0: special_inst, %0d", cnt_cycle, cnt_special_inst);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0: mul_inst, %0d", cnt_cycle, cnt_mul_inst);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0: alu_inst, %0d", cnt_cycle, cnt_alu_inst);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0: lsu_inst, %0d", cnt_cycle, cnt_lsu_inst);
      $fdisplay(FILE, "[PERF ][time= %0d] TOP.x_ct_top_0: staddr_inst, %0d", cnt_cycle, cnt_staddr_inst);
      $fdisplay(FILE, "\n");
      /*$fdisplay(FILE, "[PERF ][time= %0d] %0s, %0d", cnt_cycle, EVENT_NAME[cnt3_select_event], cnt3);
      $fdisplay(FILE, "[PERF ][time= %0d] %0s, %0d", cnt_cycle, EVENT_NAME[cnt4_select_event], cnt4);
      $fdisplay(FILE, "[PERF ][time= %0d] %0s, %0d", cnt_cycle, EVENT_NAME[cnt5_select_event], cnt5);
      $fdisplay(FILE, "[PERF ][time= %0d] %0s, %0d", cnt_cycle, EVENT_NAME[cnt6_select_event], cnt6);
      $fdisplay(FILE, "[PERF ][time= %0d] %0s, %0d", cnt_cycle, EVENT_NAME[cnt7_select_event], cnt7);
      $fdisplay(FILE, "[PERF ][time= %0d] %0s, %0d", cnt_cycle, EVENT_NAME[cnt8_select_event], cnt8);
      $fdisplay(FILE, "[PERF ][time= %0d] %0s, %0d", cnt_cycle, EVENT_NAME[cnt9_select_event], cnt9);
      $fdisplay(FILE, "[PERF ][time= %0d] %0s, %0d", cnt_cycle, EVENT_NAME[cnt10_select_event], cnt10);
      $fdisplay(FILE, "[PERF ][time= %0d] %0s, %0d", cnt_cycle, EVENT_NAME[cnt11_select_event], cnt11);
      $fdisplay(FILE, "[PERF ][time= %0d] %0s, %0d", cnt_cycle, EVENT_NAME[cnt12_select_event], cnt12);
      $fdisplay(FILE, "[PERF ][time= %0d] %0s, %0d", cnt_cycle, EVENT_NAME[cnt13_select_event], cnt13);
      $fdisplay(FILE, "[PERF ][time= %0d] %0s, %0d", cnt_cycle, EVENT_NAME[cnt14_select_event], cnt14);
      $fdisplay(FILE, "[PERF ][time= %0d] %0s, %0d", cnt_cycle, EVENT_NAME[cnt15_select_event], cnt15);
      $fdisplay(FILE, "[PERF ][time= %0d] %0s, %0d", cnt_cycle, EVENT_NAME[cnt16_select_event], cnt16);
      $fdisplay(FILE, "[PERF ][time= %0d] %0s, %0d", cnt_cycle, EVENT_NAME[cnt17_select_event], cnt17);
      $fdisplay(FILE, "[PERF ][time= %0d] %0s, %0d", cnt_cycle, EVENT_NAME[cnt18_select_event], cnt18);*/


      $display("**********************************************");
      $display("*    simulation finished successfully        *");
      $display("**********************************************");
     //#10;
     FILE = $fopen("run_case.report","w");
     $fwrite(FILE,"TEST PASS");

     $finish;
    end
      else if (value0 == 64'h2382348720 || value1 == 64'h2382348720 || value2 == 64'h444333222)
    begin
     $display("**********************************************");
     $display("*    simulation finished with error          *");
     $display("**********************************************");
     //#10;
     FILE = $fopen("run_case.report","w");
     $fwrite(FILE,"TEST FAIL");

     $finish;
    end

    else if((cpu_awlen[3:0] == 4'b0) &&
  //     (cpu_awaddr[31:0] == 32'h6000fff8) &&
  //     (cpu_awaddr[31:0] == 32'h0003fff8) &&
       (cpu_awaddr[31:0] == 32'h01ff_fff0) &&
        cpu_wvalid &&
       `clk_en)
    begin
     if(cpu_wstrb[15:0] == 16'hf)
     begin
        $write("%c", `SOC_TOP.biu_pad_wdata[7:0]);
     end
     else if(cpu_wstrb[15:0] == 16'hf0)
     begin
        $write("%c", `SOC_TOP.biu_pad_wdata[39:32]);
     end
     else if(cpu_wstrb[15:0] == 16'hf00)
     begin
        $write("%c", `SOC_TOP.biu_pad_wdata[71:64]);
     end
     else if(cpu_wstrb[15:0] == 16'hf000)
     begin
        $write("%c", `SOC_TOP.biu_pad_wdata[103:96]);
     end
    end

  end



  parameter cpu_cycle = 110;
  `ifndef NO_DUMP
  initial
  begin
  `ifdef NC_SIM
    $dumpfile("test.vcd");
    $dumpvars;
  `else
    `ifdef IVERILOG_SIM
      $dumpfile("test.vcd");
      $dumpvars;
    `else
      $dumpfile("test.vcd");
      $dumpvars;
    `endif
  `endif
  end
  `endif

  assign jtg_tdi = 1'b0;
  assign uart0_sin = 1'b1;


  soc x_soc(
    .i_pad_clk           ( clk                  ),
    .b_pad_gpio_porta    ( b_pad_gpio_porta     ),
    .i_pad_jtg_trst_b    ( jrst_b               ),
    .i_pad_jtg_tclk      ( jclk                 ),
    .i_pad_jtg_tdi       ( jtg_tdi              ),
    .i_pad_jtg_tms       ( jtg_tms              ),
    .i_pad_uart0_sin     ( uart0_sin            ),
    .o_pad_jtg_tdo       ( jtg_tdo              ),
    .o_pad_uart0_sout    ( uart0_sout           ),
    .i_pad_rst_b         ( rst_b                )
  );

  int_mnt x_int_mnt(
  );

  // debug_stim x_debug_stim(
  // );

// Latest Power control
`ifdef UPF_INCLUDED
  import UPF::*;

  initial
  begin
        supply_on ("VDD", 1.00);
     	supply_on ("VDDG", 1.00);
  end

  initial
  begin
    $deposit(top.x_soc.pmu_cpu_pwr_on,  1'b1);
    $deposit(top.x_soc.pmu_cpu_iso_in,  1'b0);
    $deposit(top.x_soc.pmu_cpu_iso_out, 1'b0);
    $deposit(top.x_soc.pmu_cpu_save,    1'b0);
    $deposit(top.x_soc.pmu_cpu_restore, 1'b0);
  end
`endif

  reg [31:0] virtual_counter;

  always @(posedge `CPU_CLK or negedge `CPU_RST)
  begin
    if(!`CPU_RST)
      virtual_counter[31:0] <= 32'b0;
    else if(virtual_counter[31:0]==32'hffffffff)
      virtual_counter[31:0] <= virtual_counter[31:0];
    else
      virtual_counter[31:0] <= virtual_counter[31:0] +1'b1;
  end

  //always @(*)
  //begin
  //if(virtual_counter[31:0]> 32'h3000000) $finish;
  //end

endmodule
