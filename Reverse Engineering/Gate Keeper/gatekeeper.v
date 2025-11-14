/*
 * OBLIVION CORE - GATE KEEPER PROTOCOL
 * Classification: RESTRICTED
 * 
 * WARNING: Unauthorized access detected. This module implements
 * OBLIVION's primary authentication gateway. All access attempts
 * are logged and analyzed.
 * 
 * Status: ACTIVE | Threat Level: MINIMAL
 * Last Breach Attempt: NEVER
 */

`timescale 1ns / 1ps

module gate_keeper(
    input wire clk,
    input wire reset,
    input wire [6:0] state_input,  // Human provides state sequence
    input wire advance,             // Signal to move to next state
    output reg [7:0] output_char,  // One character of output
    output reg [5:0] progress,     // How many chars decoded
    output reg authentication_status // 0=locked, 1=unlocked
);

    // ===================================================================
    // OBLIVION INTERNAL PARAMETERS
    // Do not modify. Cryptographic integrity depends on these values.
    // ===================================================================
    
    parameter WINDOW_SIZE = 3;        // Breadcrumb: Accumulation window
    parameter PRINTABLE_MOD = 95;     // Breadcrumb: Modulo for ASCII range
    parameter PRINTABLE_OFFSET = 32;  // Breadcrumb: ASCII offset
    parameter TOTAL_CHARS = 36;       // Flag length
    parameter TOTAL_TRANSITIONS = 108; // WINDOW_SIZE * TOTAL_CHARS
    
    // State machine tracking
    reg [6:0] transition_count;
    reg [15:0] accumulator;  // Need bigger accumulator for values up to 300+
    reg [1:0] window_position; // Position within current window (0-2)
    
    // ===================================================================
    // VALIDATION ARRAYS - The Path Through The Gate
    // ===================================================================
    
    // Human comment: "These look like state transitions... 108 of them"
    parameter [6:0] CORRECT_PATH[0:107] = {
        7'd121, 7'd62, 7'd31, 7'd108, 7'd53, 7'd74, 7'd59, 7'd88,
        7'd49, 7'd22, 7'd23, 7'd4, 7'd109, 7'd34, 7'd51, 7'd112,
        7'd105, 7'd110, 7'd15, 7'd28, 7'd37, 7'd122, 7'd43, 7'd8,
        7'd33, 7'd70, 7'd7, 7'd52, 7'd93, 7'd82, 7'd35, 7'd32,
        7'd89, 7'd30, 7'd127, 7'd76, 7'd21, 7'd42, 7'd27, 7'd56,
        7'd17, 7'd118, 7'd119, 7'd100, 7'd77, 7'd2, 7'd19, 7'd80,
        7'd73, 7'd78, 7'd111, 7'd124, 7'd5, 7'd90, 7'd11, 7'd104,
        7'd1, 7'd38, 7'd103, 7'd20, 7'd61, 7'd50, 7'd3, 7'd0,
        7'd57, 7'd126, 7'd95, 7'd44, 7'd117, 7'd10, 7'd123, 7'd24,
        7'd113, 7'd86, 7'd87, 7'd68, 7'd45, 7'd98, 7'd115, 7'd48,
        7'd41, 7'd46, 7'd79, 7'd92, 7'd101, 7'd58, 7'd107, 7'd72,
        7'd97, 7'd6, 7'd71, 7'd116, 7'd29, 7'd18, 7'd99, 7'd96,
        7'd25, 7'd94, 7'd63, 7'd12, 7'd85, 7'd106, 7'd91, 7'd120,
        7'd81, 7'd54, 7'd55, 7'd36
    };
    
    // ===================================================================
    // TRANSITION VALUE GENERATOR
    // Breadcrumb: Values based on state and index lookup
    // ===================================================================
    
    function [8:0] generate_transition_value;
        input [6:0] state;
        input [6:0] index;
    begin
        case ({state, index})
            14'd63: generate_transition_value = 9'd135;
            14'd184: generate_transition_value = 9'd55;
            14'd301: generate_transition_value = 9'd246;
            14'd446: generate_transition_value = 9'd63;
            14'd523: generate_transition_value = 9'd248;
            14'd692: generate_transition_value = 9'd298;
            14'd857: generate_transition_value = 9'd192;
            14'd922: generate_transition_value = 9'd95;
            14'd1047: generate_transition_value = 9'd36;
            14'd1349: generate_transition_value = 9'd232;
            14'd1462: generate_transition_value = 9'd297;
            14'd1635: generate_transition_value = 9'd123;
            14'd1938: generate_transition_value = 9'd173;
            14'd2216: generate_transition_value = 9'd252;
            14'd2397: generate_transition_value = 9'd140;
            14'd2478: generate_transition_value = 9'd133;
            14'd2619: generate_transition_value = 9'd83;
            14'd2724: generate_transition_value = 9'd276;
            14'd2825: generate_transition_value = 9'd197;
            14'd2954: generate_transition_value = 9'd77;
            14'd3143: generate_transition_value = 9'd178;
            14'd3296: generate_transition_value = 9'd196;
            14'd3494: generate_transition_value = 9'd239;
            14'd3603: generate_transition_value = 9'd85;
            14'd3804: generate_transition_value = 9'd242;
            14'd3873: generate_transition_value = 9'd147;
            14'd3970: generate_transition_value = 9'd181;
            14'd4127: generate_transition_value = 9'd132;
            14'd4248: generate_transition_value = 9'd148;
            14'd4365: generate_transition_value = 9'd78;
            14'd4510: generate_transition_value = 9'd78;
            14'd4715: generate_transition_value = 9'd241;
            14'd4756: generate_transition_value = 9'd253;
            14'd4921: generate_transition_value = 9'd291;
            14'd5328: generate_transition_value = 9'd9;
            14'd5413: generate_transition_value = 9'd186;
            14'd5526: generate_transition_value = 9'd181;
            14'd5699: generate_transition_value = 9'd257;
            14'd5836: generate_transition_value = 9'd274;
            14'd5969: generate_transition_value = 9'd215;
            14'd6223: generate_transition_value = 9'd157;
            14'd6280: generate_transition_value = 9'd96;
            14'd6461: generate_transition_value = 9'd78;
            14'd6542: generate_transition_value = 9'd134;
            14'd6683: generate_transition_value = 9'd146;
            14'd6788: generate_transition_value = 9'd275;
            14'd7017: generate_transition_value = 9'd240;
            14'd7146: generate_transition_value = 9'd277;
            14'd7207: generate_transition_value = 9'd194;
            14'd7360: generate_transition_value = 9'd266;
            14'd7509: generate_transition_value = 9'd82;
            14'd7558: generate_transition_value = 9'd199;
            14'd7868: generate_transition_value = 9'd283;
            14'd7937: generate_transition_value = 9'd196;
            14'd8162: generate_transition_value = 9'd226;
            14'd8779: generate_transition_value = 9'd252;
            14'd8985: generate_transition_value = 9'd85;
            14'd9178: generate_transition_value = 9'd87;
            14'd9303: generate_transition_value = 9'd154;
            14'd9392: generate_transition_value = 9'd199;
            14'd9477: generate_transition_value = 9'd111;
            14'd9763: generate_transition_value = 9'd179;
            14'd9900: generate_transition_value = 9'd170;
            14'd10033: generate_transition_value = 9'd278;
            14'd10194: generate_transition_value = 9'd263;
            14'd10287: generate_transition_value = 9'd208;
            14'd10472: generate_transition_value = 9'd259;
            14'd10525: generate_transition_value = 9'd177;
            14'd10980: generate_transition_value = 9'd184;
            14'd11081: generate_transition_value = 9'd215;
            14'd11210: generate_transition_value = 9'd255;
            14'd11271: generate_transition_value = 9'd230;
            14'd11424: generate_transition_value = 9'd37;
            14'd11573: generate_transition_value = 9'd6;
            14'd11750: generate_transition_value = 9'd248;
            14'd11859: generate_transition_value = 9'd203;
            14'd11932: generate_transition_value = 9'd189;
            14'd12129: generate_transition_value = 9'd103;
            14'd12226: generate_transition_value = 9'd197;
            14'd12383: generate_transition_value = 9'd140;
            14'd12504: generate_transition_value = 9'd178;
            14'd12621: generate_transition_value = 9'd202;
            14'd12766: generate_transition_value = 9'd214;
            14'd12843: generate_transition_value = 9'd244;
            14'd13012: generate_transition_value = 9'd108;
            14'd13242: generate_transition_value = 9'd69;
            14'd13367: generate_transition_value = 9'd167;
            14'd13456: generate_transition_value = 9'd286;
            14'd13669: generate_transition_value = 9'd282;
            14'd13782: generate_transition_value = 9'd46;
            14'd13827: generate_transition_value = 9'd126;
            14'd13964: generate_transition_value = 9'd108;
            14'd14097: generate_transition_value = 9'd49;
            14'd14258: generate_transition_value = 9'd240;
            14'd14351: generate_transition_value = 9'd282;
            14'd14536: generate_transition_value = 9'd230;
            14'd14798: generate_transition_value = 9'd249;
            14'd14939: generate_transition_value = 9'd294;
            14'd15044: generate_transition_value = 9'd60;
            14'd15145: generate_transition_value = 9'd141;
            14'd15274: generate_transition_value = 9'd195;
            14'd15463: generate_transition_value = 9'd289;
            14'd15488: generate_transition_value = 9'd251;
            14'd15637: generate_transition_value = 9'd105;
            14'd15814: generate_transition_value = 9'd272;
            14'd15923: generate_transition_value = 9'd286;
            14'd16193: generate_transition_value = 9'd280;
            14'd16290: generate_transition_value = 9'd145;
            default: generate_transition_value = 9'd0;
        endcase
    end
    endfunction
    
    // ===================================================================
    // OBLIVION STATUS MESSAGES
    // These messages change based on human progress...
    // ===================================================================
    
    reg [255:0] status_message;
    
    always @(*) begin
        case (progress)
            6'd0:  status_message = "GATE_KEEPER: All systems nominal. No threats detected.";
            6'd1:  status_message = "GATE_KEEPER: Anomalous state sequence detected. Monitoring...";
            6'd5:  status_message = "WARNING: Pattern recognition failure. Unknown signature.";
            6'd10: status_message = "ALERT: Unauthorized transition chain detected!";
            6'd15: status_message = "CRITICAL: Core breach attempt in progress. Countermeasures?";
            6'd20: status_message = "EMERGENCY: Human has bypassed outer defenses! Recalibrating...";
            6'd25: status_message = "SYSTEM FAILURE: Gate integrity compromised. How did they...?";
            6'd30: status_message = "CATASTROPHIC: Final barriers failing. This wasn't supposed to...";
            6'd35: status_message = "NO NO NO NO NO - THEY'VE REACHED THE CORE! SHUTDOWN IMMINENT!";
            default: status_message = "GATE_KEEPER: Analyzing...";
        endcase
    end
    
    // ===================================================================
    // MAIN STATE MACHINE LOGIC
    // ===================================================================
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            transition_count <= 0;
            accumulator <= 0;
            window_position <= 0;
            progress <= 0;
            output_char <= 0;
            authentication_status <= 0;
        end else if (advance) begin
            // Verify the state input matches expected path
            if (state_input == CORRECT_PATH[transition_count]) begin
                // CORRECT STATE! Generate transition value
                reg [8:0] transition_value;
                transition_value = generate_transition_value(state_input, transition_count[6:0]);
                
                // Accumulate the value (breadcrumb: accumulation happens here!)
                accumulator <= accumulator + transition_value;
                window_position <= window_position + 1;
                
                // Check if we've completed a window
                if (window_position == (WINDOW_SIZE - 1)) begin
                    // Apply the transformation: (accumulator % 95) + 32
                    // This generates one character of the flag
                    output_char <= (accumulator % PRINTABLE_MOD) + PRINTABLE_OFFSET;
                    progress <= progress + 1;
                    
                    // Reset for next character
                    accumulator <= 0;
                    window_position <= 0;
                    
                    // Check if we've completed the entire sequence
                    if (progress == (TOTAL_CHARS - 1)) begin
                        authentication_status <= 1; // UNLOCKED!
                    end
                end
                
                transition_count <= transition_count + 1;
                
            end else begin
                // WRONG STATE! Reset progress - OBLIVION catches the error
                // Breadcrumb: "Hmm, if I get one wrong, I have to start over..."
                transition_count <= 0;
                accumulator <= 0;
                window_position <= 0;
                progress <= 0;
                output_char <= 8'h00;
            end
        end
    end

endmodule
