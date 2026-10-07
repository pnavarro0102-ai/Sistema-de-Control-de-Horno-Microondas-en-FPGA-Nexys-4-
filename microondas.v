`timescale 1ns / 1ps

module microondas(

    input clk,
    input push_A,  //Boton de start
    input push_B,  //Boton de 1s 
    input push_C,  //Boton de 10s
    input push_D,  //Boton de 60s 
    input push_pause, //Boton de pausa y cancelar
    input SW1,        //Descongelar
    input SW2,        //Palomitas
    input SW3,        //Mantequilla
    input SW4,        //Pizza 
    input SW5,
    output aux,
    output amp,
    output wire [0:6] segment,
    output wire [0:7] segment_off,
    output wire [0:15] leds

);
    
    //Cable para clock de los displays
    wire clock;
    
    //Cable para clock de la maquina de estados
    wire clock_s;
    
    //Cable del clock para la cuenta regresiva
    wire clock_r;
    
    //Cable del clock para los leds
    wire clock_l;
    
    //Cables del divisor 
    wire [3:0] new_variable;

    //Cable para los estados
    wire [3:0] M_state;
   
    //Cables del reloj
    wire [6:0] seg;
    wire [6:0] min;
    wire [5:0] hrs;
    
    //Cables del reloj modificado
    wire [6:0] seg_N;
    wire [6:0] min_N;
    wire [5:0] hrs_N;
   
    //Contador del tiempo
    wire [11:0] cont;
    
    //Contador regresivo
    wire [11:0] cont_R;
    
    //Cables del sonido
    wire clock_suma;
    wire clock_resta; 
    wire clock_multi;
    wire clock_div;
    
    //Cables del conversor BCD
    wire [11:0] out_BCD;
    wire [3:0] unidades;
    wire [3:0] decenas;
    wire [3:0] centenas;
    
    //Cables del conversor BCD para cuenta regresiva
    wire [11:0] out_BCD_R;
    wire [3:0] unidades_R;
    wire [3:0] decenas_R;
    wire [3:0] centenas_R;
    
    //Cables del conversor BCD para los segundos
    wire [11:0] out_BCD_S;
    wire [3:0] unidades_S;
    wire [3:0] decenas_S;
    
    //Cables del conversor BCD para los minutos
    wire [11:0] out_BCD_M;
    wire [3:0] unidades_M;
    wire [3:0] decenas_M;
    
    //Cables del conversor BCD para las horas
    wire [11:0] out_BCD_H;
    wire [3:0] unidades_H;
    wire [3:0] decenas_H;
    
    //Cables del conversor BCD que muestra la modificación de los segundos
    wire [11:0] out_BCD_Sn;
    wire [3:0] unidades_Sn;
    wire [3:0] decenas_Sn;
    
    //Cables del conversor BCD que muestra la modificación de los minutos
    wire [11:0] out_BCD_Mn;
    wire [3:0] unidades_Mn;
    wire [3:0] decenas_Mn;
    
    //Cables del conversor BCD que muestra la modificación de las horas
    wire [11:0] out_BCD_Hn;
    wire [3:0] unidades_Hn;
    wire [3:0] decenas_Hn;
    
   
    //Para los estados
    frecuency_Div_states(.clk(clk), .divided_clock(clock_s));
    
    //Para los la cuenta regresiva
    frecuency_Div_R(.clk(clk), .divided_clock(clock_r));
    
    //Divisor de frecuencia
    frecuency_Div(.clk(clk), .divided_clock(clock), .new_variable(new_variable));
   
    //Para el parpadeo de los leds
    frecuency_Div_leds(.clk(clk), .divided_clock(clock_l));
    
    
    //Maquina de estados
    Estados(.clock_s(clock_s), .push_pause(push_pause), .push_A(push_A), .push_B(push_B), .push_C(push_C), .push_D(push_D),
            .cont(cont), .state(M_state), .SW1(SW1), .SW2(SW2), .SW3(SW3), .SW4(SW4), .SW5(SW5), .seg_N(seg_N), .min_N(min_N),
            .hrs_N(hrs_N));
                 
    //reloj        
    reloj(.clock_c(clock_r), .seg(seg), .min(min), .hrs(hrs), .seg_N(seg_N), .min_N(min_N), .hrs_N(hrs_N), .state(M_state));
    
    //Muestra los displays
    displays(.segment_off(segment_off), .segment(segment), .clock(clock), .new_variable(new_variable), .state(M_state), 
             .cont(cont), .unidades(unidades), .decenas(decenas), .centenas(centenas), .unidades_R(unidades_R), 
             .decenas_R(decenas_R), .centenas_R(centenas_R), .unidades_S(unidades_S), .decenas_S(decenas_S),
             .unidades_M(unidades_M), .decenas_M(decenas_M), .unidades_H(unidades_H), .decenas_H(decenas_H),
             .unidades_Sn(unidades_Sn), .decenas_Sn(decenas_Sn),.unidades_Mn(unidades_Mn), .decenas_Mn(decenas_Mn), 
             .unidades_Hn(unidades_Hn), .decenas_Hn(decenas_Hn));
             
    //Sonido de los botones
    audio(.clk(clk), .aux(aux), .amp(amp), .push_A(push_A), .push_B(push_B), .push_C(push_C), .push_D(push_D), 
          .push_pause(push_pause), .cont_R(cont_R), .done(done), .state(M_state));
    
    //cuenta regresiva
    cuenta_regresiva(.clock_r(clock_r), .state(M_state), .initial_count(cont), .cont_R(cont_R), .done());
    
    //Leds
    leds(.clock_l(clock_l), .cont_R(cont_R), .state(M_state), .leds(leds));
    
    //Convertidor BCD
    conversor_BCD(.bin(cont), .bcd(out_BCD));
   
    assign unidades = out_BCD [3:0] ;
    assign decenas = out_BCD [7:4] ;
    assign centenas = out_BCD [11:8] ;
    
    //Convertidor BCD para cuenta regresiva
    conversor_BCD_R(.bin(cont_R), .bcd(out_BCD_R));
    
    assign unidades_R = out_BCD_R [3:0] ;
    assign decenas_R = out_BCD_R [7:4] ;
    assign centenas_R = out_BCD_R [11:8] ;
    
    //Convertidor BCD para segundos
    conversor_BCD_Seg(.bin(seg), .bcd(out_BCD_S));
    
    assign unidades_S = out_BCD_S [3:0] ;
    assign decenas_S = out_BCD_S [7:4] ;
    
    //Convertidor BCD para minutos
    conversor_BCD_Min(.bin(min), .bcd(out_BCD_M));
    
    assign unidades_M = out_BCD_M [3:0] ;
    assign decenas_M = out_BCD_M [7:4] ;
    
    //Convertidor BCD para horas
    conversor_BCD_Hrs(.bin(hrs), .bcd(out_BCD_H));
     
    assign unidades_H = out_BCD_H [3:0] ;
    assign decenas_H = out_BCD_H [7:4] ;
    
    //Convertidor BCD para segundos modificados
    conversor_BCD_SegN(.bin(seg_N), .bcd(out_BCD_Sn));
    
    assign unidades_Sn = out_BCD_Sn [3:0] ;
    assign decenas_Sn = out_BCD_Sn [7:4] ;
    
    //Convertidor BCD para minutos modificados
    conversor_BCD_MinN(.bin(min_N), .bcd(out_BCD_Mn));
    
    assign unidades_Mn = out_BCD_Mn [3:0] ;
    assign decenas_Mn = out_BCD_Mn [7:4] ;
    
    //Convertidor BCD para horas modificadas
    conversor_BCD_HrsN(.bin(hrs_N), .bcd(out_BCD_Hn));
     
    assign unidades_Hn = out_BCD_Hn [3:0] ;
    assign decenas_Hn = out_BCD_Hn [7:4] ;
    
    
endmodule


//Maquina de estados finitos
module Estados(

    input wire clock_s,
    input wire push_pause,
    input wire push_A,
    input wire push_B,
    input wire push_C,
    input wire push_D,
    input wire SW1,
    input wire SW2,
    input wire SW3,
    input wire SW4,
    input wire SW5, 
    output reg [3:0] state,
    output reg [11:0] cont,
    output reg [6:0] seg_N,
    output reg [6:0] min_N,
    output reg [5:0] hrs_N

);

    localparam S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0010, S3 = 4'b0011, S4 = 4'b0100, S5 = 4'b0101, S6 = 4'b0110, S7 = 4'b0111,
               S8 = 4'b1000, S9 = 4'b1001 ;
    
    always @(posedge clock_s) begin
    
        if (push_pause && SW5 == 0) begin 
        
            cont = 0;
            state <= S0;  // Estado inicial
           
        end 
            
        else begin
        
            if (push_A && SW5 == 0)begin //Estado donde empieza la cuenta regresiva
               
               state <= S1;
      
            end 
            else if (push_B && SW5 == 0)begin //Suma 1 segundo
            
               cont = cont + 1;
               state <= S2;
                
            end 
            else if (push_C && SW5 == 0)begin //Suma 10 segundos
               
               cont = cont + 10;
               state <= S3;
                
            end 
            else if (push_D && SW5 == 0)begin //Suma 60 segundos
            
                cont = cont + 60;
                state <= S4;
            
            end
            else if (SW1 && SW5 == 0)begin //Descongelar
                
                cont = 20;
                state <= S5;
            
            end
            else if (SW2 && SW5 == 0)begin //Palomitas
            
                cont = 30;
                state <= S6;
            
            end
            else if (SW3 && SW5 == 0)begin //Mantequilla
            
                cont = 5;
                state <= S7;
            
            end
            else if (SW4 && SW5 == 0)begin //Pizza
            
                cont = 15;
                state <= S8;
            
            end
            else if(SW5)begin
            
                if(push_B && SW5 == 1)begin
                   
                    if(seg_N == 59)begin
                    
                        seg_N = 0;
                        state <= S9;
                    end
                    else begin 
                    
                        seg_N = seg_N + 1;
                        state <= S9;
                    
                    end
                
                end
                if(push_C && SW5 == 1)begin
                
                    if(min_N == 59)begin
                    
                        min_N = 0;
                        state <= S9;
                                            
                    end 
                    else begin
                    
                        min_N = min_N + 1;
                        state <= S9;
                    
                    end
                
                end
                if(push_D && SW5 == 1)begin
                
                    if(hrs_N == 23)begin
                    
                        hrs_N = 0;
                        state <= S9;
                    
                    end
                    else begin
                    
                        hrs_N = hrs_N + 1;
                        state <= S9;
                    
                    end
                
                end
            
            end
                
        end
   end

endmodule 

module frecuency_Div_R(

    input wire clk,
    output reg divided_clock
    
);

parameter DIVISOR = 50000000;

reg [26:0] counter = 0;

always @(posedge clk) begin

    counter <= counter + 1;
    
    if (counter >= (DIVISOR - 1)) begin
    
        counter <= 0;
        divided_clock <= ~divided_clock; 
        
     
    end
end
endmodule

module frecuency_Div_states(

    input wire clk,
    output reg divided_clock
    
);

parameter DIVISOR = 10000000;

reg [25:0] counter = 0;

always @(posedge clk) begin

    counter <= counter + 1;
    
    if (counter >= (DIVISOR - 1)) begin
    
        counter <= 0;
        divided_clock <= ~divided_clock; 
        
     
    end
end

endmodule



//Divisor de frecuencia
module frecuency_Div(

    input wire clk,
    output reg divided_clock,
    output reg [3:0] new_variable
    
);

    parameter DIVISOR = 30000;
    reg [15:0] counter = 0;
 

    always @(posedge clk) begin

        counter <= counter + 1;
    
        if (counter >= (DIVISOR - 1)) begin
    
            counter <= 0;
            new_variable <= new_variable + 1;
            divided_clock <= ~divided_clock; 
     
        end
    
        if (new_variable > 6) begin
    
            new_variable <= 0;
       
        end
    
    end

endmodule

module frecuency_Div_leds(

    input wire clk,
    output reg divided_clock
    
);

parameter DIVISOR = 50000000;

reg [31:0] counter = 0;

always @(posedge clk) begin

    counter <= counter + 1;
    
    if (counter >= (DIVISOR - 1)) begin
    
        counter <= 0;
        divided_clock <= ~divided_clock; 
        
     
    end
end

endmodule

//Muestra los displays
module displays(
    
    input wire clock,
    input wire [3:0] state,
    input wire [3:0] new_variable,
    input wire [6:0] cont,
    input wire [3:0] unidades, 
    input wire [3:0] decenas,
    input wire [3:0] centenas,
    input wire [3:0] unidades_R, 
    input wire [3:0] decenas_R,
    input wire [3:0] centenas_R,
    input wire [3:0] unidades_S, 
    input wire [3:0] decenas_S,
    input wire [3:0] unidades_M, 
    input wire [3:0] decenas_M,
    input wire [3:0] unidades_H, 
    input wire [3:0] decenas_H,
    input wire [3:0] unidades_Sn, 
    input wire [3:0] decenas_Sn,
    input wire [3:0] unidades_Mn, 
    input wire [3:0] decenas_Mn,
    input wire [3:0] unidades_Hn, 
    input wire [3:0] decenas_Hn,
    output reg [0:7] segment_off,
    output reg [0:6] segment
    
);

    always @(new_variable) begin
    
        if (state == 4'b0000)begin
            
            if (new_variable == 0)begin
            
                segment_off = 8'b11111111;
                case(unidades_S)
                    0: segment = 7'b0000001;
                    1: segment = 7'b1001111; 
                    2: segment = 7'b0010010;
                    3: segment = 7'b0000110;
                    4: segment = 7'b1001100;
                    5: segment = 7'b0100100;
                    6: segment = 7'b0100000;
                    7: segment = 7'b0001111;
                    8: segment = 7'b0000000;
                    9: segment = 7'b0000100;
                    default: segment_off = 8'b11111111;
                endcase
                segment_off <= 8'b11111110; 
                
            end
            else if(new_variable == 1)begin 
            
               segment_off = 8'b11111111;
               case(decenas_S)
                     0: segment = 7'b0000001;
                     1: segment = 7'b1001111; 
                     2: segment = 7'b0010010;
                     3: segment = 7'b0000110;
                     4: segment = 7'b1001100;
                     5: segment = 7'b0100100;
                     6: segment = 7'b0100000;
                     7: segment = 7'b0001111;
                     8: segment = 7'b0000000;
                     9: segment = 7'b0000100;
                     default: segment_off = 8'b11111111;
               endcase  
               segment_off <= 8'b11111101;
            
            end
            else if(new_variable == 2)begin
            
                segment_off = 8'b11111111;
                   case(unidades_M)
                        0: segment = 7'b0000001;
                        1: segment = 7'b1001111; 
                        2: segment = 7'b0010010;
                        3: segment = 7'b0000110;
                        4: segment = 7'b1001100;
                        5: segment = 7'b0100100;
                        6: segment = 7'b0100000;
                        7: segment = 7'b0001111;
                        8: segment = 7'b0000000;
                        9: segment = 7'b0000100;
                         default: segment_off = 8'b11111111;
                   endcase  
                   segment_off <= 8'b11111011;
            
            end
            else if(new_variable == 3)begin
            
                segment_off = 8'b11111111;
                   case(decenas_M)
                         0: segment = 7'b0000001;
                         1: segment = 7'b1001111; 
                         2: segment = 7'b0010010;
                         3: segment = 7'b0000110;
                         4: segment = 7'b1001100;
                         5: segment = 7'b0100100;
                         6: segment = 7'b0100000;
                         7: segment = 7'b0001111;
                         8: segment = 7'b0000000;
                         9: segment = 7'b0000100;
                         default: segment_off = 8'b11111111;
                   endcase  
                   segment_off <= 8'b11110111;
            
            end
            else if(new_variable == 4)begin
                segment_off = 8'b11111111;
                    case(unidades_H)
                        0: segment = 7'b0000001;
                        1: segment = 7'b1001111; 
                        2: segment = 7'b0010010;
                        3: segment = 7'b0000110;
                        4: segment = 7'b1001100;
                        5: segment = 7'b0100100;
                        6: segment = 7'b0100000;
                        7: segment = 7'b0001111;
                        8: segment = 7'b0000000;
                        9: segment = 7'b0000100;
                         default: segment_off = 8'b11111111;
                   endcase  
                   segment_off <= 8'b11101111;
            
            end
            else if(new_variable == 5)begin
            
             segment_off = 8'b11111111;
                    case(decenas_H)
                         0: segment = 7'b0000001;
                         1: segment = 7'b1001111; 
                         2: segment = 7'b0010010;
                         3: segment = 7'b0000110;
                         4: segment = 7'b1001100;
                         5: segment = 7'b0100100;
                         6: segment = 7'b0100000;
                         7: segment = 7'b0001111;
                         8: segment = 7'b0000000;
                         9: segment = 7'b0000100;
                         default: segment_off = 8'b11111111;
                   endcase  
                   segment_off <= 8'b11011111;
            
            end
            
        end
        else if(state == 4'b0010 || state == 4'b0011 || state == 4'b0100)begin 
        
              if (new_variable <= 2)begin
            
                  segment_off = 8'b11111111;
                       case(unidades)
                           0: segment = 7'b0000001;
                           1: segment = 7'b1001111; 
                           2: segment = 7'b0010010;
                           3: segment = 7'b0000110;
                           4: segment = 7'b1001100;
                           5: segment = 7'b0100100;
                           6: segment = 7'b0100000;
                           7: segment = 7'b0001111;
                           8: segment = 7'b0000000;
                           9: segment = 7'b0000100;
                           default: segment_off = 8'b11111111;
                      endcase
                      segment_off <= 8'b11111110;
                
            end
            else if(new_variable > 2 && new_variable <= 4)begin 
            
                    segment_off = 8'b11111111;
                        case(decenas)
                            0: segment = 7'b0000001;
                            1: segment = 7'b1001111; 
                            2: segment = 7'b0010010;
                            3: segment = 7'b0000110;
                            4: segment = 7'b1001100;
                            5: segment = 7'b0100100;
                            6: segment = 7'b0100000;
                            7: segment = 7'b0001111;
                            8: segment = 7'b0000000;
                            9: segment = 7'b0000100;
                            default: segment_off = 8'b11111111;
                        endcase 
                        segment_off <= 8'b11111101;
                      
            end 
            else if (new_variable > 4)begin 
            
                   segment_off = 8'b11111111;
                         case(centenas)
                             0: segment = 7'b0000001;
                             1: segment = 7'b1001111; 
                             2: segment = 7'b0010010;
                             3: segment = 7'b0000110;
                             4: segment = 7'b1001100;
                             5: segment = 7'b0100100;
                             6: segment = 7'b0100000;
                             7: segment = 7'b0001111;
                             8: segment = 7'b0000000;
                             9: segment = 7'b0000100;
                             default: segment = 7'b1111111;
                          endcase 
                          segment_off <= 8'b11111011; 
                end
            
         end
         else if(state == 4'b0101 || state == 4'b0110 || state == 4'b0111 || state == 4'b1000)begin
            
            if (new_variable < 3)begin
                
                 segment_off = 8'b11111111;
                       case(unidades)
                           0: segment = 7'b0000001;
                           1: segment = 7'b1001111; 
                           2: segment = 7'b0010010;
                           3: segment = 7'b0000110;
                           4: segment = 7'b1001100;
                           5: segment = 7'b0100100;
                           6: segment = 7'b0100000;
                           7: segment = 7'b0001111;
                           8: segment = 7'b0000000;
                           9: segment = 7'b0000100;
                           default: segment_off = 8'b11111111;
                      endcase
                      segment_off <= 8'b11111110;
            
            end
            else if(new_variable >= 3)begin
            
                    segment_off = 8'b11111111;
                        case(decenas)
                            0: segment = 7'b0000001;
                            1: segment = 7'b1001111; 
                            2: segment = 7'b0010010;
                            3: segment = 7'b0000110;
                            4: segment = 7'b1001100;
                            5: segment = 7'b0100100;
                            6: segment = 7'b0100000;
                            7: segment = 7'b0001111;
                            8: segment = 7'b0000000;
                            9: segment = 7'b0000100;
                            default: segment_off = 8'b11111111;
                        endcase 
                        segment_off <= 8'b11111101;    
                        
                end

         
         end
         else if (state == 4'b0001)begin
            
            if (new_variable == 0)begin
            
                segment_off = 8'b11111111;
                case(unidades_R)
                    0: segment = 7'b0000001;
                    1: segment = 7'b1001111; 
                    2: segment = 7'b0010010;
                    3: segment = 7'b0000110;
                    4: segment = 7'b1001100;
                    5: segment = 7'b0100100;
                    6: segment = 7'b0100000;
                    7: segment = 7'b0001111;
                    8: segment = 7'b0000000;
                    9: segment = 7'b0000100;
                    default: segment_off = 8'b11111111;
                endcase
                segment_off <= 8'b11111110; 
                
            end
            else if(new_variable == 1)begin 
            
               segment_off = 8'b11111111;
               case(decenas_R)
                     0: segment = 7'b0000001;
                     1: segment = 7'b1001111; 
                     2: segment = 7'b0010010;
                     3: segment = 7'b0000110;
                     4: segment = 7'b1001100;
                     5: segment = 7'b0100100;
                     6: segment = 7'b0100000;
                     7: segment = 7'b0001111;
                     8: segment = 7'b0000000;
                     9: segment = 7'b0000100;
                     default: segment_off = 8'b11111111;
               endcase  
               segment_off <= 8'b11111101;
            
            end
            else if(new_variable == 2)begin
            
                   segment_off = 8'b11111111;
                   case(centenas_R)
                         0: segment = 7'b0000001;
                         1: segment = 7'b1001111; 
                         2: segment = 7'b0010010;
                         3: segment = 7'b0000110;
                         4: segment = 7'b1001100;
                         5: segment = 7'b0100100;
                         6: segment = 7'b0100000;
                         7: segment = 7'b0001111;
                         8: segment = 7'b0000000;
                         9: segment = 7'b0000100;
                         default: segment_off = 8'b11111111;
                   endcase  
                   segment_off <= 8'b11111011;
            
            end
            
        end
        else if(state == 4'b1001)begin
        
            if (new_variable == 0)begin
            
                segment_off = 8'b11111111;
                case(unidades_Sn)
                    0: segment = 7'b0000001;
                    1: segment = 7'b1001111; 
                    2: segment = 7'b0010010;
                    3: segment = 7'b0000110;
                    4: segment = 7'b1001100;
                    5: segment = 7'b0100100;
                    6: segment = 7'b0100000;
                    7: segment = 7'b0001111;
                    8: segment = 7'b0000000;
                    9: segment = 7'b0000100;
                    default: segment_off = 8'b11111111;
                endcase
                segment_off <= 8'b11111110; 
                
            end
            else if(new_variable == 1)begin 
            
               segment_off = 8'b11111111;
               case(decenas_Sn)
                     0: segment = 7'b0000001;
                     1: segment = 7'b1001111; 
                     2: segment = 7'b0010010;
                     3: segment = 7'b0000110;
                     4: segment = 7'b1001100;
                     5: segment = 7'b0100100;
                     6: segment = 7'b0100000;
                     7: segment = 7'b0001111;
                     8: segment = 7'b0000000;
                     9: segment = 7'b0000100;
                     default: segment_off = 8'b11111111;
               endcase  
               segment_off <= 8'b11111101;
            
            end
            else if(new_variable == 2)begin
            
                segment_off = 8'b11111111;
                   case(unidades_Mn)
                        0: segment = 7'b0000001;
                        1: segment = 7'b1001111; 
                        2: segment = 7'b0010010;
                        3: segment = 7'b0000110;
                        4: segment = 7'b1001100;
                        5: segment = 7'b0100100;
                        6: segment = 7'b0100000;
                        7: segment = 7'b0001111;
                        8: segment = 7'b0000000;
                        9: segment = 7'b0000100;
                         default: segment_off = 8'b11111111;
                   endcase  
                   segment_off <= 8'b11111011;
            
            end
            else if(new_variable == 3)begin
            
                segment_off = 8'b11111111;
                   case(decenas_Mn)
                         0: segment = 7'b0000001;
                         1: segment = 7'b1001111; 
                         2: segment = 7'b0010010;
                         3: segment = 7'b0000110;
                         4: segment = 7'b1001100;
                         5: segment = 7'b0100100;
                         6: segment = 7'b0100000;
                         7: segment = 7'b0001111;
                         8: segment = 7'b0000000;
                         9: segment = 7'b0000100;
                         default: segment_off = 8'b11111111;
                   endcase  
                   segment_off <= 8'b11110111;
            
            end
            else if(new_variable == 4)begin
                segment_off = 8'b11111111;
                    case(unidades_Hn)
                        0: segment = 7'b0000001;
                        1: segment = 7'b1001111; 
                        2: segment = 7'b0010010;
                        3: segment = 7'b0000110;
                        4: segment = 7'b1001100;
                        5: segment = 7'b0100100;
                        6: segment = 7'b0100000;
                        7: segment = 7'b0001111;
                        8: segment = 7'b0000000;
                        9: segment = 7'b0000100;
                         default: segment_off = 8'b11111111;
                   endcase  
                   segment_off <= 8'b11101111;
            
            end
            else if(new_variable == 5)begin
            
             segment_off = 8'b11111111;
                    case(decenas_Hn)
                         0: segment = 7'b0000001;
                         1: segment = 7'b1001111; 
                         2: segment = 7'b0010010;
                         3: segment = 7'b0000110;
                         4: segment = 7'b1001100;
                         5: segment = 7'b0100100;
                         6: segment = 7'b0100000;
                         7: segment = 7'b0001111;
                         8: segment = 7'b0000000;
                         9: segment = 7'b0000100;
                         default: segment_off = 8'b11111111;
                   endcase  
                   segment_off <= 8'b11011111;
            
            end
        
        end
    
    end
    
endmodule

module reloj(

    input wire clock_c,
    input wire [3:0] state,
    input wire [6:0] seg_N,
    input wire [6:0] min_N,
    input wire [5:0] hrs_N,
    output reg [6:0] seg,
    output reg [6:0] min,
    output reg [5:0] hrs
    

);
  // Contador de segundos
    always @(posedge clock_c) begin
    
        if (state != 4'b1001)begin
        
            if (seg == 59) begin
            
                seg <= 0;
                
            end 
            else begin
            
                seg <= seg + 1;

            end
        
        end
        else begin
        
            seg <= seg_N;
        
        end
        
    end

    always @(posedge clock_c) begin
    
        if (state != 4'b1001)begin
    
            if (seg == 59) begin
            
                if (min == 59) begin
                
                    min <= 0;
                    
                end else begin
                
                    min <= min + 1;
                    
                end
            
            end
    
        end
        else begin
        
            min <= min_N;
        
        end
        
    end

    always @(posedge clock_c) begin
   
        if(state != 4'b1001)begin
        
            if (min == 59 && seg == 59) begin
            
                if (hrs == 23) begin
                
                    hrs <= 0;
                    
                end else begin
                
                    hrs <= hrs + 1;
                    
             
                end
            
            end
        
        end
        else begin
        
            hrs <= hrs_N;
        
        end
        
    end  

endmodule

module leds(

    input clock_l,
    input wire [11:0] cont_R,
    input wire [3:0] state,
    output reg [15:0] leds
    
);

    always @(posedge clock_l) begin
    
        if(state == 4'b0001 && cont_R == 0)begin
        
            leds <= ~leds;
        
        end
        else begin
            
            leds <= 0;
        
        end
    
    end


endmodule


module cuenta_regresiva(

  input wire clock_r,
  input wire [3:0] state,
  input wire [11:0] initial_count,
  output reg [11:0] cont_R, 
  output reg done =  1'b1

);
   

    always @(posedge clock_r) begin
    
        if (state == 4'b0001) begin
        
            if (cont_R == 0) begin
            
                done <= 1'b1;
                
            end 
            else begin
            
                cont_R <= cont_R - 1;
                done <= 1'b0;
                
            end
        end else begin
        
            cont_R <= initial_count; // asignar valor inicial cuando no est  en estado S1
            
        end
        
    end


endmodule 

module audio_start(

    input wire clk,
    output reg [2:0] divided_clock
    
);
    parameter DIVISOR = 20000;
    reg [14:0] counter = 0;

    always @(posedge clk) begin
    
        if (counter >= (DIVISOR - 1)) begin
        
            counter <= 0;
            
            if (divided_clock == 6)
           
                divided_clock <= 0;
                
            else
            
                divided_clock <= divided_clock + 1;
                
        end 
        else begin
        
            counter <= counter + 1;
            
        end
        
    end
    
endmodule

module audio_1s(

    input wire clk,
    output reg [2:0] divided_clock
    
);
    parameter DIVISOR = 25000;
    reg [14:0] counter = 0;

    always @(posedge clk) begin
    
        if (counter >= (DIVISOR - 1)) begin
        
            counter <= 0;
            
            if (divided_clock == 6)
            
                divided_clock <= 0;
                
            else
            
                divided_clock <= divided_clock + 1;
                
        end 
        else begin
        
            counter <= counter + 1;
            
        end
        
    end
    
endmodule

module audio_10s(

    input wire clk,
    output reg [2:0] divided_clock
    
);
    parameter DIVISOR = 30000;
    reg [14:0] counter = 0;

    always @(posedge clk) begin
    
        if (counter >= (DIVISOR - 1)) begin
        
            counter <= 0;
            
            if (divided_clock == 6)
            
                divided_clock <= 0;
                
            else
                divided_clock <= divided_clock + 1;
                
        end 
        else begin
        
            counter <= counter + 1;
            
        end
        
    end
    
endmodule

module audio_60s(

    input wire clk,
    output reg [2:0] divided_clock
    
);
    parameter DIVISOR = 35000;
    reg [16:0] counter = 0;

    always @(posedge clk) begin
    
        if (counter >= (DIVISOR - 1)) begin
        
            counter <= 0;
            
            if (divided_clock == 6)
            
                divided_clock <= 0;
                
            else
            
                divided_clock <= divided_clock + 1;
                
        end 
        else begin
        
            counter <= counter + 1;
            
        end
        
    end
    
endmodule

module audio_pause(

    input wire clk,
    output reg [2:0] divided_clock
    
);
    parameter DIVISOR = 40000;
    reg [16:0] counter = 0;

    always @(posedge clk) begin
    
        if (counter >= (DIVISOR - 1)) begin
        
            counter <= 0;
            
            if (divided_clock == 6)
            
                divided_clock <= 0;
                
            else
            
                divided_clock <= divided_clock + 1;
                
        end 
        else begin
        
            counter <= counter + 1;
            
        end
        
    end
    
endmodule

module audio_activo(

    input wire clk,
    output reg [2:0] divided_clock
    
);
    parameter DIVISOR = 45000;
    reg [16:0] counter = 0;

    always @(posedge clk) begin
    
        if (counter >= (DIVISOR - 1)) begin
        
            counter <= 0;
            
            if (divided_clock == 6)
            
                divided_clock <= 0;
                
            else
            
                divided_clock <= divided_clock + 1;
                
        end 
        else begin
        
            counter <= counter + 1;
            
        end
        
    end
    
endmodule

module audio_alarma(

    input wire clk,
    output reg [2:0] divided_clock
    
);
    parameter DIVISOR = 30000;
    reg [16:0] counter = 0;

    always @(posedge clk) begin
    
        if (counter >= (DIVISOR - 1)) begin
        
            counter <= 0;
            
            if (divided_clock == 6)
            
                divided_clock <= 0;
                
            else
            
                divided_clock <= divided_clock + 1;
                
        end 
        else begin
        
            counter <= counter + 1;
            
        end
        
    end
    
endmodule

module audio(

    input wire clk,                
    output wire aux,           
    output wire amp,        
    input push_A,
    input push_B,
    input push_C,
    input push_D,
    input push_pause,
    input wire [11:0] cont_R,
    input wire done,
    input wire [3:0] state 
    
);
   
    assign amp = 1;   
    
    audio_start(.clk(clk),.divided_clock(clock_start));
    
    audio_1s(.clk(clk), .divided_clock(clock_1s));
    
    audio_10s(.clk(clk), .divided_clock(clock_10s));
    
    audio_60s(.clk(clk),.divided_clock(clock_60s));
    
    audio_pause(.clk(clk),.divided_clock(clock_pause));
    
    audio_activo(.clk(clk),.divided_clock(clock_activo));
    
    audio_alarma(.clk(clk),.divided_clock(clock_alarma));

    
    reg auxreg;
    assign aux = auxreg;
    
    always @(posedge clk) begin
    
       
        if (clock_start == 1 && push_A) begin
        
            auxreg <= 1;
            
        end 
        else if (clock_1s == 1 && push_B) begin
            
            auxreg <= 1;
            
        end 
        else if (clock_10s == 1 && push_C) begin
           
            auxreg <= 1;
            
        end 
        else if (clock_60s == 1 && push_D) begin
            
            auxreg <= 1;
            
        end 
        else if (clock_pause == 1 && push_pause)begin 
        
            auxreg <= 1;
        
        end
        else if (clock_activo == 1 && cont_R != 0 && state == 4'b0001)begin
        
            auxreg <= 1;
        
        end
        else if(clock_alarma == 1  && cont_R == 0 && state == 4'b0001)begin
        
            auxreg <= 1;
        
        end
        else begin
        
            auxreg <= 0;
            
        end
        
     end   
     
endmodule 

module conversor_BCD

 #( parameter W = 11) 
 
  ( 
  
    input [W-1:0] bin, 
    output reg [W + (W - 4) / 3:0] bcd 
    
   ); 

  integer i,j;

  always @(bin) begin
  
    for(i = 0; i <= W+(W-4)/3; i = i+1) bcd[i] = 0;     
    
        bcd[W-1:0] = bin;     
                                      
    for(i = 0; i <= W-4; i = i+1)                      
    
      for(j = 0; j <= i/3; j = j+1)                     
      
        if (bcd[W-i+4*j -: 4] > 4)                      
        
            bcd[W-i+4*j -: 4] = bcd[W-i+4*j -: 4] + 4'd3; 
            
  end

endmodule

module conversor_BCD_R

 #( parameter W = 11) 
 
  ( 
  
    input [W-1:0] bin, 
    output reg [W + (W - 4) / 3:0] bcd 
    
   ); 

  integer i,j;

  always @(bin) begin
  
    for(i = 0; i <= W+(W-4)/3; i = i+1) bcd[i] = 0;     
    
        bcd[W-1:0] = bin;     
                                      
    for(i = 0; i <= W-4; i = i+1)                      
    
      for(j = 0; j <= i/3; j = j+1)                     
      
        if (bcd[W-i+4*j -: 4] > 4)                      
        
            bcd[W-i+4*j -: 4] = bcd[W-i+4*j -: 4] + 4'd3; 
            
  end

endmodule

module conversor_BCD_Seg

 #( parameter W = 11) 
 
  ( 
  
    input [W-1:0] bin, 
    output reg [W + (W - 4) / 3:0] bcd 
    
   ); 

  integer i,j;

  always @(bin) begin
  
    for(i = 0; i <= W+(W-4)/3; i = i+1) bcd[i] = 0;     
    
        bcd[W-1:0] = bin;     
                                      
    for(i = 0; i <= W-4; i = i+1)                      
    
      for(j = 0; j <= i/3; j = j+1)                     
      
        if (bcd[W-i+4*j -: 4] > 4)                      
        
            bcd[W-i+4*j -: 4] = bcd[W-i+4*j -: 4] + 4'd3; 
            
  end

endmodule

module conversor_BCD_Min

 #( parameter W = 11) 
 
  ( 
  
    input [W-1:0] bin, 
    output reg [W + (W - 4) / 3:0] bcd 
    
   ); 

  integer i,j;

  always @(bin) begin
  
    for(i = 0; i <= W+(W-4)/3; i = i+1) bcd[i] = 0;     
    
        bcd[W-1:0] = bin;     
                                      
    for(i = 0; i <= W-4; i = i+1)                      
    
      for(j = 0; j <= i/3; j = j+1)                     
      
        if (bcd[W-i+4*j -: 4] > 4)                      
        
            bcd[W-i+4*j -: 4] = bcd[W-i+4*j -: 4] + 4'd3; 
            
  end

endmodule

module conversor_BCD_Hrs

 #( parameter W = 11) 
 
  ( 
  
    input [W-1:0] bin, 
    output reg [W + (W - 4) / 3:0] bcd 
    
   ); 

  integer i,j;

  always @(bin) begin
  
    for(i = 0; i <= W+(W-4)/3; i = i+1) bcd[i] = 0;     
    
        bcd[W-1:0] = bin;     
                                      
    for(i = 0; i <= W-4; i = i+1)                      
    
      for(j = 0; j <= i/3; j = j+1)                     
      
        if (bcd[W-i+4*j -: 4] > 4)                      
        
            bcd[W-i+4*j -: 4] = bcd[W-i+4*j -: 4] + 4'd3; 
            
  end

endmodule

module conversor_BCD_SegN

 #( parameter W = 11) 
 
  ( 
  
    input [W-1:0] bin, 
    output reg [W + (W - 4) / 3:0] bcd 
    
   ); 

  integer i,j;

  always @(bin) begin
  
    for(i = 0; i <= W+(W-4)/3; i = i+1) bcd[i] = 0;     
    
        bcd[W-1:0] = bin;     
                                      
    for(i = 0; i <= W-4; i = i+1)                      
    
      for(j = 0; j <= i/3; j = j+1)                     
      
        if (bcd[W-i+4*j -: 4] > 4)                      
        
            bcd[W-i+4*j -: 4] = bcd[W-i+4*j -: 4] + 4'd3; 
            
  end

endmodule

module conversor_BCD_MinN

 #( parameter W = 11) 
 
  ( 
  
    input [W-1:0] bin, 
    output reg [W + (W - 4) / 3:0] bcd 
    
   ); 

  integer i,j;

  always @(bin) begin
  
    for(i = 0; i <= W+(W-4)/3; i = i+1) bcd[i] = 0;     
    
        bcd[W-1:0] = bin;     
                                      
    for(i = 0; i <= W-4; i = i+1)                      
    
      for(j = 0; j <= i/3; j = j+1)                     
      
        if (bcd[W-i+4*j -: 4] > 4)                      
        
            bcd[W-i+4*j -: 4] = bcd[W-i+4*j -: 4] + 4'd3; 
            
  end

endmodule

module conversor_BCD_HrsN

 #( parameter W = 11) 
 
  ( 
  
    input [W-1:0] bin, 
    output reg [W + (W - 4) / 3:0] bcd 
    
   ); 

  integer i,j;

  always @(bin) begin
  
    for(i = 0; i <= W+(W-4)/3; i = i+1) bcd[i] = 0;     
    
        bcd[W-1:0] = bin;     
                                      
    for(i = 0; i <= W-4; i = i+1)                      
    
      for(j = 0; j <= i/3; j = j+1)                     
      
        if (bcd[W-i+4*j -: 4] > 4)                      
        
            bcd[W-i+4*j -: 4] = bcd[W-i+4*j -: 4] + 4'd3; 
            
  end

endmodule
