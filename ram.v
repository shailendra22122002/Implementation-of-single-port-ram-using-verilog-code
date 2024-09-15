`include "defines.v"
module ram(clk,rstn,en,addr,wr_rd,data_in,
data_out,out_en);
input clk,rstn,en,wr_rd;
//input [7:0]data_in;//it can deals with only 1 byte data
input [`data_width-1:0] data_in;
input [`addr_width-1:0] addr;
output reg [`data_width-1:0] data_out;
output reg out_en;

// memory declaration

reg [`data_width-1:0] mem[`depth-1:0];
//local var
integer i;
always @(posedge clk)
    if(en)
    begin
        if(!rstn)
        begin
            data_out <=0;
            for(i=0;i<(2**`addr_width);i=i+1)
            begin
                mem[i] =0;
                $display("mem=%P",mem);
            end
            
        end
        else
        begin
            if (wr_rd==1)
            begin //write operation
                mem[addr]<= data_in;
            end
            else
            begin // read Opeartion
                data_out <=mem[addr];
                out_en <=1;
                @(posedge clk);
                out_en <=0;
            end
        end

    end
    else
        $display("ram is disabled");


endmodule